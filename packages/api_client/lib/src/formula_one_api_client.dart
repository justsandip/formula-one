import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';

/// {@template formula_one_api_client}
/// A Dart API Client for F1 Rest APIs
/// Source: https://api.jolpi.ca/ergast/
/// {@endtemplate}
class FormulaOneApiClient {
  /// {@macro formula_one_api_client}
  FormulaOneApiClient({String baseUrl = defaultBaseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  /// Base URL of the Jolpica Ergast-compatible API.
  static const defaultBaseUrl = 'https://api.jolpi.ca/ergast/f1';

  final Dio _dio;

  /// Season Races endpoints.
  late final RacesResource racesResource = RacesResource(apiClient: this);

  /// Season Standings endpoints.
  late final StandingsResource standingsResource = StandingsResource(
    apiClient: this,
  );

  /// Race Results endpoints.
  late final ResultsResource resultsResource = ResultsResource(apiClient: this);

  /// Performs a GET request to [path] and returns the decoded JSON body.
  ///
  /// [path] is relative to the client's base URL and starts with `/`, e.g.
  /// `/current.json`. Optional [queryParameters] are appended to the URL.
  ///
  /// Throws a:
  /// - [FormulaOneNetworkFailure] if no response was received (offline, DNS
  ///   failure, timeout).
  /// - [FormulaOneHttpFailure] if the server responded with a non-2xx status.
  /// - [FormulaOneMalformedResponseFailure] if the response body is empty.
  /// - [FormulaOneUnknownFailure] for any other unexpected error.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_toFailure(path, error), stackTrace);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FormulaOneUnknownFailure('Unexpected error at $path', cause: error),
        stackTrace,
      );
    }
    final data = response.data;
    if (data == null) {
      throw FormulaOneMalformedResponseFailure('Empty body from $path');
    }
    return data;
  }

  FormulaOneApiFailure _toFailure(String path, DioException error) {
    final message = error.message ?? 'Request to $path failed';
    return switch (error.type) {
      DioExceptionType.badResponse => FormulaOneHttpFailure(
        message,
        statusCode: error.response?.statusCode,
        cause: error,
      ),
      // Timeouts and connection errors, cancel, bad-certificate and unknown
      _ => FormulaOneNetworkFailure(message, cause: error),
    };
  }
}
