import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:calculator/app/theme/k_theme.dart';
import 'package:calculator/core/constants/k_color_theme.dart';
import 'package:calculator/core/theme/k_theme_extension.dart';
import 'package:calculator/features/settings/presentation/screens/theme_settings_screen.dart';

void main() {
  final tempDir = Directory.systemTemp.createTempSync('hive_theme_test');

  setUpAll(() async {
    Hive.init(tempDir.path);
    await Hive.openBox('kreate_settings_box');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() {
    Hive.box('kreate_settings_box').clear();
  });

  group('Global Theme Engine & Settings Tests', () {
    testWidgets('Renders ThemeSettingsScreen and switches color themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: KTheme.buildTheme(
              brightness: Brightness.dark,
              colorTheme: KColorTheme.kreateBlue,
            ),
            home: const Scaffold(
              body: ThemeSettingsScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Theme Settings'), findsOneWidget);
      expect(find.text('Appearance Mode'), findsOneWidget);
      expect(find.text('Color Identity'), findsOneWidget);
      expect(find.text('Solar Yellow'), findsOneWidget);
      expect(find.text('Emerald Green'), findsOneWidget);

      // Tap on Solar Yellow theme
      await tester.tap(find.text('Solar Yellow'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    test('All 12 theme variations produce non-null ThemeExtension and valid ColorSchemes', () {
      for (final colorTheme in KColorTheme.values) {
        for (final brightness in [Brightness.dark, Brightness.light]) {
          final themeData = KTheme.buildTheme(brightness: brightness, colorTheme: colorTheme);
          final ext = themeData.extension<KThemeColors>();
          expect(ext, isNotNull);
          expect(ext!.primary, isNotNull);
          expect(ext.palette.operatorBg, isNotNull);
          expect(ext.palette.equalsBg, isNotNull);
          expect(ext.palette.numButtonBg, isNotNull);
          expect(themeData.colorScheme.primary, ext.primary);
          expect(themeData.scaffoldBackgroundColor, ext.background);
        }
      }
    });
  });
}
