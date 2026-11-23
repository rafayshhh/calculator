import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../lib/features/settings/presentation/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('test_settings_overhaul_');
    Hive.init(tempDir.path);
    await Hive.openBox('kreate_settings_box');
    await Hive.openBox('kreate_favorites_box');
    await Hive.openBox('kreate_history_box_v2');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SettingsScreen Overhaul & Creator Credits Tests', () {
    testWidgets('SettingsScreen renders calculation settings and creator credits', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );
      await tester.pumpAndSettle();

      // App Branding & Version
      expect(find.text('Calculator'), findsWidgets);
      expect(find.text('Calculator Version 1.0'), findsOneWidget);

      // Appearance & Theme
      expect(find.text('APPEARANCE & THEME'), findsOneWidget);
      expect(find.text('Display Mode'), findsOneWidget);
      expect(find.text('Color Themes'), findsOneWidget);
      expect(find.text('Electric Cyan'), findsOneWidget);
      expect(find.text('Emerald Mint'), findsOneWidget);
      expect(find.text('Royal Violet'), findsOneWidget);

      // Publisher & Developer
      expect(find.text('PUBLISHER & DEVELOPER'), findsOneWidget);
      expect(find.text('Publisher'), findsOneWidget);
      expect(find.text('KreateKode'), findsOneWidget);
      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('RafayShhh (Muhammad Abdul Rafay)'), findsOneWidget);

      // Social Links & Repository
      expect(find.text('SOCIAL LINKS & REPOSITORY'), findsOneWidget);
      expect(find.text('GitHub Repository'), findsOneWidget);
      expect(find.text('github.com/rafayshhh/calculator'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('@kreatekode'), findsOneWidget);
      expect(find.text('GitHub Profile'), findsOneWidget);
      expect(find.text('@rafayshhh'), findsOneWidget);
      expect(find.text('Official Website'), findsOneWidget);
      expect(find.text('kreatekode.website'), findsOneWidget);

      // Verify ZERO licenses or legal boilerplate
      expect(find.text('Software License'), findsNothing);
      expect(find.text('MIT License'), findsNothing);
      expect(find.text('Terms of Service'), findsNothing);
    });
  });
}
