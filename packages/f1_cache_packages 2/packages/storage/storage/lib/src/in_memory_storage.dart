import 'package:storage/src/storage.dart';

/// {@template in_memory_storage}
/// A [Storage] that keeps values in memory. Nothing survives a restart.
///
/// Useful in tests, and as a stand-in until a persistent storage is wired up.
/// {@endtemplate}
class InMemoryStorage implements Storage {
  /// {@macro in_memory_storage}
  InMemoryStorage();

  final Map<String, String> _values = {};

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }
}
