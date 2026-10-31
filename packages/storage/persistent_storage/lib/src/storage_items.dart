// coverage:ignore-file

import 'package:drift/drift.dart';

/// The drift table to store one row per value.
@DataClassName('StorageItem')
class StorageItems extends Table {
  /// The identifier for the value
  TextColumn get key => text()();

  /// The stored value
  TextColumn get value => text()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}
