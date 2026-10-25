import 'package:api_client/api_client.dart';

/// {@template standings_resource}
/// Access to the standings endpoints (driver and constructor).
/// {@endtemplate}
class StandingsResource {
  /// {@macro standings_resource}
  const StandingsResource({required FormulaOneApiClient apiClient})
    : _apiClient = apiClient;

  final FormulaOneApiClient _apiClient;

  /// Fetches the current standing for the Drivers' Championship
  /// for the [season]
  Future<List<DriverStanding>> getDriverStandings({
    String season = 'current',
  }) async {
    final path = '/$season/driverStandings.json';
    final json = await _apiClient.get(path);
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
    String season = 'current',
  }) async {
    final path = '/$season/constructorStandings.json';
    final json = await _apiClient.get(path);
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
