import 'package:api_client/api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../helpers/standings_fixtures.dart';

class _MockFormulaOneApiClient extends Mock implements FormulaOneApiClient {}

void main() {
  group('StandingsResource', () {
    late FormulaOneApiClient apiClient;
    late StandingsResource resource;

    setUp(() {
      apiClient = _MockFormulaOneApiClient();
      resource = StandingsResource(apiClient: apiClient);
    });

    group('getDriverStandings', () {
      const currentPath = '/current/driverStandings.json';

      test(
        'requests the current season by default and parses the rows',
        () async {
          when(() => apiClient.get(currentPath)).thenAnswer(
            (_) async => driverStandingsBody([
              driverStandingJson(),
              driverStandingJson(position: '2', points: '371', wins: '5'),
            ]),
          );

          final standings = await resource.getDriverStandings();

          expect(standings.map((s) => s.position), [1, 2]);
          expect(standings.first.points, 408);
          expect(standings.first.driver.code, 'NOR');
          verify(() => apiClient.get(currentPath)).called(1);
        },
      );

      test('requests the given season', () async {
        when(
          () => apiClient.get('/2025/driverStandings.json'),
        ).thenAnswer((_) async => driverStandingsBody([driverStandingJson()]));

        await resource.getDriverStandings(season: '2025');

        verify(() => apiClient.get('/2025/driverStandings.json')).called(1);
      });

      test('returns an empty list when there are no standings yet', () async {
        when(
          () => apiClient.get(currentPath),
        ).thenAnswer((_) async => driverStandingsBody([]));

        expect(await resource.getDriverStandings(), isEmpty);
      });

      test('lets client failures through unchanged', () async {
        const failure = FormulaOneNetworkFailure('offline');
        when(
          () => apiClient.get(currentPath),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          resource.getDriverStandings(),
          throwsA(same(failure)),
        );
      });

      test('throws FormulaOneDeserializationFailure without MRData', () async {
        when(
          () => apiClient.get(currentPath),
        ).thenAnswer((_) async => <String, dynamic>{});

        await expectLater(
          resource.getDriverStandings(),
          throwsA(
            isA<FormulaOneDeserializationFailure>()
                .having((e) => e.message, 'message', contains(currentPath))
                .having((e) => e.cause, 'cause', isNotNull),
          ),
        );
      });

      test(
        'throws FormulaOneDeserializationFailure when rows are not a list',
        () async {
          when(() => apiClient.get(currentPath)).thenAnswer(
            (_) async => <String, dynamic>{
              'MRData': <String, dynamic>{
                'StandingsTable': <String, dynamic>{
                  'StandingsLists': [
                    <String, dynamic>{'DriverStandings': 'nope'},
                  ],
                },
              },
            },
          );

          await expectLater(
            resource.getDriverStandings(),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure for an invalid row',
        () async {
          final broken = driverStandingJson()..remove('points');
          when(
            () => apiClient.get(currentPath),
          ).thenAnswer((_) async => driverStandingsBody([broken]));

          await expectLater(
            resource.getDriverStandings(),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure for a bad number',
        () async {
          when(() => apiClient.get(currentPath)).thenAnswer(
            (_) async =>
                driverStandingsBody([driverStandingJson(position: 'x')]),
          );

          await expectLater(
            resource.getDriverStandings(),
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
    });

    group('getConstructorStandings', () {
      const currentPath = '/current/constructorStandings.json';

      test(
        'requests the current season by default and parses the rows',
        () async {
          when(() => apiClient.get(currentPath)).thenAnswer(
            (_) async => constructorStandingsBody([
              constructorStandingJson(),
              constructorStandingJson(position: '2', points: '600', wins: '6'),
            ]),
          );

          final standings = await resource.getConstructorStandings();

          expect(standings.map((s) => s.position), [1, 2]);
          expect(standings.first.points, 800);
          expect(standings.first.constructor.id, 'mclaren');
          verify(() => apiClient.get(currentPath)).called(1);
        },
      );

      test('requests the given season', () async {
        when(() => apiClient.get('/2025/constructorStandings.json')).thenAnswer(
          (_) async => constructorStandingsBody([constructorStandingJson()]),
        );

        await resource.getConstructorStandings(season: '2025');

        verify(
          () => apiClient.get('/2025/constructorStandings.json'),
        ).called(1);
      });

      test('returns an empty list when there are no standings yet', () async {
        when(
          () => apiClient.get(currentPath),
        ).thenAnswer((_) async => constructorStandingsBody([]));

        expect(await resource.getConstructorStandings(), isEmpty);
      });

      test('lets client failures through unchanged', () async {
        const failure = FormulaOneHttpFailure('boom', statusCode: 500);
        when(
          () => apiClient.get(currentPath),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          resource.getConstructorStandings(),
          throwsA(same(failure)),
        );
      });

      test('throws FormulaOneDeserializationFailure without MRData', () async {
        when(
          () => apiClient.get(currentPath),
        ).thenAnswer((_) async => <String, dynamic>{});

        await expectLater(
          resource.getConstructorStandings(),
          throwsA(
            isA<FormulaOneDeserializationFailure>()
                .having((e) => e.message, 'message', contains(currentPath))
                .having((e) => e.cause, 'cause', isNotNull),
          ),
        );
      });

      test(
        'throws FormulaOneDeserializationFailure when rows are not a list',
        () async {
          when(() => apiClient.get(currentPath)).thenAnswer(
            (_) async => <String, dynamic>{
              'MRData': <String, dynamic>{
                'StandingsTable': <String, dynamic>{
                  'StandingsLists': [
                    <String, dynamic>{'ConstructorStandings': 'nope'},
                  ],
                },
              },
            },
          );

          await expectLater(
            resource.getConstructorStandings(),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneDeserializationFailure for an invalid row',
        () async {
          final broken = constructorStandingJson()..remove('Constructor');
          when(
            () => apiClient.get(currentPath),
          ).thenAnswer((_) async => constructorStandingsBody([broken]));

          await expectLater(
            resource.getConstructorStandings(),
            throwsA(isA<FormulaOneDeserializationFailure>()),
          );
        },
      );
    });
  });
}
