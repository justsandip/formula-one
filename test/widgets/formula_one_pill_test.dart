import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/widgets/formula_one_pill.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/helpers.dart';

void main() {
  group('FormulaOnePill', () {
    const background = Color(0xFF112233);
    const foreground = Color(0xFFEEDDCC);

    testWidgets('shows the label in uppercase', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: FormulaOnePill(
            label: 'Leader',
            background: background,
            foreground: foreground,
          ),
        ),
      );

      expect(find.text('LEADER'), findsOneWidget);
    });

    testWidgets('applies the given colors', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: FormulaOnePill(
            label: 'Leader',
            background: background,
            foreground: foreground,
          ),
        ),
      );

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(FormulaOnePill),
          matching: find.byType(DecoratedBox),
        ),
      );
      final text = tester.widget<Text>(find.text('LEADER'));

      expect((box.decoration as BoxDecoration).color, background);
      expect(text.style?.color, foreground);
    });
  });
}
