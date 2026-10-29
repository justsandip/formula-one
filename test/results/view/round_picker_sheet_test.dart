// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/results/results.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

class _MockScheduleBloc extends MockBloc<ScheduleEvent, ScheduleState>
    implements ScheduleBloc;

void main() {
  group('RoundPickerSheet', () {
    late ScheduleBloc bloc;

    // Rounds 1 and 2 are done; round 3 is still to come.
    final races = [
      buildRace(startsAt: DateTime(2020, 3, 15, 12)),
      buildRace(round: 2, startsAt: DateTime(2020, 3, 22, 12)),
      buildRace(
        round: 3,
        startsAt: DateTime.now().add(const Duration(days: 30)),
      ),
    ];

    setUp(() {
      bloc = _MockScheduleBloc();
    });

    Future<void> pumpSheet(
      WidgetTester tester,
      ScheduleState state, {
      int selectedRound = 2,
    }) {
      when(() => bloc.state).thenReturn(state);
      return tester.pumpApp(
        Scaffold(body: RoundPickerSheet(selectedRound: selectedRound)),
        scheduleBloc: bloc,
      );
    }

    testWidgets('shows the title and a progress indicator while loading', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        const ScheduleState(status: ScheduleStatus.loading),
      );

      expect(find.text('CHOOSE A RACE'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a progress indicator when initial', (tester) async {
      await pumpSheet(tester, const ScheduleState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('keeps the races while reloading', (tester) async {
      await pumpSheet(
        tester,
        ScheduleState(status: ScheduleStatus.loading, races: races),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('RACE 1 GRAND PRIX'), findsOneWidget);
    });

    testWidgets('lists only completed races, newest first', (tester) async {
      await pumpSheet(
        tester,
        ScheduleState(status: ScheduleStatus.success, races: races),
      );

      expect(find.text('R01'), findsOneWidget);
      expect(find.text('R02'), findsOneWidget);
      expect(find.text('City 1 · 15 Mar'), findsOneWidget);
      expect(find.text('RACE 3 GRAND PRIX'), findsNothing);
      expect(
        tester.getTopLeft(find.text('RACE 2 GRAND PRIX')).dy,
        lessThan(tester.getTopLeft(find.text('RACE 1 GRAND PRIX')).dy),
      );
    });

    testWidgets('marks the most recent race as latest', (tester) async {
      await pumpSheet(
        tester,
        ScheduleState(status: ScheduleStatus.success, races: races),
      );

      expect(find.text('LATEST'), findsOneWidget);
    });

    testWidgets('marks the selected round with a check', (tester) async {
      await pumpSheet(
        tester,
        ScheduleState(status: ScheduleStatus.success, races: races),
        selectedRound: 1,
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows a message when no race has been run', (tester) async {
      await pumpSheet(
        tester,
        ScheduleState(status: ScheduleStatus.success, races: [races.last]),
      );

      expect(find.text('No completed races yet'), findsOneWidget);
    });

    testWidgets('shows the failure view and retries', (tester) async {
      await pumpSheet(
        tester,
        const ScheduleState(
          status: ScheduleStatus.failure,
          failure: FormulaOneNetworkFailure('offline'),
        ),
      );

      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const ScheduleRequested())).called(1);
    });
  });

  group('RoundPickerSheet.show', () {
    late FormulaOneRepository repository;

    final races = [
      buildRace(startsAt: DateTime(2020, 3, 15, 12)),
      buildRace(round: 2, startsAt: DateTime(2020, 3, 22, 12)),
    ];

    setUp(() {
      repository = _MockFormulaOneRepository();
      when(() => repository.getRaces(season: null))
          .thenAnswer((_) async => races);
    });

    Future<void> pumpOpener(WidgetTester tester, void Function(int?) onResult) {
      return tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => onResult(
                await RoundPickerSheet.show(context, selectedRound: 2),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        formulaOneRepository: repository,
      );
    }

    testWidgets('loads the schedule and returns the tapped round', (
      tester,
    ) async {
      int? picked;
      await pumpOpener(tester, (round) => picked = round);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('CHOOSE A RACE'), findsOneWidget);
      verify(() => repository.getRaces(season: null)).called(1);

      await tester.tap(find.text('RACE 1 GRAND PRIX'));
      await tester.pumpAndSettle();

      expect(picked, 1);
      expect(find.text('CHOOSE A RACE'), findsNothing);
    });

    testWidgets('returns null when dismissed', (tester) async {
      var called = false;
      int? picked = -1;
      await pumpOpener(tester, (round) {
        called = true;
        picked = round;
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // Tap the barrier above the sheet.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(picked, isNull);
    });
  });
}
