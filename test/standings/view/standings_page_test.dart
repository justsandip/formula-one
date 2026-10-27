// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/standings/standings.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

class _MockStandingsBloc extends MockBloc<StandingsEvent, StandingsState>
    implements StandingsBloc;

void main() {
  group('StandingsPage', () {
    late FormulaOneRepository repository;

    setUp(() {
      repository = _MockFormulaOneRepository();
      when(() => repository.getDriverStandings(season: 'current'))
          .thenAnswer((_) async => []);
      when(() => repository.getConstructorStandings(season: 'current'))
          .thenAnswer((_) async => []);
    });

    testWidgets('renders StandingsView and requests both tables', (
      tester,
    ) async {
      await tester.pumpApp(
        const StandingsPage(),
        formulaOneRepository: repository,
      );
      await tester.pump();

      expect(find.byType(StandingsView), findsOneWidget);
      verify(() => repository.getDriverStandings(season: 'current')).called(1);
      verify(() => repository.getConstructorStandings(season: 'current'))
          .called(1);
    });

    testWidgets('route builds a StandingsPage', (tester) async {
      await tester.pumpApp(const Scaffold(), formulaOneRepository: repository);

      final context = tester.element(find.byType(Scaffold));
      Navigator.of(context).push(StandingsPage.route());
      await tester.pumpAndSettle();

      expect(find.byType(StandingsPage), findsOneWidget);
    });
  });

  group('StandingsView', () {
    late StandingsBloc bloc;

    setUp(() {
      bloc = _MockStandingsBloc();
    });

    Future<void> pumpView(WidgetTester tester, StandingsState state) {
      when(() => bloc.state).thenReturn(state);
      return tester.pumpApp(const StandingsView(), standingsBloc: bloc);
    }

    final drivers = sampleDriverStandings();
    final constructors = sampleConstructorStandings();

    testWidgets('shows a progress indicator when initial', (tester) async {
      await pumpView(tester, const StandingsState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(StandingsSuccess), findsNothing);
    });

    testWidgets('shows a progress indicator when loading without data', (
      tester,
    ) async {
      await pumpView(
        tester,
        const StandingsState(status: StandingsStatus.loading),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('keeps showing the tables while reloading', (tester) async {
      await pumpView(
        tester,
        StandingsState(
          status: StandingsStatus.loading,
          drivers: drivers,
          constructors: constructors,
        ),
      );

      expect(find.byType(StandingsSuccess), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows the tables on success', (tester) async {
      await pumpView(
        tester,
        StandingsState(
          status: StandingsStatus.success,
          drivers: drivers,
          constructors: constructors,
        ),
      );

      expect(find.byType(StandingsSuccess), findsOneWidget);
    });

    testWidgets('shows the failure view and retries the same season', (
      tester,
    ) async {
      await pumpView(
        tester,
        const StandingsState(
          status: StandingsStatus.failure,
          season: '2025',
          failure: FormulaOneNetworkFailure('offline'),
        ),
      );

      expect(find.byType(StandingsFailure), findsOneWidget);

      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(const StandingsRequested(season: '2025')))
          .called(1);
    });
  });
}
