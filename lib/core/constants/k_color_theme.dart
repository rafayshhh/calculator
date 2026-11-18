import 'package:flutter/material.dart';

/// Semantic palette defining all UI surfaces, borders, text, controls, and accents for a specific theme.
class KThemePalette {
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color background;
  final Color backgroundElevated;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceVariant;
  final Color card;
  final Color glassSurface;
  final Color glassBorder;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color error;
  final Color warning;
  final Color success;
  final Color info;

  // Interactive controls & calculator button tokens
  final Color operatorBg;
  final Color operatorText;
  final Color equalsBg;
  final Color equalsText;
  final Color actionBg;
  final Color actionText;
  final Color secondaryButtonBg;
  final Color secondaryButtonText;
  final Color numButtonBg;
  final Color numButtonText;

  // Form input tokens
  final Color inputBg;
  final Color inputBorder;
  final Color inputBorderFocused;

  const KThemePalette({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.background,
    required this.backgroundElevated,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceVariant,
    required this.card,
    required this.glassSurface,
    required this.glassBorder,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    this.error = const Color(0xFFFF1744),
    this.warning = const Color(0xFFFFB300),
    this.success = const Color(0xFF00E676),
    this.info = const Color(0xFF00B0FF),
    required this.operatorBg,
    required this.operatorText,
    required this.equalsBg,
    required this.equalsText,
    required this.actionBg,
    required this.actionText,
    required this.secondaryButtonBg,
    required this.secondaryButtonText,
    required this.numButtonBg,
    required this.numButtonText,
    required this.inputBg,
    required this.inputBorder,
    required this.inputBorderFocused,
  });
}

/// 6 distinctive, cohesive brand color themes with dedicated Light and Dark palettes.
enum KColorTheme {
  kreateBlue(
    name: 'Kreate Blue',
    subtitle: 'Signature electric cyan & navy glassmorphism',
    accentColor: Color(0xFF00E5FF),
  ),
  classic(
    name: 'Classic',
    subtitle: 'Monochrome minimalist black & pure slate',
    accentColor: Color(0xFFFFFFFF),
  ),
  solarYellow(
    name: 'Solar Yellow',
    subtitle: 'Sophisticated warm amber & gold accents',
    accentColor: Color(0xFFFFD600),
  ),
  rosePink(
    name: 'Rose Pink',
    subtitle: 'Refined vivid rose & deep magenta highlights',
    accentColor: Color(0xFFFF4081),
  ),
  emeraldGreen(
    name: 'Emerald Green',
    subtitle: 'Premium electric emerald & deep forest surfaces',
    accentColor: Color(0xFF00E676),
  ),
  royalPurple(
    name: 'Royal Purple',
    subtitle: 'Deep galactic violet & luminous royal purple',
    accentColor: Color(0xFFB388FF),
  );

  final String name;
  final String subtitle;
  final Color accentColor;

  const KColorTheme({
    required this.name,
    required this.subtitle,
    required this.accentColor,
  });

  KThemePalette get darkPalette {
    switch (this) {
      case KColorTheme.kreateBlue:
        return const KThemePalette(
          primary: Color(0xFF00E5FF),
          primaryContainer: Color(0x2600E5FF),
          onPrimaryContainer: Color(0xFF00E5FF),
          secondary: Color(0xFF3D5AFE),
          secondaryContainer: Color(0x263D5AFE),
          background: Color(0xFF070B19),
          backgroundElevated: Color(0xFF0F1528),
          surface: Color(0xFF141C33),
          surfaceElevated: Color(0xFF1B2440),
          surfaceVariant: Color(0xFF182038),
          card: Color(0xFF131B31),
          glassSurface: Color(0x1A4072FF),
          glassBorder: Color(0x334072FF),
          divider: Color(0x264072FF),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xB3FFFFFF),
          textMuted: Color(0x80FFFFFF),
          operatorBg: Color(0x2400E5FF),
          operatorText: Color(0xFF00E5FF),
          equalsBg: Color(0xFF00E5FF),
          equalsText: Color(0xFF070B19),
          actionBg: Color(0x26FF1744),
          actionText: Color(0xFFFF5252),
          secondaryButtonBg: Color(0xFF141C33),
          secondaryButtonText: Color(0xB3FFFFFF),
          numButtonBg: Color(0xFF1B2440),
          numButtonText: Color(0xFFFFFFFF),
          inputBg: Color(0xFF1B2440),
          inputBorder: Color(0x334072FF),
          inputBorderFocused: Color(0xFF00E5FF),
        );
      case KColorTheme.classic:
        return const KThemePalette(
          primary: Color(0xFFFFFFFF),
          primaryContainer: Color(0x26FFFFFF),
          onPrimaryContainer: Color(0xFFFFFFFF),
          secondary: Color(0xFFA1A1AA),
          secondaryContainer: Color(0x26A1A1AA),
          background: Color(0xFF0E0E10),
          backgroundElevated: Color(0xFF18181B),
          surface: Color(0xFF222226),
          surfaceElevated: Color(0xFF2E2E33),
          surfaceVariant: Color(0xFF27272C),
          card: Color(0xFF1F1F23),
          glassSurface: Color(0x1AFFFFFF),
          glassBorder: Color(0x2BFFFFFF),
          divider: Color(0x20FFFFFF),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xB3FFFFFF),
          textMuted: Color(0x80FFFFFF),
          operatorBg: Color(0x26FFFFFF),
          operatorText: Color(0xFFFFFFFF),
          equalsBg: Color(0xFFFFFFFF),
          equalsText: Color(0xFF0E0E10),
          actionBg: Color(0x26FF1744),
          actionText: Color(0xFFFF5252),
          secondaryButtonBg: Color(0xFF222226),
          secondaryButtonText: Color(0xB3FFFFFF),
          numButtonBg: Color(0xFF2E2E33),
          numButtonText: Color(0xFFFFFFFF),
          inputBg: Color(0xFF2E2E33),
          inputBorder: Color(0x2BFFFFFF),
          inputBorderFocused: Color(0xFFFFFFFF),
        );
      case KColorTheme.solarYellow:
        return const KThemePalette(
          primary: Color(0xFFFFD600),
          primaryContainer: Color(0x26FFD600),
          onPrimaryContainer: Color(0xFFFFD600),
          secondary: Color(0xFFFFAB00),
          secondaryContainer: Color(0x26FFAB00),
          background: Color(0xFF121008),
          backgroundElevated: Color(0xFF1F1B0D),
          surface: Color(0xFF2A2412),
          surfaceElevated: Color(0xFF3B331A),
          surfaceVariant: Color(0xFF332C17),
          card: Color(0xFF262010),
          glassSurface: Color(0x1AFFD600),
          glassBorder: Color(0x33FFD600),
          divider: Color(0x26FFD600),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xB3FFFFFF),
          textMuted: Color(0x80FFFFFF),
          operatorBg: Color(0x26FFD600),
          operatorText: Color(0xFFFFD600),
          equalsBg: Color(0xFFFFD600),
          equalsText: Color(0xFF121008),
          actionBg: Color(0x26FF1744),
          actionText: Color(0xFFFF5252),
          secondaryButtonBg: Color(0xFF2A2412),
          secondaryButtonText: Color(0xB3FFFFFF),
          numButtonBg: Color(0xFF3B331A),
          numButtonText: Color(0xFFFFFFFF),
          inputBg: Color(0xFF3B331A),
          inputBorder: Color(0x33FFD600),
          inputBorderFocused: Color(0xFFFFD600),
        );
      case KColorTheme.rosePink:
        return const KThemePalette(
          primary: Color(0xFFFF4081),
          primaryContainer: Color(0x26FF4081),
          onPrimaryContainer: Color(0xFFFF4081),
          secondary: Color(0xFFE91E63),
          secondaryContainer: Color(0x26E91E63),
          background: Color(0xFF14090F),
          backgroundElevated: Color(0xFF24111C),
          surface: Color(0xFF331828),
          surfaceElevated: Color(0xFF452037),
          surfaceVariant: Color(0xFF3C1C30),
          card: Color(0xFF2D1423),
          glassSurface: Color(0x1AFF4081),
          glassBorder: Color(0x33FF4081),
          divider: Color(0x26FF4081),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xB3FFFFFF),
          textMuted: Color(0x80FFFFFF),
          operatorBg: Color(0x26FF4081),
          operatorText: Color(0xFFFF4081),
          equalsBg: Color(0xFFFF4081),
          equalsText: Color(0xFF14090F),
          actionBg: Color(0x26FF1744),
          actionText: Color(0xFFFF5252),
          secondaryButtonBg: Color(0xFF331828),
          secondaryButtonText: Color(0xB3FFFFFF),
          numButtonBg: Color(0xFF452037),
          numButtonText: Color(0xFFFFFFFF),
          inputBg: Color(0xFF452037),
          inputBorder: Color(0x33FF4081),
          inputBorderFocused: Color(0xFFFF4081),
        );
      case KColorTheme.emeraldGreen:
        return const KThemePalette(
          primary: Color(0xFF00E676),
          primaryContainer: Color(0x2600E676),
          onPrimaryContainer: Color(0xFF00E676),
          secondary: Color(0xFF00C853),
          secondaryContainer: Color(0x2600C853),
          background: Color(0xFF07140E),
          backgroundElevated: Color(0xFF0E2419),
          surface: Color(0xFF153625),
          surfaceElevated: Color(0xFF1D4A33),
          surfaceVariant: Color(0xFF19402C),
          card: Color(0xFF122E20),
          glassSurface: Color(0x1A00E676),
          glassBorder: Color(0x3300E676),
          divider: Color(0x2600E676),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xB3FFFFFF),
          textMuted: Color(0x80FFFFFF),
          operatorBg: Color(0x2600E676),
          operatorText: Color(0xFF00E676),
          equalsBg: Color(0xFF00E676),
          equalsText: Color(0xFF07140E),
          actionBg: Color(0x26FF1744),
          actionText: Color(0xFFFF5252),
          secondaryButtonBg: Color(0xFF153625),
          secondaryButtonText: Color(0xB3FFFFFF),
          numButtonBg: Color(0xFF1D4A33),
          numButtonText: Color(0xFFFFFFFF),
          inputBg: Color(0xFF1D4A33),
          inputBorder: Color(0x3300E676),
          inputBorderFocused: Color(0xFF00E676),
        );
      case KColorTheme.royalPurple:
        return const KThemePalette(
          primary: Color(0xFFB388FF),
          primaryContainer: Color(0x26B388FF),
          onPrimaryContainer: Color(0xFFB388FF),
          secondary: Color(0xFF7C4DFF),
          secondaryContainer: Color(0x267C4DFF),
          background: Color(0xFF0E0919),
          backgroundElevated: Color(0xFF1A112E),
          surface: Color(0xFF281A45),
          surfaceElevated: Color(0xFF37245E),
          surfaceVariant: Color(0xFF302052),
          card: Color(0xFF23163E),
          glassSurface: Color(0x1AB388FF),
          glassBorder: Color(0x33B388FF),
          divider: Color(0x26B388FF),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xB3FFFFFF),
          textMuted: Color(0x80FFFFFF),
          operatorBg: Color(0x26B388FF),
          operatorText: Color(0xFFB388FF),
          equalsBg: Color(0xFFB388FF),
          equalsText: Color(0xFF0E0919),
          actionBg: Color(0x26FF1744),
          actionText: Color(0xFFFF5252),
          secondaryButtonBg: Color(0xFF281A45),
          secondaryButtonText: Color(0xB3FFFFFF),
          numButtonBg: Color(0xFF37245E),
          numButtonText: Color(0xFFFFFFFF),
          inputBg: Color(0xFF37245E),
          inputBorder: Color(0x33B388FF),
          inputBorderFocused: Color(0xFFB388FF),
        );
    }
  }

  KThemePalette get lightPalette {
    switch (this) {
      case KColorTheme.kreateBlue:
        return const KThemePalette(
          primary: Color(0xFF0091EA),
          primaryContainer: Color(0xFFE1F5FE),
          onPrimaryContainer: Color(0xFF01579B),
          secondary: Color(0xFF3D5AFE),
          secondaryContainer: Color(0xFFE8EAF6),
          background: Color(0xFFF3F6FA),
          backgroundElevated: Color(0xFFE8EEF5),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFF0F4F9),
          surfaceVariant: Color(0xFFE2E8F0),
          card: Color(0xFFFFFFFF),
          glassSurface: Color(0x15007AFF),
          glassBorder: Color(0x25007AFF),
          divider: Color(0x1A007AFF),
          textPrimary: Color(0xFF0B132B),
          textSecondary: Color(0xFF475569),
          textMuted: Color(0xFF94A3B8),
          operatorBg: Color(0xFFE0F7FA),
          operatorText: Color(0xFF00838F),
          equalsBg: Color(0xFF0091EA),
          equalsText: Color(0xFFFFFFFF),
          actionBg: Color(0xFFFFEBEE),
          actionText: Color(0xFFD32F2F),
          secondaryButtonBg: Color(0xFFF0F4F9),
          secondaryButtonText: Color(0xFF475569),
          numButtonBg: Color(0xFFFFFFFF),
          numButtonText: Color(0xFF0B132B),
          inputBg: Color(0xFFFFFFFF),
          inputBorder: Color(0x25007AFF),
          inputBorderFocused: Color(0xFF0091EA),
        );
      case KColorTheme.classic:
        return const KThemePalette(
          primary: Color(0xFF18181B),
          primaryContainer: Color(0xFFE4E4E7),
          onPrimaryContainer: Color(0xFF18181B),
          secondary: Color(0xFF71717A),
          secondaryContainer: Color(0xFFF4F4F5),
          background: Color(0xFFF4F4F5),
          backgroundElevated: Color(0xFFE4E4E7),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFF4F4F5),
          surfaceVariant: Color(0xFFE4E4E7),
          card: Color(0xFFFFFFFF),
          glassSurface: Color(0x10000000),
          glassBorder: Color(0x20000000),
          divider: Color(0x15000000),
          textPrimary: Color(0xFF18181B),
          textSecondary: Color(0xFF52525B),
          textMuted: Color(0xFFA1A1AA),
          operatorBg: Color(0xFFE4E4E7),
          operatorText: Color(0xFF18181B),
          equalsBg: Color(0xFF18181B),
          equalsText: Color(0xFFFFFFFF),
          actionBg: Color(0xFFFFEBEE),
          actionText: Color(0xFFD32F2F),
          secondaryButtonBg: Color(0xFFF4F4F5),
          secondaryButtonText: Color(0xFF52525B),
          numButtonBg: Color(0xFFFFFFFF),
          numButtonText: Color(0xFF18181B),
          inputBg: Color(0xFFFFFFFF),
          inputBorder: Color(0x20000000),
          inputBorderFocused: Color(0xFF18181B),
        );
      case KColorTheme.solarYellow:
        return const KThemePalette(
          primary: Color(0xFFD79B00),
          primaryContainer: Color(0xFFFFF8E1),
          onPrimaryContainer: Color(0xFFF57F17),
          secondary: Color(0xFFE5A100),
          secondaryContainer: Color(0xFFFFFDE7),
          background: Color(0xFFFDFCF5),
          backgroundElevated: Color(0xFFF7F4E6),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFFBF8EB),
          surfaceVariant: Color(0xFFF3EED8),
          card: Color(0xFFFFFFFF),
          glassSurface: Color(0x15D79B00),
          glassBorder: Color(0x25D79B00),
          divider: Color(0x1AD79B00),
          textPrimary: Color(0xFF2C2405),
          textSecondary: Color(0xFF6B5B1E),
          textMuted: Color(0xFFA8985B),
          operatorBg: Color(0xFFFFF9C4),
          operatorText: Color(0xFFF57F17),
          equalsBg: Color(0xFFD79B00),
          equalsText: Color(0xFFFFFFFF),
          actionBg: Color(0xFFFFEBEE),
          actionText: Color(0xFFD32F2F),
          secondaryButtonBg: Color(0xFFFBF8EB),
          secondaryButtonText: Color(0xFF6B5B1E),
          numButtonBg: Color(0xFFFFFFFF),
          numButtonText: Color(0xFF2C2405),
          inputBg: Color(0xFFFFFFFF),
          inputBorder: Color(0x25D79B00),
          inputBorderFocused: Color(0xFFD79B00),
        );
      case KColorTheme.rosePink:
        return const KThemePalette(
          primary: Color(0xFFD81B60),
          primaryContainer: Color(0xFFFCE4EC),
          onPrimaryContainer: Color(0xFF880E4F),
          secondary: Color(0xFFC2185B),
          secondaryContainer: Color(0xFFF8BBD0),
          background: Color(0xFFFDF5F8),
          backgroundElevated: Color(0xFFF9E8F0),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFFDF0F6),
          surfaceVariant: Color(0xFFF6DEEA),
          card: Color(0xFFFFFFFF),
          glassSurface: Color(0x15D81B60),
          glassBorder: Color(0x25D81B60),
          divider: Color(0x1AD81B60),
          textPrimary: Color(0xFF2E0A1A),
          textSecondary: Color(0xFF6B2848),
          textMuted: Color(0xFFA86384),
          operatorBg: Color(0xFFFCE4EC),
          operatorText: Color(0xFFC2185B),
          equalsBg: Color(0xFFD81B60),
          equalsText: Color(0xFFFFFFFF),
          actionBg: Color(0xFFFFEBEE),
          actionText: Color(0xFFD32F2F),
          secondaryButtonBg: Color(0xFFFDF0F6),
          secondaryButtonText: Color(0xFF6B2848),
          numButtonBg: Color(0xFFFFFFFF),
          numButtonText: Color(0xFF2E0A1A),
          inputBg: Color(0xFFFFFFFF),
          inputBorder: Color(0x25D81B60),
          inputBorderFocused: Color(0xFFD81B60),
        );
      case KColorTheme.emeraldGreen:
        return const KThemePalette(
          primary: Color(0xFF00A854),
          primaryContainer: Color(0xFFE8F5E9),
          onPrimaryContainer: Color(0xFF1B5E20),
          secondary: Color(0xFF008C45),
          secondaryContainer: Color(0xFFC8E6C9),
          background: Color(0xFFF2FAF5),
          backgroundElevated: Color(0xFFE3F5EC),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFEBF7F0),
          surfaceVariant: Color(0xFFD8EFE2),
          card: Color(0xFFFFFFFF),
          glassSurface: Color(0x1500A854),
          glassBorder: Color(0x2500A854),
          divider: Color(0x1A00A854),
          textPrimary: Color(0xFF052414),
          textSecondary: Color(0xFF1E5C3C),
          textMuted: Color(0xFF5B9977),
          operatorBg: Color(0xFFE8F5E9),
          operatorText: Color(0xFF008C45),
          equalsBg: Color(0xFF00A854),
          equalsText: Color(0xFFFFFFFF),
          actionBg: Color(0xFFFFEBEE),
          actionText: Color(0xFFD32F2F),
          secondaryButtonBg: Color(0xFFEBF7F0),
          secondaryButtonText: Color(0xFF1E5C3C),
          numButtonBg: Color(0xFFFFFFFF),
          numButtonText: Color(0xFF052414),
          inputBg: Color(0xFFFFFFFF),
          inputBorder: Color(0x2500A854),
          inputBorderFocused: Color(0xFF00A854),
        );
      case KColorTheme.royalPurple:
        return const KThemePalette(
          primary: Color(0xFF651FFF),
          primaryContainer: Color(0xFFEDE7F6),
          onPrimaryContainer: Color(0xFF311B92),
          secondary: Color(0xFF7C4DFF),
          secondaryContainer: Color(0xFFD1C4E9),
          background: Color(0xFFF7F4FD),
          backgroundElevated: Color(0xFFEEE8FA),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFF4EEFC),
          surfaceVariant: Color(0xFFE7DCF8),
          card: Color(0xFFFFFFFF),
          glassSurface: Color(0x15651FFF),
          glassBorder: Color(0x25651FFF),
          divider: Color(0x1A651FFF),
          textPrimary: Color(0xFF170830),
          textSecondary: Color(0xFF4C307B),
          textMuted: Color(0xFF866EAE),
          operatorBg: Color(0xFFEDE7F6),
          operatorText: Color(0xFF651FFF),
          equalsBg: Color(0xFF651FFF),
          equalsText: Color(0xFFFFFFFF),
          actionBg: Color(0xFFFFEBEE),
          actionText: Color(0xFFD32F2F),
          secondaryButtonBg: Color(0xFFF4EEFC),
          secondaryButtonText: Color(0xFF4C307B),
          numButtonBg: Color(0xFFFFFFFF),
          numButtonText: Color(0xFF170830),
          inputBg: Color(0xFFFFFFFF),
          inputBorder: Color(0x25651FFF),
          inputBorderFocused: Color(0xFF651FFF),
        );
    }
  }

  KThemePalette palette(Brightness brightness) =>
      brightness == Brightness.dark ? darkPalette : lightPalette;
}
