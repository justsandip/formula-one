import 'package:formula_one/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// {@template formula_one_theme}
/// Formula One theme.
/// {@endtemplate}
class FormulaOneTheme {
  /// {@macro formula_one_theme}
  const new();

  /// [ThemeData] for Formula One.
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme,
      dividerTheme: _dividerTheme,
      cardTheme: _cardTheme,
      bottomSheetTheme: _bottomSheetTheme,
    );
  }

  /// Color roles, mapped from [FormulaOneColors].
  ColorScheme get colorScheme {
    return const ColorScheme.dark(
      primary: FormulaOneColors.racingRed,
      onPrimary: FormulaOneColors.carbon,
      surface: FormulaOneColors.carbon,
      onSurface: FormulaOneColors.offWhite,
      onSurfaceVariant: FormulaOneColors.silver,
      surfaceContainer: FormulaOneColors.graphite,
      outline: FormulaOneColors.steel,
      outlineVariant: FormulaOneColors.steel,
    );
  }

  TextTheme get _textTheme {
    const styles = FormulaOneTextStyles.mobile;
    return TextTheme(
      displayLarge: styles.displayLarge,
      displayMedium: styles.displayMedium,
      displaySmall: styles.displaySmall,
      headlineLarge: styles.headlineLarge,
      headlineMedium: styles.headlineMedium,
      titleLarge: styles.titleLarge,
      titleMedium: styles.titleMedium,
      bodyMedium: styles.bodyMedium,
      labelLarge: styles.labelLarge,
      labelMedium: styles.labelMedium,
      labelSmall: styles.labelSmall,
    ).apply(
      displayColor: FormulaOneColors.offWhite,
      bodyColor: FormulaOneColors.offWhite,
    );
  }

  DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: FormulaOneColors.steel,
      thickness: 1,
      space: 1,
    );
  }

  CardThemeData get _cardTheme {
    return CardThemeData(
      color: FormulaOneColors.graphite,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: FormulaOneColors.steel),
      ),
    );
  }

  BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: FormulaOneColors.graphite,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}
