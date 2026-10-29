import 'package:api_client/api_client.dart';

/// {@template results_resource}
/// Access to the race results endpoints.
/// {@endtemplate}
class ResultsResource {
  /// {@macro results_resource}
  const ResultsResource({required FormulaOneApiClient apiClient})
    : _apiClient = apiClient;

  final FormulaOneApiClient _apiClient;

  /// Fetches the classification of race [round] of [season], or of the
  /// current season when null.
  ///
  /// Returns null if the race has not been run yet.
  Future<RaceResults?> getRaceResults({required int round, int? season}) {
    return _fetch('/${season ?? 'current'}/$round/results.json');
  }

  /// Fetches the classification of the most recent race with results.
  ///
  /// Returns null if the season has no results yet.
  Future<RaceResults?> getLatestRaceResults() {
    return _fetch('/current/last/results.json');
  }

  Future<RaceResults?> _fetch(String path) async {
    // One race never has more than 100 entries, so one request is enough.
    final json = await _apiClient.get(path, queryParameters: {'limit': 100});
    try {
      final mrData = json['MRData'] as Map<String, dynamic>;
      final table = mrData['RaceTable'] as Map<String, dynamic>;
      final races = table['Races'] as List<dynamic>;
      if (races.isEmpty) return null;

      final raceJson = races.first as Map<String, dynamic>;
      final results = (raceJson['Results'] as List<dynamic>)
          .map((e) => RaceResult.fromJson(e as Map<String, dynamic>))
          .toList();

      final total = int.parse(mrData['total'] as String);
      if (results.length != total) {
        throw StateError('Got ${results.length} of $total results');
      }

      return RaceResults(race: Race.fromJson(raceJson), results: results);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FormulaOneDeserializationFailure(
          'Could not decode response from $path',
          cause: error,
        ),
        stackTrace,
      );
    }
  }
}
