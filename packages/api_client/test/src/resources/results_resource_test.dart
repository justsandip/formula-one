// ignore_for_file: document_ignores, avoid_dynamic_calls

import 'package:api_client/api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../helpers/results_fixtures.dart';

class _MockFormulaOneApiClient extends Mock implements FormulaOneApiClient {}

void main() {
  group('ResultsResource', () {
    late FormulaOneApiClient apiClient;
    late ResultsResource resource;

    const limit = <String, dynamic>{'limit': 100};

    void stubGet(String path, Map<String, dynamic> body) {
      when(
        () => apiClient.get(path, queryParameters: limit),
      ).thenAnswer((_) async => body);
    }

    setUp(() {
      apiClient = _MockFormulaOneApiClient();
      resource = ResultsResource(apiClient: apiClient);
    });

    group('getRaceResults', () {
      const path = '/current/17/results.json';

      test(
        'requests the race of the current season with a limit of 100',
        () async {
          stubGet(path, raceResultsBody([raceResultJson()]));

          await resource.getRaceResults(round: 17);

          verify(() => apiClient.get(path, queryParameters: limit)).called(1);
        },
      );

      test('requests the given season', () async {
        stubGet('/2025/17/results.json', raceResultsBody([raceResultJson()]));

        await resource.getRaceResults(round: 17, season: 2025);

        verify(
          () => apiClient.get('/2025/17/results.json', queryParameters: limit),
        ).called(1);
      });

      test('returns the race with its results in order', () async {
        stubGet(
          path,
          raceResultsBody([
            raceResultJson(),
            raceResultJson(position: '2', positionText: '2', points: '18'),
          ]),
        );

        final raceResults = await resource.getRaceResults(round: 17);

        expect(raceResults, isNotNull);
        expect(raceResults!.race.name, 'Singapore Grand Prix');
        expect(raceResults.race.round, '17');
        expect(raceResults.results.map((r) => r.position), [1, 2]);
      });

      test('returns null when the race has not been run', () async {
        stubGet(path, emptyRaceResultsBody());

        expect(await resource.getRaceResults(round: 17), isNull);
      });

      test('lets client failures through unchanged', () async {
        const failure = FormulaOneNetworkFailure('offline');
        when(
          () => apiClient.get(path, queryParameters: limit),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          resource.getRaceResults(round: 17),
          throwsA(same(failure)),
        );
      });

      test(
        'throws FormulaOneDeserializationFailure when results are missing',
        () async {
          // 22 results exist on the server but only 2 came back.
          stubGet(
            path,
            raceResultsBody([
              raceResultJson(),
              raceResultJson(position: '2'),
            ], total: '22'),
          );

          await expectLater(
            resource.getRaceResults(round: 17),
            throwsA(
              isA<FormulaOneDeserializationFailure>()
                  .having((e) => e.message, 'message', contains(path))
                  .having((e) => e.cause, 'cause', isA<StateError>()),
            ),
          );
        },
      );

      test('throws FormulaOneDeserializationFailure without MRData', () async {
        stubGet(path, <String, dynamic>{});

        await expectLater(
          resource.getRaceResults(round: 17),
          throwsA(
            isA<FormulaOneDeserializationFailure>().having(
              (e) => e.cause,
              'cause',
              isNotNull,
            ),
          ),
        );
      });

      test(
        'throws FormulaOneDeserializationFailure when Results is not a list',
        () async {
          final body = raceResultsBody([raceResultJson()]);
          final races =
              (body['MRData'] as Map<String, dynamic>)['RaceTable']['Races']
                  as List<dynamic>;
          (races.first as Map<String, dynamic>)['Results'] = 'nope';
          stubGet(path, body);

          await expectLater(
            resource.getRaceResults(round: 17),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure for an invalid result row',
        () async {
          final broken = raceResultJson()..remove('points');
          stubGet(path, raceResultsBody([broken]));

          await expectLater(
            resource.getRaceResults(round: 17),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure when total is missing',
        () async {
          final body = raceResultsBody([raceResultJson()]);
          (body['MRData'] as Map<String, dynamic>).remove('total');
          stubGet(path, body);

          await expectLater(
            resource.getRaceResults(round: 17),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure when total is not a number',
        () async {
          stubGet(path, raceResultsBody([raceResultJson()], total: 'x'));

          await expectLater(
            resource.getRaceResults(round: 17),
            throwsA(
              isA<FormulaOneDeserializationFailure>().having(
                (e) => e.cause,
                'cause',
                isA<FormatException>(),
              ),
            ),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure for an invalid race',
        () async {
          final body = raceResultsBody([raceResultJson()]);
          final races =
              (body['MRData'] as Map<String, dynamic>)['RaceTable']['Races']
                  as List<dynamic>;
          (races.first as Map<String, dynamic>).remove('raceName');
          stubGet(path, body);

          await expectLater(
            resource.getRaceResults(round: 17),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );
    });

    group('getLatestRaceResults', () {
      const path = '/current/last/results.json';

      test('requests the last race with a limit of 100', () async {
        stubGet(path, raceResultsBody([raceResultJson()]));

        final raceResults = await resource.getLatestRaceResults();

        expect(raceResults?.race.name, 'Singapore Grand Prix');
        verify(() => apiClient.get(path, queryParameters: limit)).called(1);
      });

      test('returns null when the season has no results yet', () async {
        stubGet(path, emptyRaceResultsBody());

        expect(await resource.getLatestRaceResults(), isNull);
      });

      test('lets client failures through unchanged', () async {
        const failure = FormulaOneHttpFailure('boom', statusCode: 500);
        when(
          () => apiClient.get(path, queryParameters: limit),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          resource.getLatestRaceResults(),
          throwsA(same(failure)),
        );
      });

      test('wraps a malformed response', () async {
        stubGet(path, <String, dynamic>{});

        await expectLater(
          resource.getLatestRaceResults(),
          throwsA(isA<FormulaOneDeserializationFailure>()),
        );
      });
    });
  });
}
