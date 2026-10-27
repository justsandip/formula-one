import 'package:material_ui/material_ui.dart';

/// {@template formula_one_pill}
/// Small rounded label, e.g. a status chip.
/// {@endtemplate}
class FormulaOnePill extends StatelessWidget {
  /// {@macro formula_one_pill}
  const new({
    required this.label,
    required this.background,
    required this.foreground,
    super.key,
  });

  /// Text, shown in uppercase.
  final String label;

  /// Fill color.
  final Color background;

  /// Text color.
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
