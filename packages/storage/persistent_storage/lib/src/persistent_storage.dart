import 'package:persistent_storage/persistent_storage.dart';
import 'package:storage/storage.dart';

/// {@template persistent_storage}
/// Storage that saves data in the device's persistent memory.
/// {@endtemplate}
class PersistentStorage implements Storage {
  /// {@macro persistent_storage}
  const new({required this._database});

  final StorageDatabase _database;

  /// Returns value for the provided [key] from storage.
  /// Returns `null` if no value is found for the given [key].
  ///
  /// Throws a [StorageException] if the read fails.
  @override
  Future<String?> read({required String key}) async {
    try {
      final query = _database.select(_database.storageItems)
        ..where((table) => table.key.equals(key));
      final row = await query.getSingleOrNull();
      return row?.value;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageException(error), stackTrace);
    }
  }

  /// Writes the provided [key], [value] pair into storage.
  ///
  /// Throws a [StorageException] if the write fails.
  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _database
          .into(_database.storageItems)
          .insertOnConflictUpdate(
            StorageItemsCompanion.insert(key: key, value: value),
          );
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageException(error), stackTrace);
    }
  }

  /// Removes the value for the provided [key] from storage.
  ///
  /// Throws a [StorageException] if the delete fails.
  @override
  Future<void> delete({required String key}) async {
    try {
      final query = _database.delete(_database.storageItems)
        ..where((table) => table.key.equals(key));
      await query.go();
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageException(error), stackTrace);
    }
  }

  /// Removes all key, value pairs from storage.
  ///
  /// Throws a [StorageException] if the clear fails.
  @override
  Future<void> clear() async {
    try {
      await _database.delete(_database.storageItems).go();
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(StorageException(error), stackTrace);
    }
  }
}
