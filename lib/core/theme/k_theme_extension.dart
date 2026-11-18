import 'package:flutter/material.dart';
import '../constants/k_color_theme.dart';

/// Comprehensive semantic theme extension accessible via `context.kTheme` or `Theme.of(context).extension<KThemeColors>()`.
@immutable
class KThemeColors extends ThemeExtension<KThemeColors> {
  final KThemePalette palette;
  final KColorTheme colorTheme;
  final Brightness brightness;

  const KThemeColors({
    required this.palette,
    required this.colorTheme,
    required this.brightness,
  });

  bool get isDark => brightness == Brightness.dark;

  // Semantic surfaces & backgrounds
  Color get primary => palette.primary;
  Color get secondary => palette.secondary;
  Color get background => palette.background;
  Color get backgroundElevated => palette.backgroundElevated;
  Color get surface => palette.surface;
  Color get surfaceElevated => palette.surfaceElevated;
  Color get card => palette.card;
  Color get glassSurface => palette.glassSurface;
  Color get glassBorder => palette.glassBorder;
  Color get divider => palette.divider;

  // Typography
  Color get textPrimary => palette.textPrimary;
  Color get textSecondary => palette.textSecondary;
  Color get textMuted => palette.textMuted;

  // Semantic state indicators
  Color get error => palette.error;
  Color get warning => palette.warning;
  Color get success => palette.success;
  Color get info => palette.info;

  // Interactive buttons & calculator tokens
  Color get operatorBg => palette.operatorBg;
  Color get operatorText => palette.operatorText;
  Color get equalsBg => palette.equalsBg;
  Color get equalsText => palette.equalsText;
  Color get actionBg => palette.actionBg;
  Color get actionText => palette.actionText;
  Color get secondaryButtonBg => palette.secondaryButtonBg;
  Color get secondaryButtonText => palette.secondaryButtonText;
  Color get numButtonBg => palette.numButtonBg;
  Color get numButtonText => palette.numButtonText;

  // Form input tokens
  Color get inputBg => palette.inputBg;
  Color get inputBorder => palette.inputBorder;
  Color get inputBorderFocused => palette.inputBorderFocused;

  @override
  KThemeColors copyWith({
    KThemePalette? palette,
    KColorTheme? colorTheme,
    Brightness? brightness,
  }) {
    return KThemeColors(
      palette: palette ?? this.palette,
      colorTheme: colorTheme ?? this.colorTheme,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  KThemeColors lerp(ThemeExtension<KThemeColors>? other, double t) {
    if (other is! KThemeColors) return this;
    if (t < 0.5) return this;
    return other;
  }
}

/// Convenience build context extension for instant theme access anywhere in widget tree.
extension KThemeBuildContextExtension on BuildContext {
  KThemeColors get kTheme =>
      Theme.of(this).extension<KThemeColors>() ??
      KThemeColors(
        palette: KColorTheme.kreateBlue.palette(Theme.of(this).brightness),
        colorTheme: KColorTheme.kreateBlue,
        brightness: Theme.of(this).brightness,
      );

  KThemePalette get kPalette => kTheme.palette;
}
