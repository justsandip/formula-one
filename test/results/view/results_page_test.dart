// ignore_for_file: avoid_redundant_argument_values, document_ignores,
// ignore_for_file: prefer_const_constructors

import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/results/results.dart';
import 'package:formula_one/widgets/formula_one_failure_view.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

class _MockResultsBloc extends MockBloc<ResultsEvent, ResultsState>
    implements ResultsBloc;

void main() {
  setUpAll(() => registerFallbackValue(ResultsRequested()));

  group('ResultsPage', () {
    late FormulaOneRepository repository;

    setUp(() {
      repository = _MockFormulaOneRepository();
      when(() => repository.getLatestRaceResults())
          .thenAnswer((_) async => null);
      when(() => repository.getRaceResults(round: 16))
          .thenAnswer((_) async => null);
    });

    testWidgets('renders ResultsView and requests the latest race', (
      tester,
    ) async {
      await tester.pumpApp(ResultsPage(), formulaOneRepository: repository);
      await tester.pump();
      await tester.pump();

      expect(find.byType(ResultsView), findsOneWidget);
      verify(() => repository.getLatestRaceResults()).called(1);
    });

    testWidgets('requests the given round', (tester) async {
      await tester.pumpApp(
        ResultsPage(round: 16),
        formulaOneRepository: repository,
      );
      await tester.pump();
      await tester.pump();

      verify(() => repository.getRaceResults(round: 16)).called(1);
      verifyNever(() => repository.getLatestRaceResults());
    });

    testWidgets('route builds a ResultsPage for the round with a back button', (
      tester,
    ) async {
      await tester.pumpApp(Scaffold(), formulaOneRepository: repository);

      final context = tester.element(find.byType(Scaffold));
      Navigator.of(context).push(ResultsPage.route(round: 16));
      await tester.pumpAndSettle();

      expect(find.byType(ResultsPage), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      verify(() => repository.getRaceResults(round: 16)).called(1);
    });
  });

  group('ResultsView', () {
    late ResultsBloc bloc;
    late FormulaOneRepository repository;

    final raceResults = buildRaceResults();

    setUp(() {
      bloc = _MockResultsBloc();
      repository = _MockFormulaOneRepository();
      when(() => repository.getRaces(season: null)).thenAnswer(
        (_) async => [
          buildRace(startsAt: DateTime(2020, 3, 15, 12)),
          buildRace(round: 16, startsAt: DateTime(2020, 3, 22, 12)),
          buildRace(round: 17, startsAt: DateTime(2020, 3, 29, 12)),
        ],
      );
    });

    Future<void> pumpView(WidgetTester tester, ResultsState state) {
      tester.view
        ..physicalSize = const Size(800, 1400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      when(() => bloc.state).thenReturn(state);
      return tester.pumpApp(
        ResultsView(),
        resultsBloc: bloc,
        formulaOneRepository: repository,
      );
    }

    testWidgets('shows a progress indicator when initial', (tester) async {
      await pumpView(tester, ResultsState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Round '), findsNothing);
    });

    testWidgets('shows a progress indicator when loading without results', (
      tester,
    ) async {
      await pumpView(tester, ResultsState(status: ResultsStatus.loading));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('keeps the results while reloading', (tester) async {
      await pumpView(
        tester,
        ResultsState(
          status: ResultsStatus.loading,
          raceResults: raceResults,
          round: 17,
        ),
      );

      expect(find.byType(ResultsSuccess), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows the results and the round pill on success', (
      tester,
    ) async {
      await pumpView(
        tester,
        ResultsState(
          status: ResultsStatus.success,
          raceResults: raceResults,
          round: 17,
        ),
      );

      expect(find.byType(ResultsSuccess), findsOneWidget);
      expect(find.text('Round 17'), findsOneWidget);
    });

    testWidgets('shows a message when there are no results', (tester) async {
      await pumpView(tester, ResultsState(status: ResultsStatus.empty));

      expect(find.text('NO RESULTS YET'), findsOneWidget);
    });

    testWidgets('shows the failure view and retries the same round', (
      tester,
    ) async {
      await pumpView(
        tester,
        ResultsState(
          status: ResultsStatus.failure,
          round: 17,
          failure: FormulaOneNetworkFailure('offline'),
        ),
      );

      expect(find.byType(FormulaOneFailureView), findsOneWidget);

      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(ResultsRequested(round: 17))).called(1);
    });

    testWidgets('retries the latest race when no round was requested', (
      tester,
    ) async {
      await pumpView(tester, ResultsState(status: ResultsStatus.failure));

      await tester.tap(find.text('Retry'));

      verify(() => bloc.add(ResultsRequested())).called(1);
    });

    group('top bar', () {
      testWidgets('shows the Latest chip on the tab while on the latest race', (
        tester,
      ) async {
        await pumpView(
          tester,
          ResultsState(status: ResultsStatus.success, raceResults: raceResults),
        );

        expect(find.text('LATEST RACE'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsNothing);
      });

      testWidgets('hides the Latest chip for a specific round', (tester) async {
        await pumpView(
          tester,
          ResultsState(
            status: ResultsStatus.success,
            raceResults: raceResults,
            round: 16,
          ),
        );

        expect(find.text('LATEST RACE'), findsNothing);
      });

      testWidgets('hides the Latest chip while nothing has loaded', (
        tester,
      ) async {
        await pumpView(tester, ResultsState(status: ResultsStatus.loading));

        expect(find.text('LATEST RACE'), findsNothing);
      });

      testWidgets('shows a back button instead of the chip when pushed', (
        tester,
      ) async {
        when(() => bloc.state).thenReturn(
          ResultsState(status: ResultsStatus.success, raceResults: raceResults),
        );
        await tester.pumpApp(
          Scaffold(),
          resultsBloc: bloc,
          formulaOneRepository: repository,
        );
        final context = tester.element(find.byType(Scaffold));

        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => ResultsView()));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.text('LATEST RACE'), findsNothing);

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(find.byType(ResultsView), findsNothing);
      });
    });

    group('round picker', () {
      ResultsState success() => ResultsState(
        status: ResultsStatus.success,
        raceResults: raceResults,
        round: 17,
      );

      testWidgets('requests the picked round', (tester) async {
        await pumpView(tester, success());

        await tester.tap(find.text('Round 17'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('RACE 16 GRAND PRIX'));
        await tester.pumpAndSettle();

        verify(() => bloc.add(ResultsRequested(round: 16))).called(1);
      });

      testWidgets('does nothing when the current round is picked', (
        tester,
      ) async {
        await pumpView(tester, success());

        await tester.tap(find.text('Round 17'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('RACE 17 GRAND PRIX'));
        await tester.pumpAndSettle();

        verifyNever(() => bloc.add(any()));
      });

      testWidgets('does nothing when the sheet is dismissed', (tester) async {
        await pumpView(tester, success());

        await tester.tap(find.text('Round 17'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        verifyNever(() => bloc.add(any()));
      });
    });
  });
}
