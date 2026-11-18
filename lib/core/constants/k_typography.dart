import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KTypography {
  KTypography._();

  static final TextTheme textTheme = GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  );

  static TextStyle get displayLarge => textTheme.displayLarge ?? const TextStyle(fontSize: 57, fontWeight: FontWeight.bold);
  static TextStyle get displayMedium => textTheme.displayMedium ?? const TextStyle(fontSize: 45, fontWeight: FontWeight.bold);
  static TextStyle get displaySmall => textTheme.displaySmall ?? const TextStyle(fontSize: 36, fontWeight: FontWeight.bold);

  static TextStyle get headlineLarge => textTheme.headlineLarge ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.w600);
  static TextStyle get headlineMedium => textTheme.headlineMedium ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w600);
  static TextStyle get headlineSmall => textTheme.headlineSmall ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge => textTheme.titleLarge ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.w500);
  static TextStyle get titleMedium => textTheme.titleMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get titleSmall => textTheme.titleSmall ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get bodyLarge => textTheme.bodyLarge ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static TextStyle get bodyMedium => textTheme.bodyMedium ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle get bodySmall => textTheme.bodySmall ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

  static TextStyle get labelLarge => textTheme.labelLarge ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get labelMedium => textTheme.labelMedium ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle get labelSmall => textTheme.labelSmall ?? const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
}
