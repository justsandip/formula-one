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
      int fetchedAt = 0,
      Map<String, dynamic> body = const {'old': true},
    }) => jsonEncode(<String, dynamic>{
      'formatVersion': formatVersion,
      'fetchedAt': fetchedAt,
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

    group('ttl', () {
      final now = DateTime.utc(2026, 10, 31, 12);
      int at(Duration ago) => now.subtract(ago).millisecondsSinceEpoch;

      Future<Map<String, dynamic>> fetchAt({
        Duration? ttl,
        bool Function(Object error)? serveStaleWhen,
        Future<Map<String, dynamic>> Function()? net,
      }) => withClock(
        Clock.fixed(now),
        () => cache.fetch(
          key: key,
          network: net ?? network,
          ttl: ttl,
          serveStaleWhen: serveStaleWhen,
        ),
      );

      void stubStored(int fetchedAt) =>
          when(() => storage.read(key: key))
              .thenAnswer((_) async => stored(fetchedAt: fetchedAt));

      test('serves a response younger than the ttl', () async {
        stubStored(at(const Duration(minutes: 59)));

        final body = await fetchAt(ttl: const Duration(hours: 1));

        expect(body, {'old': true});
        expect(networkCalls, 0);
      });

      test('refetches a response older than the ttl', () async {
        stubStored(at(const Duration(minutes: 61)));

        final body = await fetchAt(ttl: const Duration(hours: 1));

        expect(body, {'call': 1});
        expect(written()['fetchedAt'], now.millisecondsSinceEpoch);
      });

      test('treats a response exactly as old as the ttl as expired', () async {
        stubStored(at(const Duration(hours: 1)));

        await fetchAt(ttl: const Duration(hours: 1));

        expect(networkCalls, 1);
      });

      test('never expires without a ttl', () async {
        stubStored(at(const Duration(days: 365)));

        final body = await fetchAt();

        expect(body, {'old': true});
        expect(networkCalls, 0);
      });

      test('always refetches with a zero ttl', () async {
        stubStored(at(Duration.zero));

        await fetchAt(ttl: Duration.zero);

        expect(networkCalls, 1);
      });

      test('does not trust a fetch time in the future', () async {
        stubStored(now.add(const Duration(hours: 1)).millisecondsSinceEpoch);

        await fetchAt(ttl: const Duration(hours: 1));

        expect(networkCalls, 1);
      });
    });

    group('serving stale responses', () {
      final now = DateTime.utc(2026, 10, 31, 12);
      final expired = now
          .subtract(const Duration(hours: 5))
          .millisecondsSinceEpoch;
      const ttl = Duration(hours: 1);
      final outage = Exception('offline');

      var failures = 0;
      Future<Map<String, dynamic>> failingNetwork() async {
        failures++;
        throw outage;
      }

      setUp(() => failures = 0);

      Future<Map<String, dynamic>> fetchStale({
        bool Function(Object error)? serveStaleWhen,
      }) => withClock(
        Clock.fixed(now),
        () => cache.fetch(
          key: key,
          network: failingNetwork,
          ttl: ttl,
          serveStaleWhen: serveStaleWhen,
        ),
      );

      test('serves the expired response when the predicate agrees', () async {
        when(() => storage.read(key: key))
            .thenAnswer((_) async => stored(fetchedAt: expired));
        Object? asked;

        final body = await fetchStale(
          serveStaleWhen: (error) {
            asked = error;
            return true;
          },
        );

        expect(body, {'old': true});
        expect(asked, same(outage));
        verifyNoWrites();
      });

      test('tries the network again on every request while stale', () async {
        when(() => storage.read(key: key))
            .thenAnswer((_) async => stored(fetchedAt: expired));

        await fetchStale(serveStaleWhen: (_) => true);
        await fetchStale(serveStaleWhen: (_) => true);

        expect(failures, 2);
      });

      test('rethrows when the predicate refuses', () async {
        when(() => storage.read(key: key))
            .thenAnswer((_) async => stored(fetchedAt: expired));

        await expectLater(
          fetchStale(serveStaleWhen: (_) => false),
          throwsA(same(outage)),
        );
      });

      test('rethrows when there is no predicate', () async {
        when(() => storage.read(key: key))
            .thenAnswer((_) async => stored(fetchedAt: expired));

        await expectLater(fetchStale(), throwsA(same(outage)));
      });

      test('rethrows when nothing is stored', () async {
        await expectLater(
          fetchStale(serveStaleWhen: (_) => true),
          throwsA(same(outage)),
        );
      });

      test(
        'never serves a response written with another format version',
        () async {
          when(() => storage.read(key: key)).thenAnswer(
            (_) async => stored(formatVersion: 99, fetchedAt: expired),
          );

          await expectLater(
            fetchStale(serveStaleWhen: (_) => true),
            throwsA(same(outage)),
          );
        },
      );

      test('does not ask the predicate while the response is fresh', () async {
        when(() => storage.read(key: key)).thenAnswer(
          (_) async => stored(
            fetchedAt: now
                .subtract(const Duration(minutes: 5))
                .millisecondsSinceEpoch,
          ),
        );
        var asked = false;

        final body = await fetchStale(
          serveStaleWhen: (_) {
            asked = true;
            return true;
          },
        );

        expect(body, {'old': true});
        expect(asked, isFalse);
        expect(failures, 0);
      });
    });
  });
}
