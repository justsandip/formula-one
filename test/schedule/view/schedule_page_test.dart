import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one/widgets/widgets.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

class _MockScheduleBloc extends MockBloc<ScheduleEvent, ScheduleState>
    implements ScheduleBloc;

void main() {
  group('SchedulePage', () {
    late FormulaOneRepository repository;

    setUp(() {
      repository = _MockFormulaOneRepository();
      when(() => repository.getRaces()).thenAnswer((_) async => []);
    });

    testWidgets('renders ScheduleView and requests the schedule', (
      tester,
    ) async {
      await tester.pumpApp(
        const SchedulePage(),
        formulaOneRepository: repository,
      );
      await tester.pump();

      expect(find.byType(ScheduleView), findsOneWidget);
      verify(() => repository.getRaces()).called(1);
    });

    testWidgets('route builds a SchedulePage', (tester) async {
      await tester.pumpApp(const Scaffold(), formulaOneRepository: repository);

      final context = tester.element(find.byType(Scaffold));
      Navigator.of(context).push(SchedulePage.route());
      await tester.pumpAndSettle();

      expect(find.byType(SchedulePage), findsOneWidget);
    });
  });

  group('ScheduleView', () {
    late ScheduleBloc bloc;

    // Done races only, so no countdown timer is involved.
    final races = [
      buildRace(startsAt: DateTime(2020, 3, 1, 12)),
      buildRace(round: 2, startsAt: DateTime(2020, 3, 8, 12)),
    ];

    setUp(() {
      bloc = _MockScheduleBloc();
    });

    Future<void> pumpView(WidgetTester tester, ScheduleState state) {
      when(() => bloc.state).thenReturn(state);
      return tester.pumpApp(const ScheduleView(), scheduleBloc: bloc);
    }

    testWidgets('shows a progress indicator when initial', (tester) async {
      await pumpView(tester, const ScheduleState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ScheduleSuccess), findsNothing);
    });

    testWidgets('shows a progress indicator when loading without races', (
      tester,
    ) async {
      await pumpView(
        tester,
        const ScheduleState(status: ScheduleStatus.loading),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('keeps showing the races while reloading', (tester) async {
      await pumpView(
        tester,
        ScheduleState(status: ScheduleStatus.loading, races: races),
      );

      expect(find.byType(ScheduleSuccess), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows the races on success', (tester) async {
      await pumpView(
        tester,
        ScheduleState(status: ScheduleStatus.success, races: races),
      );

      expect(find.byType(ScheduleSuccess), findsOneWidget);
    });

    testWidgets('shows the failure view and retries the same season', (
      tester,
    ) async {
      await pumpView(
        tester,
        const ScheduleState(
          status: ScheduleStatus.failure,
          season: 2025,
          failure: FormulaOneNetworkFailure('offline'),
        ),
      );

      expect(find.byType(FormulaOneFailureView), findsOneWidget);

      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const ScheduleRequested(season: 2025))).called(1);
    });
  });
}
