import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// {@template formula_one_text_styles}
/// Text styles of the Formula One UI.
///
/// Fonts come from the `google_fonts` package: Barlow Condensed for titles,
/// names and numbers, and Barlow for labels and body text.
/// {@endtemplate}
abstract class FormulaOneTextStyles {
  const new _();

  /// Text styles for mobile devices.
  static const mobile = _TextStylesMobile._();

  /// Large standalone numbers, e.g. the standings leader's points.
  TextStyle get displayLarge;

  /// Page titles. Uppercase.
  TextStyle get displayMedium;

  /// Hero names and leader names. Uppercase.
  TextStyle get displaySmall;

  /// Podium leader code.
  TextStyle get headlineLarge;

  /// Points and podium codes.
  TextStyle get headlineMedium;

  /// Round and position numbers.
  TextStyle get titleLarge;

  /// Row titles. Uppercase.
  TextStyle get titleMedium;

  /// Meta text and secondary lines.
  TextStyle get bodyMedium;

  /// Buttons, segmented controls and the navigation bar.
  TextStyle get labelLarge;

  /// Kicker labels above titles. Uppercase.
  TextStyle get labelMedium;

  /// Chips. Uppercase.
  TextStyle get labelSmall;
}

class _TextStylesMobile extends FormulaOneTextStyles {
  const new _() : super._();

  @override
  TextStyle get displayLarge => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w700,
        fontSize: 44,
        height: 1,
      );

  @override
  TextStyle get displayMedium => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w700,
        fontSize: 40,
        height: 1,
      );

  @override
  TextStyle get displaySmall => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w700,
        fontSize: 36,
        height: 1,
      );

  @override
  TextStyle get headlineLarge => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w700,
        fontSize: 28,
      );

  @override
  TextStyle get headlineMedium => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w700,
        fontSize: 20,
      );

  @override
  TextStyle get titleLarge => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      );

  @override
  TextStyle get titleMedium => GoogleFonts.barlowCondensed(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: 0.34,
      );

  @override
  TextStyle get bodyMedium => GoogleFonts.barlow(
        fontWeight: FontWeight.w400,
        fontSize: 13,
      );

  @override
  TextStyle get labelLarge => GoogleFonts.barlow(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      );

  @override
  TextStyle get labelMedium => GoogleFonts.barlow(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 1.68,
      );

  @override
  TextStyle get labelSmall => GoogleFonts.barlow(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 0.88,
      );
}
