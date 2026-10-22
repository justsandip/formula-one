import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group('NextRaceCard', () {
    testWidgets('renders the race details and the countdown', (tester) async {
      // Extra seconds keep the minute stable while the test runs.
      final race = buildRace(
        round: 18,
        name: 'United States Grand Prix',
        startsAt: DateTime.now().add(
          const Duration(days: 7, hours: 11, minutes: 51, seconds: 30),
        ),
      );

      await tester.pumpApp(Scaffold(body: NextRaceCard(race: race)));

      expect(find.text('NEXT RACE'), findsOneWidget);
      expect(find.text('Round 18'), findsOneWidget);
      expect(find.text('UNITED STATES GRAND\u00A0PRIX'), findsOneWidget);
      expect(find.text('Circuit 18'), findsOneWidget);
      expect(find.text('07'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('51'), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
      expect(find.text('hours'), findsOneWidget);
      expect(find.text('min'), findsOneWidget);
    });

    testWidgets('shows zeros when the race has already started',
        (tester) async {
      final race = buildRace(
        startsAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpApp(Scaffold(body: NextRaceCard(race: race)));

      expect(find.text('00'), findsNWidgets(3));
    });

    testWidgets('keeps rendering after the refresh timer fires',
        (tester) async {
      final race = buildRace(
        startsAt: DateTime.now().add(const Duration(days: 2, minutes: 30)),
      );
      await tester.pumpApp(Scaffold(body: NextRaceCard(race: race)));

      // The timer runs on fake time, but DateTime.now() is real time, so the
      // values do not change. This only proves the callback runs cleanly.
      await tester.pump(const Duration(seconds: 30));

      expect(find.text('02'), findsOneWidget);
    });

    testWidgets('updates when it receives another race', (tester) async {
      final soon = buildRace(
        startsAt: DateTime.now().add(const Duration(days: 3, minutes: 30)),
      );
      final later = buildRace(
        round: 2,
        startsAt: DateTime.now().add(const Duration(days: 9, minutes: 30)),
      );

      await tester.pumpApp(Scaffold(body: NextRaceCard(race: soon)));
      expect(find.text('03'), findsOneWidget);

      await tester.pumpApp(Scaffold(body: NextRaceCard(race: later)));
      expect(find.text('09'), findsOneWidget);
      expect(find.text('Round 2'), findsOneWidget);
    });

    testWidgets('stops its timer when removed', (tester) async {
      final race = buildRace(
        startsAt: DateTime.now().add(const Duration(days: 1)),
      );
      await tester.pumpApp(Scaffold(body: NextRaceCard(race: race)));

      await tester.pumpApp(const Scaffold());

      // A pending timer would fail the test on its own; this makes the
      // intent explicit.
      expect(find.byType(NextRaceCard), findsNothing);
    });
  });
}
