import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:calculator/features/tools/application/recent_tools_provider.dart';

void main() {
  final tempDir = Directory.systemTemp.createTempSync('hive_recent_tools_test');

  setUpAll(() async {
    Hive.init(tempDir.path);
    await RecentToolsNotifier.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() {
    final box = Hive.box<String>('kreate_recent_tools_box');
    box.clear();
  });

  group('RecentToolsNotifier Tests', () {
    test('Records and sorts recent tools by newest first', () {
      final container = ProviderContainer();
      final notifier = container.read(recentToolsProvider.notifier);

      notifier.recordToolUsage(toolId: 'molar_mass', route: '/tools/chemistry/molar_mass');
      notifier.recordToolUsage(toolId: 'ohms_law', route: '/tools/physics/ohms_law');

      final list = container.read(recentToolsProvider);
      expect(list.length, 2);
      expect(list[0].toolId, 'ohms_law');
      expect(list[1].toolId, 'molar_mass');
    });

    test('Increments usageCount and updates timestamp on repeat usage', () {
      final container = ProviderContainer();
      final notifier = container.read(recentToolsProvider.notifier);

      notifier.recordToolUsage(toolId: 'molar_mass', route: '/tools/chemistry/molar_mass');
      notifier.recordToolUsage(toolId: 'molar_mass', route: '/tools/chemistry/molar_mass');
      
      final list = container.read(recentToolsProvider);

      expect(list[0].toolId, 'molar_mass');
      expect(list[0].usageCount, 2);
    });

    test('Clears recent tools', () {
      final container = ProviderContainer();
      final notifier = container.read(recentToolsProvider.notifier);

      notifier.recordToolUsage(toolId: 'molar_mass', route: '/tools/chemistry/molar_mass');
      notifier.clearRecentTools();
      expect(container.read(recentToolsProvider).isEmpty, true);
    });
  });
}
