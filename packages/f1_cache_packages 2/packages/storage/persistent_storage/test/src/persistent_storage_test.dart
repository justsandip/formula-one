import 'dart:io';

import 'package:drift/native.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:storage/storage.dart';
import 'package:storage/testing.dart';
import 'package:test/test.dart';

void main() {
  group('PersistentStorage', () {
    // Each contract test gets a fresh in-memory database, so the contract the
    // in-memory storage passes is checked against real SQLite.
    late StorageDatabase database;

    runStorageContractTests(
      () {
        database = StorageDatabase(NativeDatabase.memory());
        return PersistentStorage(database: database);
      },
      dispose: (_) => database.close(),
    );

    group('failures', () {
      late PersistentStorage storage;

      setUp(() async {
        final closed = StorageDatabase(NativeDatabase.memory());
        storage = PersistentStorage(database: closed);
        await closed.close();
      });

      test('read throws a StorageException', () async {
        await expectLater(
          storage.read(key: 'k'),
          throwsA(isA<StorageException>()),
        );
      });

      test('write throws a StorageException', () async {
        await expectLater(
          storage.write(key: 'k', value: 'v'),
          throwsA(isA<StorageException>()),
        );
      });

      test('delete throws a StorageException', () async {
        await expectLater(
          storage.delete(key: 'k'),
          throwsA(isA<StorageException>()),
        );
      });

      test('clear throws a StorageException', () async {
        await expectLater(
          storage.clear(),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('persistence', () {
      test('values survive reopening the database file', () async {
        final directory = await Directory.systemTemp.createTemp('f1_storage');
        addTearDown(() => directory.delete(recursive: true));
        final file = File('${directory.path}/storage.sqlite');

        final first = StorageDatabase.persistent(file);
        await PersistentStorage(database: first).write(key: 'k', value: 'v');
        await first.close();

        final second = StorageDatabase.persistent(file);
        addTearDown(second.close);

        expect(await PersistentStorage(database: second).read(key: 'k'), 'v');
      });
    });
  });
}
