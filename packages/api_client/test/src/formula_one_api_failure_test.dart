// ignore_for_file: document_ignores, prefer_const_constructors
import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('FormulaOneApiFailure', () {
    final cause = StateError('boom');

    test('FormulaOneNetworkFailure keeps message and cause', () {
      final failure = FormulaOneNetworkFailure('offline', cause: cause);

      expect(failure, isA<FormulaOneApiFailure>());
      expect(failure, isA<Exception>());
      expect(failure.message, 'offline');
      expect(failure.cause, cause);
      expect(failure.toString(), 'FormulaOneNetworkFailure: offline');
    });

    test('FormulaOneHttpFailure keeps status code', () {
      final failure = FormulaOneHttpFailure(
        'not found',
        statusCode: 404,
        cause: cause,
      );

      expect(failure.message, 'not found');
      expect(failure.statusCode, 404);
      expect(failure.cause, cause);
      expect(failure.toString(), 'FormulaOneHttpFailure: not found');
    });

    test('FormulaOneMalformedResponseFailure keeps message', () {
      final failure = FormulaOneMalformedResponseFailure('empty');

      expect(failure.message, 'empty');
      expect(failure.cause, isNull);
      expect(
        failure.toString(),
        'FormulaOneMalformedResponseFailure: empty',
      );
    });

    test('FormulaOneUnknownFailure keeps message and cause', () {
      final failure = FormulaOneUnknownFailure('???', cause: cause);

      expect(failure.message, '???');
      expect(failure.cause, cause);
      expect(failure.toString(), 'FormulaOneUnknownFailure: ???');
    });

    test('FormulaOneDeserializationFailure keeps message and cause', () {
      final failure = FormulaOneDeserializationFailure(
        'bad shape',
        cause: cause,
      );

      expect(failure.message, 'bad shape');
      expect(failure.cause, cause);
      expect(
        failure.toString(),
        'FormulaOneDeserializationFailure: bad shape',
      );
    });
  });
}
