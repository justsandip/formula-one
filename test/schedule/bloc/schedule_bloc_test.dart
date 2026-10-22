// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFormulaOneRepository extends Mock implements FormulaOneRepository;

void main() {
  group('ScheduleBloc', () {
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

    setUp(() {
      repository = MockFormulaOneRepository();
    });

    ScheduleBloc buildBloc() => ScheduleBloc(formulaOneRepository: repository);

    test('initial state is ScheduleState()', () {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      expect(bloc.state, const ScheduleState());
    });

    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, success] for the current season',
      setUp: () {
        when(() => repository.getRaces(season: null))
            .thenAnswer((_) async => [race]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ScheduleRequested()),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading),
        ScheduleState(status: ScheduleStatus.success, races: [race]),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, success] for a given season',
      setUp: () {
        when(() => repository.getRaces(season: 2025))
            .thenAnswer((_) async => [race]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ScheduleRequested(season: 2025)),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading, season: 2025),
        ScheduleState(
          status: ScheduleStatus.success,
          races: [race],
          season: 2025,
        ),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'keeps the races while the same season reloads',
      setUp: () {
        when(() => repository.getRaces(season: null))
            .thenAnswer((_) async => [race]);
      },
      seed: () => ScheduleState(status: ScheduleStatus.success, races: [race]),
      build: buildBloc,
      act: (bloc) => bloc.add(const ScheduleRequested()),
      expect: () => [
        ScheduleState(status: ScheduleStatus.loading, races: [race]),
        ScheduleState(status: ScheduleStatus.success, races: [race]),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'drops the races when another season is requested',
      setUp: () {
        when(() => repository.getRaces(season: 2025))
            .thenAnswer((_) async => []);
      },
      seed: () => ScheduleState(status: ScheduleStatus.success, races: [race]),
      build: buildBloc,
      act: (bloc) => bloc.add(const ScheduleRequested(season: 2025)),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading, season: 2025),
        const ScheduleState(status: ScheduleStatus.success, season: 2025),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, failure] when the repository throws an api failure',
      setUp: () {
        when(() => repository.getRaces(season: null))
            .thenAnswer((_) async => throw _networkFailure);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ScheduleRequested()),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading),
        const ScheduleState(
          status: ScheduleStatus.failure,
          failure: _networkFailure,
        ),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'reports unexpected errors and emits an unknown failure',
      setUp: () {
        when(() => repository.getRaces(season: null))
            .thenAnswer((_) async => throw StateError('boom'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ScheduleRequested()),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading),
        isA<ScheduleState>()
            .having((s) => s.status, 'status', ScheduleStatus.failure)
            .having(
              (s) => s.failure,
              'failure',
              isA<FormulaOneUnknownFailure>(),
            ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'ignores the result of a request replaced by a newer one',
      setUp: () {
        when(() => repository.getRaces(season: 2024)).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return [race];
        });
        when(() => repository.getRaces(season: 2025))
            .thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const ScheduleRequested(season: 2024))
        ..add(const ScheduleRequested(season: 2025)),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading, season: 2024),
        const ScheduleState(status: ScheduleStatus.loading, season: 2025),
        const ScheduleState(status: ScheduleStatus.success, season: 2025),
      ],
    );
  });

  group('ScheduleRequested', () {
    test('supports value equality', () {
      expect(
        const ScheduleRequested(season: 2025),
        const ScheduleRequested(season: 2025),
      );
      expect(
        const ScheduleRequested(season: 2025),
        isNot(const ScheduleRequested()),
      );
    });
  });
}

const _networkFailure = FormulaOneNetworkFailure('offline');
