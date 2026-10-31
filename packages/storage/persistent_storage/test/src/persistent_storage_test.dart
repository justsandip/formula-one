import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

/// A database whose tables were never created, so every query fails.
class _BrokenDatabase extends StorageDatabase {
  new() : super(NativeDatabase.memory());

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {});
}

void main() {
  group('PersistentStorage', () {
    group('failures', () {
      late StorageDatabase database;
      late PersistentStorage storage;

      setUp(() {
        database = _BrokenDatabase();
        storage = PersistentStorage(database: database);
      });

      tearDown(() => database.close());

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
        await expectLater(storage.clear(), throwsA(isA<StorageException>()));
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
