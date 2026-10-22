import 'dart:ui' show Color;

/// {@template formula_one_colors}
/// Color palette of the Formula One UI.
///
/// Names describe the color, not its role, because most colors serve
/// several roles. Map them to roles (background, surface, ...) in the theme.
/// {@endtemplate}
abstract class FormulaOneColors {
  /// Near-black base. App background.
  static const carbon = Color(0xFF0D0E11);

  /// Navigation bar background, one step above [carbon].
  static const asphalt = Color(0xFF111317);

  /// Card and list row surface.
  static const graphite = Color(0xFF16181D);

  /// Borders, dividers, chip fills and progress tracks.
  static const steel = Color(0xFF262930);

  /// Muted text: meta info and inactive labels.
  static const silver = Color(0xFF8A8F99);

  /// Secondary text.
  static const platinum = Color(0xFFC9CCD3);

  /// Primary text.
  static const offWhite = Color(0xFFF2F3F5);

  /// Accent: active states, highlights and the leading result.
  static const racingRed = Color(0xFFFF4A3D);
}
