import 'package:clock/clock.dart';
import 'package:response_cache/response_cache.dart';
import 'package:storage/storage.dart';

/// {@template response_cache}
/// Serves JSON API responses from a Storage and goes to network only on a miss.
///
/// A stored response is used when it was written with the same
/// [formatVersion] and decodes properly. Anything else is a miss. A broken
/// storage never fails a request: read and write errors are ignored.
/// {@endtemplate}
class ResponseCache {
  /// {@macro response_cache}
  const new({required this._storage, this.formatVersion = 1});

  final Storage _storage;

  /// Version stamped on every response written. Bump it when the format of
  /// stored responses changes, so older ones are ignored.
  final int formatVersion;

  /// Returns the stored response for [key], or calls [network], stores its
  /// result and returns it.
  ///
  /// Errors thrown by [network] are rethrown, and nothing is stored.
  Future<Map<String, dynamic>> fetch({
    required String key,
    required Future<Map<String, dynamic>> Function() network,
  }) async {
    final cached = await _read(key);
    if (cached != null) return cached;

    final body = await network();
    await _write(key, body);
    return body;
  }

  Future<Map<String, dynamic>?> _read(String key) async {
    final String? source;

    try {
      source = await _storage.read(key: key);
    } on StorageException {
      return null;
    }

    if (source == null) return null;

    final cached = StoredResponse.tryDecode(source);
    if (cached == null || cached.formatVersion != formatVersion) return null;

    return cached.body;
  }

  Future<void> _write(String key, Map<String, dynamic> body) async {
    try {
      await _storage.write(
        key: key,
        value: StoredResponse(
          body: body,
          fetchedAt: clock.now(),
          formatVersion: formatVersion,
        ).encode(),
      );
    } on StorageException {
      // A cache that cannot be written must never fail the request.
    }
  }
}
