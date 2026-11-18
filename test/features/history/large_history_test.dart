import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/features/history/data/history_repository.dart';
import 'package:calculator/features/history/domain/history_entry.dart';
import 'package:calculator/features/history/providers/history_provider.dart';

void main() {
  group('History Performance & Large Dataset', () {
    late ProviderContainer container;
    late HistoryRepository repository;

    setUpAll(() async {
      Hive.init('.');
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HistoryEntryV2Adapter());
      }
      final box = await Hive.openBox<HistoryEntryV2>('test_large_history_box');
      await box.clear();
      repository = HiveHistoryRepository(box);
    });

    setUp(() {
      container = ProviderContainer(
        overrides: [historyRepositoryProvider.overrideWithValue(repository)],
      );
    });

    tearDownAll(() async {
      await Hive.box<HistoryEntryV2>('test_large_history_box').clear();
      await Hive.box<HistoryEntryV2>('test_large_history_box').close();
    });

    test('Add 1000 entries and verify prepend ordering', () async {
      final notifier = container.read(historyProvider.notifier);

      // Simulate adding 1000 entries
      for (int i = 0; i < 1000; i++) {
        await notifier.add('1+$i', '${1 + i}');
      }

      final state = container.read(historyProvider);
      expect(state.length, 1000);

      // The newest entry (999) should be at index 0 because of prepend
      expect(state.first.expression, '1+999');
      expect(state.first.result, '1000');

      // The oldest entry (0) should be at index 999
      expect(state.last.expression, '1+0');
      expect(state.last.result, '1');
    });

    test('Delete specific entry from large dataset', () async {
      final stateBefore = container.read(historyProvider);
      final entryToDelete = stateBefore[500]; // Middle entry

      final notifier = container.read(historyProvider.notifier);
      await notifier.delete(entryToDelete.id);

      final stateAfter = container.read(historyProvider);
      expect(stateAfter.length, 999);
      expect(stateAfter.any((e) => e.id == entryToDelete.id), false);
    });

    test('Clear large dataset works safely', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.clear();

      final stateAfter = container.read(historyProvider);
      expect(stateAfter.isEmpty, true);
    });
  });
}
