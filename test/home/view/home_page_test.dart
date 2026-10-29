// ignore_for_file: prefer_const_constructors, document_ignores,
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/home/home.dart';
import 'package:formula_one/results/results.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockFormulaOneRepository extends Mock implements FormulaOneRepository;

void main() {
  group('HomePage', () {
    late FormulaOneRepository repository;

    setUp(() {
      repository = _MockFormulaOneRepository();
      when(() => repository.getRaces(season: null)).thenAnswer((_) async => []);
    });

    Future<void> pumpHome(WidgetTester tester) async {
      await tester.pumpApp(HomePage(), formulaOneRepository: repository);
      await tester.pump();
      await tester.pump();
    }

    Finder navLabel(String label) => find.descendant(
      of: find.byType(HomeNavBar),
      matching: find.text(label),
    );

    HomeCubit homeCubit(WidgetTester tester) =>
        tester.element(find.byType(HomeView)).read<HomeCubit>();

    testWidgets('provides a HomeCubit to HomeView', (tester) async {
      await pumpHome(tester);

      expect(find.byType(HomeView), findsOneWidget);
      expect(homeCubit(tester).state, const HomeState());
    });

    testWidgets('builds only the selected tab at first', (tester) async {
      await pumpHome(tester);

      expect(find.byType(SchedulePage), findsOneWidget);
      expect(find.byType(Placeholder, skipOffstage: false), findsNothing);
    });

    testWidgets('builds a tab the first time it is selected', (tester) async {
      await pumpHome(tester);

      await tester.tap(navLabel('RESULTS'));
      await tester.pump();

      expect(homeCubit(tester).state.tab, HomeTab.results);
      expect(find.byType(ResultsPage, skipOffstage: false), findsOneWidget);
    });

    testWidgets('selects the standings tab', (tester) async {
      await pumpHome(tester);

      await tester.tap(navLabel('STANDINGS'));
      await tester.pump();

      expect(homeCubit(tester).state.tab, HomeTab.standings);
    });

    testWidgets('keeps the calendar alive while another tab is showing', (
      tester,
    ) async {
      await pumpHome(tester);
      final bloc = tester
          .element(find.byType(ScheduleView))
          .read<ScheduleBloc>();

      await tester.tap(navLabel('RESULTS'));
      await tester.pump();

      expect(find.byType(SchedulePage), findsNothing);
      expect(find.byType(SchedulePage, skipOffstage: false), findsOneWidget);

      await tester.tap(navLabel('CALENDAR'));
      await tester.pump();

      final sameBloc = tester
          .element(find.byType(ScheduleView))
          .read<ScheduleBloc>();
      expect(sameBloc, same(bloc));
      verify(() => repository.getRaces(season: null)).called(1);
    });
  });
}
