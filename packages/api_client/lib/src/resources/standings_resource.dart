import 'package:api_client/api_client.dart';
import 'package:meta/meta.dart';

/// {@template standings_resource}
/// Access to the standings endpoints (driver and constructor).
/// {@endtemplate}
class StandingsResource {
  /// {@macro standings_resource}
  const StandingsResource({required FormulaOneApiClient apiClient})
    : _apiClient = apiClient;

  final FormulaOneApiClient _apiClient;

  /// Limit for the API request
  @visibleForTesting
  static const limit = <String, dynamic>{'limit': 100};

  /// Fetches the current standing for the Drivers' Championship
  /// for the [season]
  Future<List<DriverStanding>> getDriverStandings({int? season}) async {
    final path = '/${season ?? 'current'}/driverStandings.json';
    final json = await _apiClient.get(path, queryParameters: limit);
    try {
      final mrData = json['MRData'] as Map<String, dynamic>;
      final table = mrData['StandingsTable'] as Map<String, dynamic>;
      final standings = table['StandingsLists'] as List<dynamic>;
      if (standings.isEmpty) return const [];

      final rows =
          (standings.first as Map<String, dynamic>)['DriverStandings']
              as List<dynamic>;
      return rows
          .map((e) => DriverStanding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FormulaOneDeserializationFailure(
          'Could not decode response from $path',
          cause: error,
        ),
        stackTrace,
      );
    }
  }

  /// Fetches the current standing for the Constructors' Championship
  /// for the [season]
  Future<List<ConstructorStanding>> getConstructorStandings({
    int? season,
  }) async {
    final path = '/${season ?? 'current'}/constructorStandings.json';
    final json = await _apiClient.get(path, queryParameters: limit);
    try {
      final mrData = json['MRData'] as Map<String, dynamic>;
      final table = mrData['StandingsTable'] as Map<String, dynamic>;
      final standings = table['StandingsLists'] as List<dynamic>;
      if (standings.isEmpty) return const [];

      final rows =
          (standings.first as Map<String, dynamic>)['ConstructorStandings']
              as List<dynamic>;
      return rows
          .map((e) => ConstructorStanding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
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
