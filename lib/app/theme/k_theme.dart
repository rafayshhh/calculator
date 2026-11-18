import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/k_color_theme.dart';
import '../../core/constants/k_typography.dart';
import '../../core/theme/k_theme_extension.dart';

class KTheme {
  KTheme._();

  static ThemeData get darkTheme => buildTheme(
    brightness: Brightness.dark,
    colorTheme: KColorTheme.kreateBlue,
  );

  static ThemeData get lightTheme => buildTheme(
    brightness: Brightness.light,
    colorTheme: KColorTheme.kreateBlue,
  );

  static ThemeData buildTheme({
    required Brightness brightness,
    KColorTheme colorTheme = KColorTheme.kreateBlue,
  }) {
    final isDark = brightness == Brightness.dark;
    final palette = colorTheme.palette(brightness);

    final baseTextTheme = isDark
        ? KTypography.textTheme
        : GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      extensions: [
        KThemeColors(
          palette: palette,
          colorTheme: colorTheme,
          brightness: brightness,
        ),
      ],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.primary,
        onPrimary: isDark && colorTheme != KColorTheme.classic
            ? Colors.black
            : (isDark ? Colors.black : Colors.white),
        primaryContainer: palette.primaryContainer,
        onPrimaryContainer: palette.onPrimaryContainer,
        secondary: palette.secondary,
        onSecondary: Colors.white,
        secondaryContainer: palette.secondaryContainer,
        error: palette.error,
        onError: Colors.white,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        surfaceContainerHighest: palette.surfaceElevated,
      ),
      textTheme: isDark
          ? baseTextTheme
          : baseTextTheme.copyWith(
              displayLarge: baseTextTheme.displayLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: baseTextTheme.displayMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: baseTextTheme.titleLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: baseTextTheme.bodyLarge?.copyWith(
                color: palette.textPrimary,
              ),
              bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.glassBorder, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceElevated,
        side: BorderSide(color: palette.glassBorder, width: 1),
        labelStyle: TextStyle(color: palette.textSecondary, fontSize: 12),
        selectedColor: palette.primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: palette.glassBorder, width: 1),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: palette.textSecondary),
        hintStyle: TextStyle(color: palette.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.backgroundElevated,
        indicatorColor: palette.glassSurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.primary);
          }
          return IconThemeData(color: palette.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: palette.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(color: palette.textMuted, fontSize: 12);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.backgroundElevated,
        indicatorColor: palette.glassSurface,
        selectedIconTheme: IconThemeData(color: palette.primary),
        unselectedIconTheme: IconThemeData(color: palette.textMuted),
        selectedLabelTextStyle: TextStyle(
          color: palette.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: palette.textMuted,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary),
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
  }
}
