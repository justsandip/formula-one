import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:response_cache/response_cache.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

class _MockStorage extends Mock implements Storage;

void main() {
  setUpAll(() => registerFallbackValue(''));

  group('ResponseCache', () {
    const key = '/current/driverStandings.json';

    late Storage storage;
    late ResponseCache cache;
    late int networkCalls;

    Future<Map<String, dynamic>> network() async {
      networkCalls++;
      return <String, dynamic>{'call': networkCalls};
    }

    /// A stored response as the cache writes it.
    String stored({
      int formatVersion = 1,
      Map<String, dynamic> body = const {'old': true},
    }) => jsonEncode(<String, dynamic>{
      'formatVersion': formatVersion,
      'fetchedAt': 0,
      'body': body,
    });

    /// The value passed to `storage.write` for [key]. Fails if there was not
    /// exactly one write.
    Map<String, dynamic> written() {
      final value =
          verify(
                () => storage.write(
                  key: key,
                  value: captureAny(named: 'value'),
                ),
              ).captured.single
              as String;
      return jsonDecode(value) as Map<String, dynamic>;
    }

    void verifyNoWrites() => verifyNever(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    );

    setUp(() {
      storage = _MockStorage();
      // Defaults: nothing stored, and writes succeed.
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      cache = ResponseCache(storage: storage);
      networkCalls = 0;
    });

    test('goes to the network on a miss and returns the body', () async {
      final body = await cache.fetch(key: key, network: network);

      expect(body, {'call': 1});
      expect(networkCalls, 1);
      verify(() => storage.read(key: key)).called(1);
    });

    test('stores the body with the fetch time and format version', () async {
      await withClock(Clock.fixed(DateTime.utc(2026, 10, 30, 12)), () async {
        await cache.fetch(key: key, network: network);
      });

      expect(written(), {
        'formatVersion': 1,
        'fetchedAt': DateTime.utc(2026, 10, 30, 12).millisecondsSinceEpoch,
        'body': {'call': 1},
      });
    });

    test('serves later requests from the cache without the network', () async {
      await cache.fetch(key: key, network: network);
      final firstWrite =
          verify(
                () => storage.write(
                  key: key,
                  value: captureAny(named: 'value'),
                ),
              ).captured.single
              as String;
      // From now on the storage returns what the cache wrote.
      when(() => storage.read(key: key)).thenAnswer((_) async => firstWrite);

      final second = await cache.fetch(key: key, network: network);

      expect(second, {'call': 1});
      expect(networkCalls, 1);
    });

    test('serves a response stored earlier', () async {
      when(() => storage.read(key: key)).thenAnswer((_) async => stored());

      final body = await cache.fetch(key: key, network: network);

      expect(body, {'old': true});
      expect(networkCalls, 0);
      verifyNoWrites();
    });

    test('keeps different keys apart', () async {
      when(() => storage.read(key: '/a.json'))
          .thenAnswer((_) async => stored(body: const {'a': 1}));

      final a = await cache.fetch(key: '/a.json', network: network);
      final b = await cache.fetch(key: '/b.json', network: network);

      expect(a, {'a': 1});
      expect(b, {'call': 1});
      expect(networkCalls, 1);
      verify(() => storage.read(key: '/a.json')).called(1);
      verify(() => storage.read(key: '/b.json')).called(1);
    });

    test('rethrows a network failure and stores nothing', () async {
      final failure = Exception('offline');

      await expectLater(
        cache.fetch(key: key, network: () async => throw failure),
        throwsA(same(failure)),
      );

      verifyNoWrites();
    });

    test('goes to the network again after a failure', () async {
      await expectLater(
        cache.fetch(key: key, network: () async => throw Exception('offline')),
        throwsException,
      );

      final body = await cache.fetch(key: key, network: network);

      expect(body, {'call': 1});
      verify(() => storage.read(key: key)).called(2);
    });

    test('ignores a response written with another format version', () async {
      when(() => storage.read(key: key)).thenAnswer((_) async => stored());
      final upgraded = ResponseCache(storage: storage, formatVersion: 2);

      final body = await upgraded.fetch(key: key, network: network);

      expect(body, {'call': 1});
      expect(written()['formatVersion'], 2);
    });

    for (final corrupt in <String, String>{
      'text that is not JSON': 'not json',
      'JSON that is not an object': '[1,2]',
      'an object without the expected fields': '{}',
    }.entries) {
      test('treats ${corrupt.key} as a miss and overwrites it', () async {
        when(() => storage.read(key: key))
            .thenAnswer((_) async => corrupt.value);

        final body = await cache.fetch(key: key, network: network);

        expect(body, {'call': 1});
        expect(written()['body'], {'call': 1});
      });
    }

    test('falls back to the network when reading the storage fails', () async {
      when(() => storage.read(key: key))
          .thenAnswer((_) async => throw const StorageException('read failed'));

      final body = await cache.fetch(key: key, network: network);

      expect(body, {'call': 1});
    });

    test('still returns the body when writing the storage fails', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => throw const StorageException('write failed'));

      final first = await cache.fetch(key: key, network: network);
      final second = await cache.fetch(key: key, network: network);

      expect(first, {'call': 1});
      // Nothing was stored, so the second request goes to the network again.
      expect(second, {'call': 2});
    });
  });
}
