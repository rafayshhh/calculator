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

      // Calculation Engine sections
      expect(find.text('CALCULATION ENGINE'), findsOneWidget);
      expect(find.text('Decimal Precision'), findsOneWidget);
      expect(find.text('Angle Mode'), findsOneWidget);
      expect(find.text('Thousands Separator'), findsOneWidget);

      // Appearance & Feedback
      expect(find.text('APPEARANCE & THEME'), findsOneWidget);
      expect(find.text('INTERACTION & FEEDBACK'), findsOneWidget);
      expect(find.text('STORAGE & HISTORY'), findsOneWidget);

      // Creator & Community
      expect(find.text('CREATOR & COMMUNITY'), findsOneWidget);
      expect(find.text('Muhammad Abdul Rafay'), findsOneWidget);
      expect(find.textContaining('Instagram: @kreatekode'), findsOneWidget);
      expect(find.textContaining('GitHub: @rafayshhh'), findsOneWidget);
      expect(find.textContaining('Google Play Store: KreateKode'), findsOneWidget);
      expect(find.textContaining('Website: kreatekode.website'), findsOneWidget);

      // Application info
      expect(find.text('About Calculator'), findsOneWidget);
      expect(find.text('Source Code Repository'), findsOneWidget);

      // Verify ZERO licenses or legal boilerplate
      expect(find.text('Software License'), findsNothing);
      expect(find.text('MIT License'), findsNothing);
      expect(find.text('Terms of Service'), findsNothing);
    });
  });
}
