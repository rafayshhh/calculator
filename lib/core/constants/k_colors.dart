import 'package:flutter/material.dart';
import '../theme/k_theme_extension.dart';
import 'k_color_theme.dart';

class KColors {
  KColors._();

  // Primary brand colors (Default fallback)
  static const Color primary = Color(0xFF00E5FF); // Electric Cyan
  static const Color secondary = Color(0xFF3D5AFE);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentViolet = Color(0xFF7C4DFF);

  // Semantic Feedback Tokens
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF1744);
  static const Color info = Color(0xFF00B0FF);

  // Dark Theme Tokens (Default Midnight Navy / Deep Glass)
  static const Color backgroundDark = Color(0xFF070B19);
  static const Color backgroundElevatedDark = Color(0xFF0F1528);
  static const Color surfaceDark = Color(0xFF141C33);
  static const Color surfaceElevatedDark = Color(0xFF1B2440);

  static const Color glassSurfaceDark = Color(0x1A4072FF);
  static const Color glassBorderDark = Color(0x334072FF);
  static const Color cardDark = Color(0xFF131B31);
  static const Color dividerDark = Color(0x264072FF);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xB3FFFFFF);
  static const Color textMutedDark = Color(0x80FFFFFF);

  // Light Theme Tokens (Default Cool White / Navy / Subtle Glass)
  static const Color backgroundLight = Color(0xFFF3F6FA);
  static const Color backgroundElevatedLight = Color(0xFFE8EEF5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF0F4F9);

  static const Color glassSurfaceLight = Color(0x15007AFF);
  static const Color glassBorderLight = Color(0x25007AFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0x1A007AFF);

  static const Color textPrimaryLight = Color(0xFF0B132B);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Helper method to retrieve the active theme palette directly
  static KThemePalette palette(BuildContext context) {
    final ext = Theme.of(context).extension<KThemeColors>();
    if (ext != null) return ext.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return KColorTheme.kreateBlue.palette(isDark ? Brightness.dark : Brightness.light);
  }

  // Dynamic Theme-Aware Helper Getters for all active themes
  static Color primaryAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.primary ??
      (Theme.of(context).brightness == Brightness.dark ? primary : const Color(0xFF0091EA));

  static Color secondaryAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.secondary ?? secondary;

  static Color textPrimaryAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.textPrimary ??
      (Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight);

  static Color textSecondaryAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.textSecondary ??
      (Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight);

  static Color textMutedAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.textMuted ??
      (Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMutedLight);

  static Color surfaceAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.surface ??
      (Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight);

  static Color surfaceElevatedAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.surfaceElevated ??
      (Theme.of(context).brightness == Brightness.dark ? surfaceElevatedDark : surfaceElevatedLight);

  static Color backgroundAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.background ??
      (Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight);

  static Color backgroundElevatedAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.backgroundElevated ??
      (Theme.of(context).brightness == Brightness.dark ? backgroundElevatedDark : backgroundElevatedLight);

  static Color glassSurfaceAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.glassSurface ??
      (Theme.of(context).brightness == Brightness.dark ? glassSurfaceDark : glassSurfaceLight);

  static Color glassBorderAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.glassBorder ??
      (Theme.of(context).brightness == Brightness.dark ? glassBorderDark : glassBorderLight);

  static Color cardAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.card ??
      (Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight);

  static Color dividerAdaptive(BuildContext context) =>
      Theme.of(context).extension<KThemeColors>()?.divider ??
      (Theme.of(context).brightness == Brightness.dark ? dividerDark : dividerLight);

  // Legacy / Default Fallbacks
  static const Color background = backgroundDark;
  static const Color backgroundElevated = backgroundElevatedDark;
  static const Color surface = surfaceDark;
  static const Color surfaceElevated = surfaceElevatedDark;

  static const Color glassSurface = glassSurfaceDark;
  static const Color glassBorder = glassBorderDark;

  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textMuted = textMutedDark;
}
