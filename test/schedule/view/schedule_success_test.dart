import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ScheduleSuccess', () {
    void setScreenSize(WidgetTester tester, Size size) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> pumpSuccess(WidgetTester tester, List<Race> races) {
      return tester.pumpApp(Scaffold(body: ScheduleSuccess(races: races)));
    }

    // Local times at midday so the formatted date never shifts a day.
    DateTime past(int day) => DateTime(2020, 3, day, 12);
    DateTime future(int days) => DateTime.now().add(Duration(days: days));

    testWidgets('shows a message when there are no races', (tester) async {
      await pumpSuccess(tester, const []);

      expect(find.text('NO RACES YET'), findsOneWidget);
      expect(find.byType(NextRaceCard), findsNothing);
    });

    testWidgets('renders the header and one row per race', (tester) async {
      setScreenSize(tester, const Size(800, 1200));
      await pumpSuccess(tester, [
        buildRace(startsAt: past(15)),
        buildRace(round: 2, startsAt: future(10)),
        buildRace(round: 3, startsAt: future(20)),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('2020 SEASON'), findsOneWidget);
      expect(find.text('CALENDAR'), findsOneWidget);
      expect(find.text('R01'), findsOneWidget);
      expect(find.text('R02'), findsOneWidget);
      expect(find.text('R03'), findsOneWidget);
      expect(find.text('RACE 1 GRAND PRIX'), findsOneWidget);
      expect(find.text('City 1 · 15 Mar'), findsOneWidget);
      // The next race appears in its row and in the next race card.
      expect(find.text('RACE 2 GRAND PRIX'), findsOneWidget);
      expect(find.text('RACE 2 GRAND\u00A0PRIX'), findsOneWidget);
      expect(find.text('RACE 3 GRAND PRIX'), findsOneWidget);
    });

    testWidgets('marks races as done, next and upcoming', (tester) async {
      setScreenSize(tester, const Size(800, 1200));
      await pumpSuccess(tester, [
        buildRace(startsAt: past(15)),
        buildRace(round: 2, startsAt: future(10)),
        buildRace(round: 3, startsAt: future(20)),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('DONE'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);
    });

    testWidgets('shows the next race card when there is room', (tester) async {
      setScreenSize(tester, const Size(800, 1200));
      await pumpSuccess(tester, [
        buildRace(startsAt: past(15)),
        buildRace(round: 2, startsAt: future(10)),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(NextRaceCard), findsOneWidget);
    });

    testWidgets('hides the next race card on short screens', (tester) async {
      setScreenSize(tester, const Size(800, 500));
      await pumpSuccess(tester, [
        buildRace(startsAt: past(15)),
        buildRace(round: 2, startsAt: future(10)),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(NextRaceCard), findsNothing);
      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('has no next race card or Next chip once the season is over', (
      tester,
    ) async {
      setScreenSize(tester, const Size(800, 1200));
      await pumpSuccess(tester, [
        buildRace(startsAt: past(1)),
        buildRace(round: 2, startsAt: past(8)),
        buildRace(round: 3, startsAt: past(15)),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(NextRaceCard), findsNothing);
      expect(find.text('NEXT'), findsNothing);
      expect(find.text('DONE'), findsNWidgets(3));
    });

    testWidgets('opens with the last two completed races above the next one', (
      tester,
    ) async {
      setScreenSize(tester, const Size(800, 700));
      // Rounds 1-12 are done, round 13 (index 12) is next, 14-20 upcoming.
      final races = [
        for (var i = 0; i < 12; i++)
          buildRace(round: i + 1, startsAt: past(i + 1)),
        for (var i = 12; i < 20; i++)
          buildRace(round: i + 1, startsAt: future(i)),
      ];

      await pumpSuccess(tester, races);
      await tester.pumpAndSettle();

      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      double top(String name) => tester.getTopLeft(find.text(name).last).dy;

      // Round 11 (two before the next race) sits at the top edge.
      expect(top('RACE 11 GRAND PRIX'), greaterThanOrEqualTo(viewport.top));
      expect(top('RACE 11 GRAND PRIX'), lessThan(viewport.top + 65));
      // Earlier rounds are scrolled out above.
      expect(top('RACE 10 GRAND PRIX'), lessThan(viewport.top));
      // Round 12 and the next race (13) are inside the viewport.
      expect(top('RACE 12 GRAND PRIX'), lessThan(viewport.bottom));
      expect(top('RACE 13 GRAND PRIX'), lessThan(viewport.bottom));
    });
  });
}
