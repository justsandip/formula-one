import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/standings/standings.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StandingsSuccess', () {
    void setScreenSize(WidgetTester tester, Size size) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> pumpStandings(
      WidgetTester tester, {
      List<DriverStanding>? drivers,
      List<ConstructorStanding>? constructors,
    }) {
      setScreenSize(tester, const Size(800, 1200));
      return tester.pumpApp(
        Scaffold(
          body: StandingsSuccess(
            drivers: drivers ?? sampleDriverStandings(),
            constructors: constructors ?? sampleConstructorStandings(),
          ),
        ),
      );
    }

    group('header', () {
      testWidgets('shows the kicker, title and both tab pills', (tester) async {
        await pumpStandings(tester);

        expect(find.text('2026 SEASON'), findsOneWidget);
        expect(find.text('STANDINGS'), findsOneWidget);
        expect(find.text('Drivers'), findsOneWidget);
        expect(find.text('Constructors'), findsOneWidget);
      });
    });

    group('drivers tab', () {
      testWidgets('is selected first and shows the leader card', (
        tester,
      ) async {
        await pumpStandings(tester);

        expect(find.text('DRIVER'), findsOneWidget);
        expect(find.text('LEADER'), findsOneWidget);
        expect(find.text('No. 4'), findsOneWidget);
        expect(find.text('LANDO NORRIS'), findsOneWidget);
        expect(find.text('McLaren · 6 wins'), findsOneWidget);
        expect(find.text('408'), findsOneWidget);
        expect(find.text('pts · +37 on P2'), findsOneWidget);
      });

      testWidgets('lists the other drivers with points and gap', (
        tester,
      ) async {
        await pumpStandings(tester);

        expect(find.text('OSCAR PIASTRI'), findsOneWidget);
        expect(find.text('McLaren · 5 wins'), findsOneWidget);
        expect(find.text('371'), findsOneWidget);
        expect(find.text('\u221237'), findsOneWidget);
        expect(find.text('MAX VERSTAPPEN'), findsOneWidget);
        expect(find.text('\u221268'), findsOneWidget);
        // The leader only appears in the card, not in the list.
        expect(find.text('LANDO NORRIS'), findsOneWidget);
      });

      testWidgets('uses singular and plural wins, and omits zero wins', (
        tester,
      ) async {
        await pumpStandings(tester);

        expect(find.text('Mercedes · 1 win'), findsOneWidget);
        expect(find.text('Ferrari · 2 wins'), findsOneWidget);
        // Hamilton has no wins: just the team.
        expect(find.text('Ferrari'), findsOneWidget);
      });

      testWidgets('joins the teams of a driver who changed team', (
        tester,
      ) async {
        await pumpStandings(
          tester,
          drivers: [
            buildDriverStanding(
              position: 1,
              givenName: 'Lando',
              familyName: 'Norris',
              points: 100,
            ),
            buildDriverStanding(
              position: 2,
              givenName: 'Pierre',
              familyName: 'Gasly',
              points: 50,
              teams: ['Alpine', 'McLaren'],
            ),
          ],
        );

        expect(find.text('Alpine / McLaren'), findsOneWidget);
      });

      testWidgets('formats fractional points', (tester) async {
        await pumpStandings(
          tester,
          drivers: [
            buildDriverStanding(
              position: 1,
              givenName: 'Lando',
              familyName: 'Norris',
              points: 100,
            ),
            buildDriverStanding(
              position: 2,
              givenName: 'Oscar',
              familyName: 'Piastri',
              points: 12.5,
            ),
          ],
        );

        expect(find.text('12.5'), findsOneWidget);
        expect(find.text('\u221287.5'), findsOneWidget);
        expect(find.text('pts · +87.5 on P2'), findsOneWidget);
      });

      testWidgets('sizes each progress bar relative to the leader', (
        tester,
      ) async {
        await pumpStandings(tester);

        final bars = tester
            .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .toList();

        expect(bars.first.widthFactor, closeTo(371 / 408, 0.001));
      });

      testWidgets('draws empty bars while the leader has no points', (
        tester,
      ) async {
        await pumpStandings(
          tester,
          drivers: [
            buildDriverStanding(
              position: 1,
              givenName: 'Lando',
              familyName: 'Norris',
              points: 0,
            ),
            buildDriverStanding(
              position: 2,
              givenName: 'Oscar',
              familyName: 'Piastri',
              points: 0,
            ),
          ],
        );

        final bar = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );

        expect(bar.widthFactor, 0);
      });

      testWidgets('shows only the unit when there is no runner-up', (
        tester,
      ) async {
        await pumpStandings(
          tester,
          drivers: [
            buildDriverStanding(
              position: 1,
              givenName: 'Lando',
              familyName: 'Norris',
              points: 25,
            ),
          ],
        );

        expect(find.text('pts'), findsOneWidget);
        expect(find.byType(FractionallySizedBox), findsNothing);
      });
    });

    group('constructors tab', () {
      testWidgets('shows the constructors leader card and rows', (
        tester,
      ) async {
        await pumpStandings(tester);

        await tester.tap(find.text('Constructors'));
        await tester.pump();

        expect(find.text('TEAM'), findsOneWidget);
        expect(find.text('LEADER'), findsOneWidget);
        expect(find.text('MCLAREN'), findsOneWidget);
        expect(find.text('British · 11 wins'), findsOneWidget);
        expect(find.text('779'), findsOneWidget);
        expect(find.text('pts · +250 on P2'), findsOneWidget);
        expect(find.text('FERRARI'), findsOneWidget);
        expect(find.text('Italian · 2 wins'), findsOneWidget);
        expect(find.text('\u2212250'), findsOneWidget);
        // No race number for a team, and the drivers are gone.
        expect(find.textContaining('No. '), findsNothing);
        expect(find.text('LANDO NORRIS'), findsNothing);
      });

      testWidgets('switches back to the drivers', (tester) async {
        await pumpStandings(tester);

        await tester.tap(find.text('Constructors'));
        await tester.pump();
        await tester.tap(find.text('Drivers'));
        await tester.pump();

        expect(find.text('LANDO NORRIS'), findsOneWidget);
        expect(find.text('MCLAREN'), findsNothing);
      });
    });

    group('empty and short screens', () {
      testWidgets('shows a message when there are no standings', (
        tester,
      ) async {
        await pumpStandings(tester, drivers: const [], constructors: const []);

        expect(find.text('NO STANDINGS YET'), findsOneWidget);
        expect(find.text('LEADER'), findsNothing);
      });

      testWidgets('shows the message only for the empty tab', (tester) async {
        await pumpStandings(tester, constructors: const []);

        expect(find.text('LANDO NORRIS'), findsOneWidget);

        await tester.tap(find.text('Constructors'));
        await tester.pump();

        expect(find.text('NO STANDINGS YET'), findsOneWidget);
      });

      testWidgets(
        'hides the leader card on short screens and lists the leader',
        (tester) async {
          setScreenSize(tester, const Size(800, 500));
          await tester.pumpApp(
            Scaffold(
              body: StandingsSuccess(
                drivers: sampleDriverStandings(),
                constructors: sampleConstructorStandings(),
              ),
            ),
          );

          expect(find.text('LEADER'), findsNothing);
          expect(find.text('LANDO NORRIS'), findsOneWidget);
        },
      );
    });
  });
}
