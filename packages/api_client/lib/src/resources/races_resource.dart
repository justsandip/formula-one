import 'package:api_client/api_client.dart';

/// {@template races_resource}
/// Access to the races endpoints (the season calendar).
/// {@endtemplate}
class RacesResource {
  /// {@macro races_resource}
  const RacesResource({required FormulaOneApiClient apiClient})
    : _apiClient = apiClient;

  final FormulaOneApiClient _apiClient;

  /// Fetches every race of [season], or of the current season when null.
  ///
  /// Throws a [FormulaOneApiFailure] if the request fails, or a
  /// [FormulaOneDeserializationFailure] if the response does not match
  /// the [Race] model.
  Future<List<Race>> getRaces({int? season}) async {
    final path = '/${season ?? 'current'}.json';
    final json = await _apiClient.get(path);
    try {
      final mrData = json['MRData'] as Map<String, dynamic>;
      final table = mrData['RaceTable'] as Map<String, dynamic>;
      final races = table['Races'] as List<dynamic>;
      return races
          .map((e) => Race.fromJson(e as Map<String, dynamic>))
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
