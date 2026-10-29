// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:api_client/api_client.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFormulaOneApiClient extends Mock implements FormulaOneApiClient {}

class _MockRacesResource extends Mock implements RacesResource {}

class _MockStandingsResource extends Mock implements StandingsResource {}

class _MockResultsResource extends Mock implements ResultsResource {}

void main() {
  group('FormulaOneRepository', () {
    late FormulaOneApiClient apiClient;
    late RacesResource racesResource;
    late StandingsResource standingsResource;
    late ResultsResource resultsResource;
    late FormulaOneRepository repository;

    final race = Race(
      round: '1',
      name: 'Australian Grand Prix',
      circuit: const Circuit(
        id: 'albert_park',
        name: 'Albert Park Grand Prix Circuit',
        location: 'Melbourne',
        country: 'Australia',
        latitude: -37.8497,
        longitude: 144.968,
      ),
      startsAt: DateTime.utc(2026, 3, 8, 4),
    );

    const constructor = Constructor(
      id: 'mclaren',
      name: 'McLaren',
      nationality: 'British',
    );
    const driver = Driver(
      id: 'norris',
      permanentNumber: '4',
      code: 'NOR',
      givenName: 'Lando',
      familyName: 'Norris',
      nationality: 'British',
    );
    const driverStanding = DriverStanding(
      position: 1,
      points: 408,
      wins: 7,
      driver: driver,
      constructors: [constructor],
    );
    const constructorStanding = ConstructorStanding(
      position: 1,
      points: 800,
      wins: 14,
      constructor: constructor,
    );
    const raceResult = RaceResult(
      position: 1,
      positionText: '1',
      points: 25,
      grid: 1,
      laps: 57,
      status: 'Finished',
      driver: driver,
      constructor: constructor,
      time: '1:42:06.304',
    );
    final raceResults = RaceResults(race: race, results: const [raceResult]);

    setUp(() {
      apiClient = _MockFormulaOneApiClient();
      racesResource = _MockRacesResource();
      standingsResource = _MockStandingsResource();
      resultsResource = _MockResultsResource();
      when(() => apiClient.racesResource).thenReturn(racesResource);
      when(() => apiClient.standingsResource).thenReturn(standingsResource);
      when(() => apiClient.resultsResource).thenReturn(resultsResource);
      repository = FormulaOneRepository(apiClient: apiClient);
    });

    group('getRaces', () {
      test('returns the current season races by default', () async {
        when(
          () => racesResource.getRaces(season: null),
        ).thenAnswer((_) async => [race]);

        expect(await repository.getRaces(), [race]);
        verify(() => racesResource.getRaces(season: null)).called(1);
      });

      test('passes the requested season through', () async {
        when(
          () => racesResource.getRaces(season: 2025),
        ).thenAnswer((_) async => [race]);

        expect(await repository.getRaces(season: 2025), [race]);
        verify(() => racesResource.getRaces(season: 2025)).called(1);
      });

      test('lets api failures through unchanged', () async {
        const failure = FormulaOneNetworkFailure('offline');
        when(
          () => racesResource.getRaces(season: null),
        ).thenAnswer((_) async => throw failure);

        await expectLater(repository.getRaces(), throwsA(same(failure)));
      });
    });

    group('getDriverStandings', () {
      test('returns the current season standings by default', () async {
        when(
          () => standingsResource.getDriverStandings(season: 'current'),
        ).thenAnswer((_) async => [driverStanding]);

        expect(await repository.getDriverStandings(), [driverStanding]);
        verify(
          () => standingsResource.getDriverStandings(season: 'current'),
        ).called(1);
      });

      test('passes the requested season through', () async {
        when(
          () => standingsResource.getDriverStandings(season: '2025'),
        ).thenAnswer((_) async => [driverStanding]);

        expect(await repository.getDriverStandings(season: '2025'), [
          driverStanding,
        ]);
        verify(
          () => standingsResource.getDriverStandings(season: '2025'),
        ).called(1);
      });

      test('lets api failures through unchanged', () async {
        const failure = FormulaOneHttpFailure('boom', statusCode: 500);
        when(
          () => standingsResource.getDriverStandings(season: 'current'),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          repository.getDriverStandings(),
          throwsA(same(failure)),
        );
      });
    });

    group('getConstructorStandings', () {
      test('returns the current season standings by default', () async {
        when(
          () => standingsResource.getConstructorStandings(season: 'current'),
        ).thenAnswer((_) async => [constructorStanding]);

        expect(await repository.getConstructorStandings(), [
          constructorStanding,
        ]);
        verify(
          () => standingsResource.getConstructorStandings(season: 'current'),
        ).called(1);
      });

      test('passes the requested season through', () async {
        when(
          () => standingsResource.getConstructorStandings(season: '2025'),
        ).thenAnswer((_) async => [constructorStanding]);

        expect(await repository.getConstructorStandings(season: '2025'), [
          constructorStanding,
        ]);
        verify(
          () => standingsResource.getConstructorStandings(season: '2025'),
        ).called(1);
      });

      test('lets api failures through unchanged', () async {
        const failure = FormulaOneDeserializationFailure('bad shape');
        when(
          () => standingsResource.getConstructorStandings(season: 'current'),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          repository.getConstructorStandings(),
          throwsA(same(failure)),
        );
      });
    });

    group('getRaceResults', () {
      test('returns the results of a round of the current season', () async {
        when(
          () => resultsResource.getRaceResults(round: 17, season: null),
        ).thenAnswer((_) async => raceResults);

        expect(await repository.getRaceResults(round: 17), raceResults);
        verify(
          () => resultsResource.getRaceResults(round: 17, season: null),
        ).called(1);
      });

      test('passes the requested season through', () async {
        when(
          () => resultsResource.getRaceResults(round: 17, season: 2025),
        ).thenAnswer((_) async => raceResults);

        expect(
          await repository.getRaceResults(round: 17, season: 2025),
          raceResults,
        );
        verify(
          () => resultsResource.getRaceResults(round: 17, season: 2025),
        ).called(1);
      });

      test('returns null when the race has not been run', () async {
        when(
          () => resultsResource.getRaceResults(round: 17, season: null),
        ).thenAnswer((_) async => null);

        expect(await repository.getRaceResults(round: 17), isNull);
      });

      test('lets api failures through unchanged', () async {
        const failure = FormulaOneNetworkFailure('offline');
        when(
          () => resultsResource.getRaceResults(round: 17, season: null),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          repository.getRaceResults(round: 17),
          throwsA(same(failure)),
        );
      });
    });

    group('getLatestRaceResults', () {
      test('returns the results of the most recent race', () async {
        when(
          () => resultsResource.getLatestRaceResults(),
        ).thenAnswer((_) async => raceResults);

        expect(await repository.getLatestRaceResults(), raceResults);
        verify(() => resultsResource.getLatestRaceResults()).called(1);
      });

      test('returns null when the season has no results yet', () async {
        when(
          () => resultsResource.getLatestRaceResults(),
        ).thenAnswer((_) async => null);

        expect(await repository.getLatestRaceResults(), isNull);
      });

      test('lets api failures through unchanged', () async {
        const failure = FormulaOneHttpFailure('boom', statusCode: 500);
        when(
          () => resultsResource.getLatestRaceResults(),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          repository.getLatestRaceResults(),
          throwsA(same(failure)),
        );
      });
    });
  });
}
