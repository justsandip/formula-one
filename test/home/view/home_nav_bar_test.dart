import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/home/home.dart';
import 'package:formula_one/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group('HomeNavBar', () {
    Future<void> pumpBar(
      WidgetTester tester, {
      HomeTab selected = HomeTab.calendar,
      ValueChanged<HomeTab>? onSelected,
    }) {
      return tester.pumpApp(
        Scaffold(
          bottomNavigationBar: HomeNavBar(
            selected: selected,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      );
    }

    Color? labelColor(WidgetTester tester, String label) =>
        tester.widget<Text>(find.text(label)).style?.color;

    testWidgets('renders the three tab labels in uppercase', (tester) async {
      await pumpBar(tester);

      expect(find.text('CALENDAR'), findsOneWidget);
      expect(find.text('RESULTS'), findsOneWidget);
      expect(find.text('STANDINGS'), findsOneWidget);
    });

    testWidgets('does not grow to fill the screen', (tester) async {
      await pumpBar(tester);

      final height = tester.getSize(find.byType(HomeNavBar)).height;

      expect(height, greaterThanOrEqualTo(64));
      expect(height, lessThan(150));
    });

    testWidgets('highlights only the selected tab', (tester) async {
      await pumpBar(tester, selected: HomeTab.results);
      final scheme = const FormulaOneTheme().colorScheme;

      expect(labelColor(tester, 'RESULTS'), scheme.onSurface);
      expect(labelColor(tester, 'CALENDAR'), scheme.onSurfaceVariant);
      expect(labelColor(tester, 'STANDINGS'), scheme.onSurfaceVariant);
    });

    testWidgets('reports the tapped tab', (tester) async {
      final selected = <HomeTab>[];
      await pumpBar(tester, onSelected: selected.add);

      await tester.tap(find.text('RESULTS'));
      await tester.tap(find.text('STANDINGS'));
      await tester.tap(find.text('CALENDAR'));

      expect(selected, [HomeTab.results, HomeTab.standings, HomeTab.calendar]);
    });
  });
}
