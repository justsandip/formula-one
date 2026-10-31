# Changes to formula_one_api_client.dart

1. Import: `import 'package:response_cache/response_cache.dart';`

2. Constructor: add an optional cache.

```dart
FormulaOneApiClient({
  String baseUrl = defaultBaseUrl,
  Dio? dio,
  ResponseCache? cache,
})  : _cache = cache,
      _dio = dio ?? Dio(/* ...as today... */);

final ResponseCache? _cache;
```

3. Split `get`: the existing body becomes `_network`, and `get` decides whether
   to go through the cache.

```dart
/// Performs a GET request to [path] and returns the decoded JSON body.
///
/// With a cache, a response already fetched for the same path and query
/// parameters is returned without a network call.
///
/// (keep the existing "Throws a:" list)
Future<Map<String, dynamic>> get(
  String path, {
  Map<String, dynamic>? queryParameters,
}) {
  final cache = _cache;
  if (cache == null) return _network(path, queryParameters);
  return cache.fetch(
    key: cacheKey(path, queryParameters),
    network: () => _network(path, queryParameters),
  );
}

Future<Map<String, dynamic>> _network(
  String path,
  Map<String, dynamic>? queryParameters,
) async {
  // ...the previous body of get(), unchanged...
}
```

4. pubspec: depend on `response_cache`; add `storage` as a dev dependency for
   the tests (they use `InMemoryStorage`).
