const _schedule = Duration(hours: 12);
const _standings = Duration(hours: 1);
const _results = Duration(hours: 3);
const _latestResults = Duration(minutes: 15);
const _fallback = Duration(hours: 1);

final _season = RegExp(r'^/(\d{4})(?:[/.]|$)');
final _latestResultsPath = RegExp(r'^/[^/]+/last/results\.json$');
final _standingsPath = RegExp(r'^/[^/]+/(driver|constructor)Standings\.json$');
final _resultsPath = RegExp(r'^/[^/]+/\d+/results\.json$');
final _schedulePath = RegExp(r'^/[^/]+\.json$');

/// How long a response for [path] stays fresh. `null` means it never
/// expires.
///
/// A season that is already over cannot change, so its endpoints never
/// expire. Everything else gets a TTL by kind of data, and unknown endpoints
/// get a short one so a new endpoint cannot be stuck on old data.
Duration? cacheTtlFor(String path, {required DateTime now}) {
  final season = _season.firstMatch(path)?.group(1);
  if (season != null && int.parse(season) < now.year) return null;

  if (_latestResultsPath.hasMatch(path)) return _latestResults;
  if (_standingsPath.hasMatch(path)) return _standings;
  if (_resultsPath.hasMatch(path)) return _results;
  if (_schedulePath.hasMatch(path)) return _schedule;
  return _fallback;
}
