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

  /// Returns the stored response for [key] if it is still fresh, or calls
  /// [network], stores its result and returns it.
  ///
  /// A stored response is fresh when it is younger than [ttl]. With a `null`
  /// [ttl] it never expires. A fetch time in the future is not trusted, so,
  /// that response counts as expired.
  ///
  /// If [network] throws and an expired response exists, [serveStaleWhen] is
  /// asked about the error. When it returns `true` the expired response is
  /// returned. Otherwise, and when there is no [serveStaleWhen], the error is
  /// rethrown. A response written with another format version is never served.
  Future<Map<String, dynamic>> fetch({
    required String key,
    required Future<Map<String, dynamic>> Function() network,
    Duration? ttl,
    bool Function(Object error)? serveStaleWhen,
  }) async {
    final cached = await _read(key);
    if (cached != null && _isFresh(cached, ttl)) return cached.body;

    final Map<String, dynamic> body;
    try {
      body = await network();
    } on Object catch (error) {
      if (cached != null && (serveStaleWhen?.call(error) ?? false)) {
        return cached.body;
      }
      rethrow;
    }

    await _write(key, body);
    return body;
  }

  Future<StoredResponse?> _read(String key) async {
    final String? source;

    try {
      source = await _storage.read(key: key);
    } on StorageException {
      return null;
    }

    if (source == null) return null;

    final cached = StoredResponse.tryDecode(source);
    if (cached == null || cached.formatVersion != formatVersion) return null;

    return cached;
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

  bool _isFresh(StoredResponse stored, Duration? ttl) {
    if (ttl == null) return true;
    final age = clock.now().difference(stored.fetchedAt);
    return !age.isNegative && age < ttl;
  }
}
