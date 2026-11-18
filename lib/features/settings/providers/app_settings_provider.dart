import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../calculator/domain/math_engine.dart';

class AppSettingsState {
  final int decimalPrecision; // -1 for Auto / Floating, or 2, 4, 6, 8, 10, 12
  final AngleMode defaultAngleMode;
  final bool useThousandsSeparator;
  final int historyLimit;

  const AppSettingsState({
    this.decimalPrecision = -1,
    this.defaultAngleMode = AngleMode.degrees,
    this.useThousandsSeparator = true,
    this.historyLimit = 100,
  });

  String get precisionLabel {
    if (decimalPrecision == -1) return 'Auto (Floating)';
    return '$decimalPrecision Decimals';
  }

  String get angleModeLabel {
    switch (defaultAngleMode) {
      case AngleMode.degrees:
        return 'Degrees (DEG)';
      case AngleMode.radians:
        return 'Radians (RAD)';
      case AngleMode.gradians:
        return 'Gradians (GRAD)';
    }
  }

  AppSettingsState copyWith({
    int? decimalPrecision,
    AngleMode? defaultAngleMode,
    bool? useThousandsSeparator,
    int? historyLimit,
  }) {
    return AppSettingsState(
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      defaultAngleMode: defaultAngleMode ?? this.defaultAngleMode,
      useThousandsSeparator:
          useThousandsSeparator ?? this.useThousandsSeparator,
      historyLimit: historyLimit ?? this.historyLimit,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  static const String boxName = 'kreate_settings_box';
  static const String precisionKey = 'calc_decimal_precision';
  static const String angleModeKey = 'calc_default_angle_mode';
  static const String thousandsKey = 'calc_thousands_separator';
  static const String historyLimitKey = 'calc_history_limit';

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (_) {}
  }

  @override
  AppSettingsState build() {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final precision = box.get(precisionKey, defaultValue: -1) as int;
        final angleRaw =
            box.get(angleModeKey, defaultValue: 'degrees') as String;
        final angle = AngleMode.values.firstWhere(
          (e) => e.name == angleRaw,
          orElse: () => AngleMode.degrees,
        );
        final thousands = box.get(thousandsKey, defaultValue: true) as bool;
        final historyLimit =
            box.get(historyLimitKey, defaultValue: 100) as int;

        return AppSettingsState(
          decimalPrecision: precision,
          defaultAngleMode: angle,
          useThousandsSeparator: thousands,
          historyLimit: historyLimit,
        );
      }
    } catch (_) {}

    return const AppSettingsState();
  }

  Future<void> setDecimalPrecision(int precision) async {
    state = state.copyWith(decimalPrecision: precision);
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).put(precisionKey, precision);
      }
    } catch (_) {}
  }

  Future<void> setDefaultAngleMode(AngleMode mode) async {
    state = state.copyWith(defaultAngleMode: mode);
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).put(angleModeKey, mode.name);
      }
    } catch (_) {}
  }

  Future<void> setThousandsSeparator(bool enabled) async {
    state = state.copyWith(useThousandsSeparator: enabled);
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).put(thousandsKey, enabled);
      }
    } catch (_) {}
  }

  Future<void> setHistoryLimit(int limit) async {
    state = state.copyWith(historyLimit: limit);
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).put(historyLimitKey, limit);
      }
    } catch (_) {}
  }

  Future<void> resetToDefaults() async {
    state = const AppSettingsState();
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.delete(precisionKey);
        await box.delete(angleModeKey);
        await box.delete(thousandsKey);
        await box.delete(historyLimitKey);
      }
    } catch (_) {}
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
  AppSettingsNotifier.new,
);
