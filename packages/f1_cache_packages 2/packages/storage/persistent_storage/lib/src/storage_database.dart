import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'storage_database.g.dart';

/// The `key_values` table: one row per stored value.
@DataClassName('KeyValue')
class KeyValues extends Table {
  /// Identifies the value.
  TextColumn get key => text()();

  /// The stored value.
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// {@template storage_database}
/// The Drift database behind [PersistentStorage].
///
/// Its [schemaVersion] versions the tables. It is unrelated to the format
/// version of the values stored in them.
/// {@endtemplate}
@DriftDatabase(tables: [KeyValues])
class StorageDatabase extends _$StorageDatabase {
  /// {@macro storage_database}
  StorageDatabase(super.executor);

  /// Opens the database stored in [file], in a background isolate.
  StorageDatabase.persistent(File file)
      : this(NativeDatabase.createInBackground(file));

  @override
  int get schemaVersion => 1;
}
