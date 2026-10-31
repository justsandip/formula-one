import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:response_cache/response_cache.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

/// Wraps an in-memory storage and fails on demand.
class _FlakyStorage implements Storage {
  _FlakyStorage({this.failReads = false, this.failWrites = false});

  final bool failReads;
  final bool failWrites;
  final InMemoryStorage inner = InMemoryStorage();

  @override
  Future<String?> read({required String key}) async {
    if (failReads) throw const StorageException('read failed');
    return inner.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    if (failWrites) throw const StorageException('write failed');
    return inner.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) => inner.delete(key: key);

  @override
  Future<void> clear() => inner.clear();
}

void main() {
  group('ResponseCache', () {
    const key = '/current/driverStandings.json';

    late InMemoryStorage storage;
    late ResponseCache cache;
    late int networkCalls;

    Future<Map<String, dynamic>> network() async {
      networkCalls++;
      return <String, dynamic>{'call': networkCalls};
    }

    String stored({
      int formatVersion = 1,
      Map<String, dynamic> body = const {'old': true},
    }) =>
        jsonEncode(<String, dynamic>{
          'formatVersion': formatVersion,
          'fetchedAt': 0,
          'body': body,
        });

    setUp(() {
      storage = InMemoryStorage();
      cache = ResponseCache(storage: storage);
      networkCalls = 0;
    });

    test('goes to the network on a miss and returns the body', () async {
      final body = await cache.fetch(key: key, network: network);

      expect(body, {'call': 1});
      expect(networkCalls, 1);
    });

    test('stores the body with the fetch time and format version', () async {
      await withClock(Clock.fixed(DateTime.utc(2026, 10, 30, 12)), () async {
        await cache.fetch(key: key, network: network);
      });

      final json = jsonDecode((await storage.read(key: key))!);

      expect(json, {
        'formatVersion': 1,
        'fetchedAt': DateTime.utc(2026, 10, 30, 12).millisecondsSinceEpoch,
        'body': {'call': 1},
      });
    });

    test('serves later requests from the cache without the network',
        () async {
      await cache.fetch(key: key, network: network);

      final second = await cache.fetch(key: key, network: network);

      expect(second, {'call': 1});
      expect(networkCalls, 1);
    });

    test('serves a response stored earlier', () async {
      await storage.write(key: key, value: stored());

      final body = await cache.fetch(key: key, network: network);

      expect(body, {'old': true});
      expect(networkCalls, 0);
    });

    test('keeps different keys apart', () async {
      await cache.fetch(key: '/a.json', network: network);
      final other = await cache.fetch(key: '/b.json', network: network);

      expect(other, {'call': 2});
      expect(networkCalls, 2);
    });

    test('rethrows a network failure and stores nothing', () async {
      final failure = Exception('offline');

      await expectLater(
        cache.fetch(key: key, network: () async => throw failure),
        throwsA(same(failure)),
      );

      expect(await storage.read(key: key), isNull);
    });

    test('goes to the network again after a failure', () async {
      await expectLater(
        cache.fetch(key: key, network: () async => throw Exception('offline')),
        throwsException,
      );

      final body = await cache.fetch(key: key, network: network);

      expect(body, {'call': 1});
    });

    test('ignores a response written with another format version', () async {
      await storage.write(key: key, value: stored());
      final upgraded = ResponseCache(storage: storage, formatVersion: 2);

      final body = await upgraded.fetch(key: key, network: network);

      expect(body, {'call': 1});
      expect(
        (jsonDecode((await storage.read(key: key))!)
            as Map<String, dynamic>)['formatVersion'],
        2,
      );
    });

    for (final corrupt in <String, String>{
      'text that is not JSON': 'not json',
      'JSON that is not an object': '[1,2]',
      'an object without the expected fields': '{}',
    }.entries) {
      test('treats ${corrupt.key} as a miss and overwrites it', () async {
        await storage.write(key: key, value: corrupt.value);

        final body = await cache.fetch(key: key, network: network);

        expect(body, {'call': 1});
        expect(
          (jsonDecode((await storage.read(key: key))!)
              as Map<String, dynamic>)['body'],
          {'call': 1},
        );
      });
    }

    test('falls back to the network when reading the storage fails',
        () async {
      final flaky = ResponseCache(storage: _FlakyStorage(failReads: true));

      final body = await flaky.fetch(key: key, network: network);

      expect(body, {'call': 1});
    });

    test('still returns the body when writing the storage fails', () async {
      final flaky = ResponseCache(storage: _FlakyStorage(failWrites: true));

      final first = await flaky.fetch(key: key, network: network);
      final second = await flaky.fetch(key: key, network: network);

      expect(first, {'call': 1});
      // Nothing was stored, so the second request goes to the network again.
      expect(second, {'call': 2});
    });
  });
}
