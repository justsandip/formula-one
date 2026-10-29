import 'package:api_client/api_client.dart';

/// {@template formula_one_repository}
/// Single source of Formula One data for the app.
///
/// Today every call goes straight to the [FormulaOneApiClient]. Local
/// caching will be added here, so callers do not need to change.
/// {@endtemplate}
class FormulaOneRepository {
  /// {@macro formula_one_repository}
  const FormulaOneRepository({required FormulaOneApiClient apiClient})
    : _apiClient = apiClient;

  final FormulaOneApiClient _apiClient;

  /// Returns every race of [season], or of the current season when null.
  ///
  /// Throws a [FormulaOneApiFailure] if the races cannot be loaded.
  Future<List<Race>> getRaces({int? season}) {
    return _apiClient.racesResource.getRaces(season: season);
  }

  /// Returns current drivers' standing for the [season]. Defaults to
  /// the current season.
  ///
  /// Throws a [FormulaOneApiFailure] if the standings cannot be loaded.
  Future<List<DriverStanding>> getDriverStandings({String season = 'current'}) {
    return _apiClient.standingsResource.getDriverStandings(season: season);
  }

  /// Returns current constructors' standing for the [season]. Defaults to
  /// the current season.
  ///
  /// Throws a [FormulaOneApiFailure] if the standings cannot be loaded.
  Future<List<ConstructorStanding>> getConstructorStandings({
    String season = 'current',
  }) {
    return _apiClient.standingsResource.getConstructorStandings(season: season);
  }

  /// Returns the classification of race [round] of [season], or of the
  /// current season when null.
  ///
  /// Returns null if the race has not been run yet.
  ///
  /// Throws a [FormulaOneApiFailure] if the results cannot be loaded.
  Future<RaceResults?> getRaceResults({required int round, int? season}) {
    return _apiClient.resultsResource.getRaceResults(
      round: round,
      season: season,
    );
  }

  /// Returns the classification of the most recent race with results.
  ///
  /// Returns null if the season has no results yet.
  ///
  /// Throws a [FormulaOneApiFailure] if the results cannot be loaded.
  Future<RaceResults?> getLatestRaceResults() {
    return _apiClient.resultsResource.getLatestRaceResults();
  }
}
