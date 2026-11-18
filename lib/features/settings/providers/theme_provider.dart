import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/k_color_theme.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String boxName = 'kreate_settings_box';
  static const String key = 'theme_mode';

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (_) {}
  }

  @override
  ThemeMode build() {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final raw = box.get(key, defaultValue: 'system') as String?;
        return ThemeMode.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {}
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.put(key, mode.name);
      }
    } catch (_) {}
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ColorThemeNotifier extends Notifier<KColorTheme> {
  static const String boxName = 'kreate_settings_box';
  static const String key = 'color_theme';

  @override
  KColorTheme build() {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final raw = box.get(key, defaultValue: 'kreateBlue') as String?;
        return KColorTheme.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => KColorTheme.kreateBlue,
        );
      }
    } catch (_) {}
    return KColorTheme.kreateBlue;
  }

  Future<void> setColorTheme(KColorTheme colorTheme) async {
    state = colorTheme;
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.put(key, colorTheme.name);
      }
    } catch (_) {}
  }
}

final colorThemeProvider =
    NotifierProvider<ColorThemeNotifier, KColorTheme>(ColorThemeNotifier.new);
