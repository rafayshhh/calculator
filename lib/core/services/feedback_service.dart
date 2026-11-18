import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum FeedbackIntensity {
  off('Off'),
  light('Light'),
  medium('Medium'),
  strong('Strong');

  final String label;
  const FeedbackIntensity(this.label);
}

class FeedbackService {
  FeedbackService._();

  static void buttonPress([dynamic intensity]) {
    if (_isOff(intensity)) return;
    HapticFeedback.lightImpact();
  }

  static void operatorPress([dynamic intensity]) {
    if (_isOff(intensity)) return;
    HapticFeedback.mediumImpact();
  }

  static void selection([dynamic intensity]) {
    if (_isOff(intensity)) return;
    HapticFeedback.selectionClick();
  }

  static void toolSelect([dynamic intensity]) {
    if (_isOff(intensity)) return;
    HapticFeedback.selectionClick();
  }

  static void settingChange([dynamic intensity]) {
    if (_isOff(intensity)) return;
    HapticFeedback.selectionClick();
  }

  static void error([dynamic intensity]) {
    if (_isOff(intensity)) return;
    HapticFeedback.heavyImpact();
  }

  static bool _isOff(dynamic intensity) {
    if (intensity is FeedbackIntensity) {
      return intensity == FeedbackIntensity.off;
    }
    return false;
  }
}

class FeedbackNotifier extends Notifier<FeedbackIntensity> {
  static const String boxName = 'kreate_settings_box';
  static const String key = 'feedback_intensity';

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (_) {}
  }

  @override
  FeedbackIntensity build() {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final raw = box.get(key, defaultValue: 'medium') as String?;
        return FeedbackIntensity.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => FeedbackIntensity.medium,
        );
      }
    } catch (_) {}
    return FeedbackIntensity.medium;
  }

  Future<void> setIntensity(FeedbackIntensity intensity) async {
    state = intensity;
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.put(key, intensity.name);
      }
    } catch (_) {}
  }
}

final feedbackProvider =
    NotifierProvider<FeedbackNotifier, FeedbackIntensity>(FeedbackNotifier.new);
