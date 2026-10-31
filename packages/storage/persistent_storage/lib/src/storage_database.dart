import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:persistent_storage/src/storage_items.dart';

part 'storage_database.g.dart';

/// {@template storage_database}
/// The Drift database behind [PersistentStorage].
///
/// Its [schemaVersion] versions the tables. It is unrelated to the format
/// version of the values stored in them.
/// {@endtemplate}
@DriftDatabase(tables: [StorageItems])
class StorageDatabase extends _$StorageDatabase {
  /// {@macro storage_database}
  // new([QueryExecutor? executor]) : super(executor ?? _openConnection());
  new(super.e);

  /// Opens the database stored in [file], in a background isolate.
  new persistent(File file) : this(NativeDatabase.createInBackground(file));

  @override
  int get schemaVersion => 1;
}
