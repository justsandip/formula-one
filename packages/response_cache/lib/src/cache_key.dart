/// Builds the cache key for a request.
///
/// The key is [path], followed by `?` and the query parameters sorted by
/// name when there are any. Sorting means `?a=1&b=2` and `?b=2&a=1` share one
/// stored response.
String cacheKey(String path, [Map<String, dynamic>? queryParameters]) {
  if (queryParameters == null || queryParameters.isEmpty) return path;
  final names = queryParameters.keys.toList()..sort();
  final query = names.map((name) => '$name=${queryParameters[name]}').join('&');
  return '$path?$query';
}
