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
}
