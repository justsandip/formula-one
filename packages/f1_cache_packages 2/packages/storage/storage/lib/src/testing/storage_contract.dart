import 'package:storage/storage.dart';
import 'package:test/test.dart';

/// Runs the behavior every [Storage] implementation must have.
///
/// [create] builds a fresh, empty storage for each test. [dispose] runs after
/// each test, e.g. to close a database.
void runStorageContractTests(
  Storage Function() create, {
  Future<void> Function(Storage storage)? dispose,
}) {
  group('Storage contract', () {
    late Storage storage;

    setUp(() {
      storage = create();
    });

    tearDown(() async {
      await dispose?.call(storage);
    });

    test('read returns null for an absent key', () async {
      expect(await storage.read(key: 'missing'), isNull);
    });

    test('write then read returns the value', () async {
      await storage.write(key: 'k', value: '{"a":1}');

      expect(await storage.read(key: 'k'), '{"a":1}');
    });

    test('write replaces the value of an existing key', () async {
      await storage.write(key: 'k', value: 'one');
      await storage.write(key: 'k', value: 'two');

      expect(await storage.read(key: 'k'), 'two');
    });

    test('keeps different keys apart', () async {
      await storage.write(key: 'a', value: '1');
      await storage.write(key: 'b', value: '2');

      expect(await storage.read(key: 'a'), '1');
      expect(await storage.read(key: 'b'), '2');
    });

    test('stores an empty value', () async {
      await storage.write(key: 'k', value: '');

      expect(await storage.read(key: 'k'), '');
    });

    test('round-trips keys with slashes, question marks and equals signs',
        () async {
      const key = '/2025/17/results.json?limit=100&offset=0';
      await storage.write(key: key, value: '{}');

      expect(await storage.read(key: key), '{}');
    });

    test('round-trips unicode and large values', () async {
      final value = '{"name":"São Paulo · Hülkenberg","pad":"${'x' * 1000000}"}';
      await storage.write(key: 'large', value: value);

      expect(await storage.read(key: 'large'), value);
    });

    test('delete removes only the given key', () async {
      await storage.write(key: 'a', value: '1');
      await storage.write(key: 'b', value: '2');

      await storage.delete(key: 'a');

      expect(await storage.read(key: 'a'), isNull);
      expect(await storage.read(key: 'b'), '2');
    });

    test('delete of an absent key does not throw', () async {
      await expectLater(storage.delete(key: 'missing'), completes);
    });

    test('clear removes every value', () async {
      await storage.write(key: 'a', value: '1');
      await storage.write(key: 'b', value: '2');

      await storage.clear();

      expect(await storage.read(key: 'a'), isNull);
      expect(await storage.read(key: 'b'), isNull);
    });

    test('clear on an empty storage does not throw', () async {
      await expectLater(storage.clear(), completes);
    });
  });
}
