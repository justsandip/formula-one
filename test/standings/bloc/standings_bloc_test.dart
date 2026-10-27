// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/standings/standings.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

void main() {
  group('StandingsBloc', () {
    late FormulaOneRepository repository;

    final drivers = sampleDriverStandings();
    final constructors = sampleConstructorStandings();
    const offline = FormulaOneNetworkFailure('offline');

    setUp(() {
      repository = _MockFormulaOneRepository();
    });

    void stubSeason(
      String season, {
      List<DriverStanding>? drivers,
      List<ConstructorStanding>? constructors,
    }) {
      when(() => repository.getDriverStandings(season: season))
          .thenAnswer((_) async => drivers ?? const []);
      when(() => repository.getConstructorStandings(season: season))
          .thenAnswer((_) async => constructors ?? const []);
    }

    StandingsBloc buildBloc() =>
        StandingsBloc(formulaOneRepository: repository);

    test('initial state is StandingsState()', () {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      expect(bloc.state, const StandingsState());
    });

    blocTest<StandingsBloc, StandingsState>(
      'emits [loading, success] with both tables for the current season',
      setUp: () =>
          stubSeason('current', drivers: drivers, constructors: constructors),
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested()),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading),
        StandingsState(
          status: StandingsStatus.success,
          drivers: drivers,
          constructors: constructors,
        ),
      ],
      verify: (_) {
        verify(() => repository.getDriverStandings(season: 'current'))
            .called(1);
        verify(() => repository.getConstructorStandings(season: 'current'))
            .called(1);
      },
    );

    blocTest<StandingsBloc, StandingsState>(
      'emits [loading, success] for a given season',
      setUp: () =>
          stubSeason('2025', drivers: drivers, constructors: constructors),
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested(season: '2025')),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading, season: '2025'),
        StandingsState(
          status: StandingsStatus.success,
          drivers: drivers,
          constructors: constructors,
          season: '2025',
        ),
      ],
    );

    blocTest<StandingsBloc, StandingsState>(
      'keeps the tables while the same season reloads',
      setUp: () =>
          stubSeason('current', drivers: drivers, constructors: constructors),
      seed: () => StandingsState(
        status: StandingsStatus.success,
        drivers: drivers,
        constructors: constructors,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested()),
      expect: () => [
        StandingsState(
          status: StandingsStatus.loading,
          drivers: drivers,
          constructors: constructors,
        ),
        StandingsState(
          status: StandingsStatus.success,
          drivers: drivers,
          constructors: constructors,
        ),
      ],
    );

    blocTest<StandingsBloc, StandingsState>(
      'drops the tables when another season is requested',
      setUp: () => stubSeason('2025'),
      seed: () => StandingsState(
        status: StandingsStatus.success,
        drivers: drivers,
        constructors: constructors,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested(season: '2025')),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading, season: '2025'),
        const StandingsState(status: StandingsStatus.success, season: '2025'),
      ],
    );

    blocTest<StandingsBloc, StandingsState>(
      'emits [loading, failure] when the drivers request fails',
      setUp: () {
        when(() => repository.getDriverStandings(season: 'current'))
            .thenAnswer((_) async => throw offline);
        when(() => repository.getConstructorStandings(season: 'current'))
            .thenAnswer((_) async => constructors);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested()),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading),
        const StandingsState(status: StandingsStatus.failure, failure: offline),
      ],
    );

    blocTest<StandingsBloc, StandingsState>(
      'emits [loading, failure] when the constructors request fails',
      setUp: () {
        const failure = FormulaOneHttpFailure('boom', statusCode: 500);
        when(() => repository.getDriverStandings(season: 'current'))
            .thenAnswer((_) async => drivers);
        when(() => repository.getConstructorStandings(season: 'current'))
            .thenAnswer((_) async => throw failure);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested()),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading),
        isA<StandingsState>()
            .having((s) => s.status, 'status', StandingsStatus.failure)
            .having((s) => s.failure, 'failure', isA<FormulaOneHttpFailure>()),
      ],
    );

    blocTest<StandingsBloc, StandingsState>(
      'keeps the tables when a reload of the same season fails',
      setUp: () {
        when(() => repository.getDriverStandings(season: 'current'))
            .thenAnswer((_) async => throw offline);
        when(() => repository.getConstructorStandings(season: 'current'))
            .thenAnswer((_) async => constructors);
      },
      seed: () => StandingsState(
        status: StandingsStatus.success,
        drivers: drivers,
        constructors: constructors,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested()),
      expect: () => [
        StandingsState(
          status: StandingsStatus.loading,
          drivers: drivers,
          constructors: constructors,
        ),
        StandingsState(
          status: StandingsStatus.failure,
          drivers: drivers,
          constructors: constructors,
          failure: offline,
        ),
      ],
    );

    blocTest<StandingsBloc, StandingsState>(
      'reports unexpected errors and emits an unknown failure',
      setUp: () {
        when(() => repository.getDriverStandings(season: 'current'))
            .thenAnswer((_) async => throw StateError('boom'));
        when(() => repository.getConstructorStandings(season: 'current'))
            .thenAnswer((_) async => constructors);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const StandingsRequested()),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading),
        isA<StandingsState>()
            .having((s) => s.status, 'status', StandingsStatus.failure)
            .having(
              (s) => s.failure,
              'failure',
              isA<FormulaOneUnknownFailure>(),
            ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<StandingsBloc, StandingsState>(
      'ignores the result of a request replaced by a newer one',
      setUp: () {
        when(() => repository.getDriverStandings(season: '2024'))
            .thenAnswer((_) async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              return drivers;
            });
        when(() => repository.getConstructorStandings(season: '2024'))
            .thenAnswer((_) async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              return constructors;
            });
        stubSeason('2025');
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const StandingsRequested(season: '2024'))
        ..add(const StandingsRequested(season: '2025')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const StandingsState(status: StandingsStatus.loading, season: '2024'),
        const StandingsState(status: StandingsStatus.loading, season: '2025'),
        const StandingsState(status: StandingsStatus.success, season: '2025'),
      ],
    );
  });

  group('StandingsRequested', () {
    test('defaults to the current season', () {
      expect(const StandingsRequested().season, 'current');
    });

    test('supports value equality', () {
      expect(
        const StandingsRequested(season: '2025'),
        const StandingsRequested(season: '2025'),
      );
      expect(
        const StandingsRequested(season: '2025'),
        isNot(const StandingsRequested()),
      );
    });
  });

  group('StandingsState', () {
    test('supports value equality', () {
      expect(const StandingsState(), const StandingsState());
    });

    test('differs when a field differs', () {
      expect(
        const StandingsState(),
        isNot(const StandingsState(status: StandingsStatus.loading)),
      );
      expect(
        const StandingsState(),
        isNot(const StandingsState(season: '2025')),
      );
      expect(
        const StandingsState(),
        isNot(const StandingsState(failure: FormulaOneNetworkFailure('x'))),
      );
    });
  });
}
