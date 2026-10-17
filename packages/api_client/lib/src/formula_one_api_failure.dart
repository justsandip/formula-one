/// {@template formula_one_api_failure}
/// Base type for every error thrown by the Formula One API client.
/// {@endtemplate}
sealed class FormulaOneApiFailure implements Exception {
  /// {@macro formula_one_api_failure}
  const FormulaOneApiFailure(this.message, {this.cause});

  /// Human readable description of the failure.
  final String message;

  /// The underlying error, if any (e.g. a `DioException`).
  final Object? cause;

  @override
  String toString() {
    final name = switch (this) {
      FormulaOneNetworkFailure() => 'FormulaOneNetworkFailure',
      FormulaOneHttpFailure() => 'FormulaOneHttpFailure',
      FormulaOneMalformedResponseFailure() =>
        'FormulaOneMalformedResponseFailure',
      FormulaOneUnknownFailure() => 'FormulaOneUnknownFailure',
      FormulaOneDeserializationFailure() => 'FormulaOneDeserializationFailure',
    };
    return '$name: $message';
  }
}

/// {@template formula_one_network_failure}
/// Thrown when no response was received: offline, DNS failure, timeout.
/// {@endtemplate}
final class FormulaOneNetworkFailure extends FormulaOneApiFailure {
  /// {@macro formula_one_network_failure}
  const FormulaOneNetworkFailure(super.message, {super.cause});
}

/// {@template formula_one_http_failure}
/// Thrown when the server answered with a non-2xx status.
/// {@endtemplate}
final class FormulaOneHttpFailure extends FormulaOneApiFailure {
  /// {@macro formula_one_http_failure}
  const FormulaOneHttpFailure(
    super.message, {
    required this.statusCode,
    super.cause,
  });

  /// HTTP status code of the response.
  final int? statusCode;
}

/// {@template formula_one_malformed_response_failure}
/// Thrown when the body is empty, not JSON, or not shaped as expected.
/// {@endtemplate}
final class FormulaOneMalformedResponseFailure extends FormulaOneApiFailure {
  /// {@macro formula_one_malformed_response_failure}
  const FormulaOneMalformedResponseFailure(super.message, {super.cause});
}

/// {@template formula_one_unknown_failure}
/// Thrown for any failure the client did not anticipate.
/// {@endtemplate}
final class FormulaOneUnknownFailure extends FormulaOneApiFailure {
  /// {@macro formula_one_unknown_failure}
  const FormulaOneUnknownFailure(super.message, {super.cause});
}

/// {@template formula_one_deserialization_failure}
/// Thrown when an error occurs while deserializing the response body.
/// {@endtemplate}
final class FormulaOneDeserializationFailure extends FormulaOneApiFailure {
  /// {@macro formula_one_deserialization_failure}
  const FormulaOneDeserializationFailure(super.message, {super.cause});
}
