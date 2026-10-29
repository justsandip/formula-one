import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/results/results.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ResultsSuccess', () {
    Future<void> pumpResults(WidgetTester tester, RaceResults raceResults) {
      tester.view
        ..physicalSize = const Size(800, 1400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpApp(
        Scaffold(body: ResultsSuccess(raceResults: raceResults)),
      );
    }

    testWidgets('shows the round, location and race name', (tester) async {
      await pumpResults(tester, buildRaceResults());

      expect(find.text('ROUND 17 · CITY 17'), findsOneWidget);
      expect(find.text('SINGAPORE GRAND PRIX'), findsOneWidget);
    });

    testWidgets('shows the podium with codes and times', (tester) async {
      await pumpResults(tester, buildRaceResults());

      expect(find.text('P1'), findsOneWidget);
      expect(find.text('P2'), findsOneWidget);
      expect(find.text('P3'), findsOneWidget);
      expect(find.text('NOR'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
      expect(find.text('PIA'), findsOneWidget);
      expect(find.text('1:40:22.000'), findsOneWidget);
      expect(find.text('+3.2s'), findsOneWidget);
      expect(find.text('+7.9s'), findsOneWidget);
    });

    testWidgets('falls back to the status when a podium driver has no time', (
      tester,
    ) async {
      await pumpResults(
        tester,
        buildRaceResults(
          results: [
            buildRaceResult(position: 1, code: 'NOR', time: '1:40:22.000'),
            buildRaceResult(position: 2, code: 'VER', time: '+3.2s'),
            buildRaceResult(position: 3, code: 'PIA', status: '+1 Lap'),
          ],
        ),
      );

      expect(find.text('+1 Lap'), findsOneWidget);
    });

    testWidgets('lists the rest of the classification below the podium', (
      tester,
    ) async {
      await pumpResults(tester, buildRaceResults());

      expect(find.text('LEC'), findsOneWidget);
      expect(find.text('Ferrari'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('+12.4S'), findsOneWidget);
      expect(find.text('RUS'), findsOneWidget);
      expect(find.text('Mercedes'), findsOneWidget);
    });

    testWidgets('shows a retirement with its position text and status', (
      tester,
    ) async {
      await pumpResults(tester, buildRaceResults());

      expect(find.text('ALO'), findsOneWidget);
      expect(find.text('Aston Martin'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('RETIRED'), findsOneWidget);
    });

    testWidgets('lists every result when there are fewer than three', (
      tester,
    ) async {
      await pumpResults(
        tester,
        buildRaceResults(
          results: [
            buildRaceResult(position: 1, code: 'NOR', time: '1:40:22.000'),
            buildRaceResult(position: 2, code: 'VER', time: '+3.2s'),
          ],
        ),
      );

      expect(find.text('P1'), findsNothing);
      expect(find.text('NOR'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
    });

    testWidgets('shows no list card when the podium is the whole result', (
      tester,
    ) async {
      await pumpResults(
        tester,
        buildRaceResults(
          results: [
            buildRaceResult(position: 1, code: 'NOR', time: '1:40:22.000'),
            buildRaceResult(position: 2, code: 'VER', time: '+3.2s'),
            buildRaceResult(position: 3, code: 'PIA', time: '+7.9s'),
          ],
        ),
      );

      // Only the three podium cards.
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.byType(Divider), findsNothing);
    });
  });
}
