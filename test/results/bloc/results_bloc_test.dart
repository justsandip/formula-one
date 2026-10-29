// ignore_for_file: document_ignores, prefer_const_constructors

import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/results/results.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

void main() {
  group('ResultsBloc', () {
    late FormulaOneRepository repository;

    const driver = Driver(
      id: 'norris',
      permanentNumber: '4',
      code: 'NOR',
      givenName: 'Lando',
      familyName: 'Norris',
      nationality: 'British',
    );
    const constructor = Constructor(
      id: 'mclaren',
      name: 'McLaren',
      nationality: 'British',
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

    final round17 = RaceResults(
      race: buildRace(round: 17, startsAt: DateTime(2020, 3, 15, 12)),
      results: const [raceResult],
    );
    final round16 = RaceResults(
      race: buildRace(round: 16, startsAt: DateTime(2020, 3, 8, 12)),
      results: const [raceResult],
    );
    const offline = FormulaOneNetworkFailure('offline');

    setUp(() {
      repository = _MockFormulaOneRepository();
    });

    ResultsBloc buildBloc() => ResultsBloc(formulaOneRepository: repository);

    test('initial state is ResultsState()', () {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      expect(bloc.state, const ResultsState());
    });

    group('latest race (round is null)', () {
      blocTest<ResultsBloc, ResultsState>(
        'emits [loading, success] with the latest race',
        setUp: () {
          when(() => repository.getLatestRaceResults())
              .thenAnswer((_) async => round17);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested()),
        expect: () => [
          const ResultsState(status: ResultsStatus.loading),
          ResultsState(status: ResultsStatus.success, raceResults: round17),
        ],
        verify: (_) {
          verify(() => repository.getLatestRaceResults()).called(1);
          verifyNever(
            () => repository.getRaceResults(round: any(named: 'round')),
          );
        },
      );

      blocTest<ResultsBloc, ResultsState>(
        'emits [loading, empty] when the season has no results yet',
        setUp: () {
          when(() => repository.getLatestRaceResults())
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested()),
        expect: () => const [
          ResultsState(status: ResultsStatus.loading),
          ResultsState(status: ResultsStatus.empty),
        ],
      );

      blocTest<ResultsBloc, ResultsState>(
        'drops the results of a specific round when the latest is requested',
        setUp: () {
          when(() => repository.getLatestRaceResults())
              .thenAnswer((_) async => round17);
        },
        seed: () => ResultsState(
          status: ResultsStatus.success,
          raceResults: round17,
          round: 17,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested()),
        expect: () => [
          const ResultsState(status: ResultsStatus.loading),
          ResultsState(status: ResultsStatus.success, raceResults: round17),
        ],
      );
    });

    group('specific round', () {
      blocTest<ResultsBloc, ResultsState>(
        'emits [loading, success] for the requested round',
        setUp: () {
          when(() => repository.getRaceResults(round: 17))
              .thenAnswer((_) async => round17);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested(round: 17)),
        expect: () => [
          const ResultsState(status: ResultsStatus.loading, round: 17),
          ResultsState(
            status: ResultsStatus.success,
            raceResults: round17,
            round: 17,
          ),
        ],
        verify: (_) {
          verify(() => repository.getRaceResults(round: 17)).called(1);
          verifyNever(() => repository.getLatestRaceResults());
        },
      );

      blocTest<ResultsBloc, ResultsState>(
        'emits [loading, empty] when the race has not been run',
        setUp: () {
          when(() => repository.getRaceResults(round: 18))
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested(round: 18)),
        expect: () => const [
          ResultsState(status: ResultsStatus.loading, round: 18),
          ResultsState(status: ResultsStatus.empty, round: 18),
        ],
      );

      blocTest<ResultsBloc, ResultsState>(
        'keeps the results while the same round reloads',
        setUp: () {
          when(() => repository.getRaceResults(round: 17))
              .thenAnswer((_) async => round17);
        },
        seed: () => ResultsState(
          status: ResultsStatus.success,
          raceResults: round17,
          round: 17,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested(round: 17)),
        expect: () => [
          ResultsState(
            status: ResultsStatus.loading,
            raceResults: round17,
            round: 17,
          ),
          ResultsState(
            status: ResultsStatus.success,
            raceResults: round17,
            round: 17,
          ),
        ],
      );

      blocTest<ResultsBloc, ResultsState>(
        'drops the results when another round is requested',
        setUp: () {
          when(() => repository.getRaceResults(round: 16))
              .thenAnswer((_) async => round16);
        },
        seed: () => ResultsState(
          status: ResultsStatus.success,
          raceResults: round17,
          round: 17,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested(round: 16)),
        expect: () => [
          const ResultsState(status: ResultsStatus.loading, round: 16),
          ResultsState(
            status: ResultsStatus.success,
            raceResults: round16,
            round: 16,
          ),
        ],
      );

      blocTest<ResultsBloc, ResultsState>(
        'ignores the result of a request replaced by a newer one',
        setUp: () {
          when(() => repository.getRaceResults(round: 16))
              .thenAnswer((_) async {
                await Future<void>.delayed(const Duration(milliseconds: 50));
                return round16;
              });
          when(() => repository.getRaceResults(round: 17))
              .thenAnswer((_) async => round17);
        },
        build: buildBloc,
        act: (bloc) => bloc
          ..add(ResultsRequested(round: 16))
          ..add(ResultsRequested(round: 17)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const ResultsState(status: ResultsStatus.loading, round: 16),
          const ResultsState(status: ResultsStatus.loading, round: 17),
          ResultsState(
            status: ResultsStatus.success,
            raceResults: round17,
            round: 17,
          ),
        ],
      );
    });

    group('failures', () {
      blocTest<ResultsBloc, ResultsState>(
        'emits [loading, failure] when the repository throws an api failure',
        setUp: () {
          when(() => repository.getRaceResults(round: 17))
              .thenAnswer((_) async => throw offline);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested(round: 17)),
        expect: () => const [
          ResultsState(status: ResultsStatus.loading, round: 17),
          ResultsState(
            status: ResultsStatus.failure,
            round: 17,
            failure: offline,
          ),
        ],
      );

      blocTest<ResultsBloc, ResultsState>(
        'keeps the results when a reload of the same round fails',
        setUp: () {
          when(() => repository.getRaceResults(round: 17))
              .thenAnswer((_) async => throw offline);
        },
        seed: () => ResultsState(
          status: ResultsStatus.success,
          raceResults: round17,
          round: 17,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(ResultsRequested(round: 17)),
        expect: () => [
          ResultsState(
            status: ResultsStatus.loading,
            raceResults: round17,
            round: 17,
          ),
          ResultsState(
            status: ResultsStatus.failure,
            raceResults: round17,
            round: 17,
            failure: offline,
          ),
        ],
      );

      blocTest<ResultsBloc, ResultsState>(
        'reports unexpected errors and emits an unknown failure',
        setUp: () {
          when(() => repository.getLatestRaceResults())
              .thenAnswer((_) async => throw StateError('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ResultsRequested()),
        expect: () => [
          const ResultsState(status: ResultsStatus.loading),
          isA<ResultsState>()
              .having((s) => s.status, 'status', ResultsStatus.failure)
              .having(
                (s) => s.failure,
                'failure',
                isA<FormulaOneUnknownFailure>(),
              ),
        ],
        errors: () => [isA<StateError>()],
      );
    });
  });

  group('ResultsRequested', () {
    test('defaults to the latest race', () {
      expect(const ResultsRequested().round, isNull);
    });

    test('supports value equality', () {
      expect(
        const ResultsRequested(round: 17),
        const ResultsRequested(round: 17),
      );
      expect(
        const ResultsRequested(round: 17),
        isNot(const ResultsRequested()),
      );
    });
  });

  group('ResultsState', () {
    test('supports value equality', () {
      expect(const ResultsState(), const ResultsState());
    });

    test('differs when a field differs', () {
      expect(
        const ResultsState(),
        isNot(const ResultsState(status: ResultsStatus.loading)),
      );
      expect(const ResultsState(), isNot(const ResultsState(round: 17)));
      expect(
        const ResultsState(),
        isNot(const ResultsState(failure: FormulaOneNetworkFailure('x'))),
      );
    });
  });
}
