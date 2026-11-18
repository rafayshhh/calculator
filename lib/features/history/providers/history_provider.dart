import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/history_entry.dart';
import '../data/history_repository.dart';

class HistoryNotifier extends Notifier<List<HistoryEntryV2>> {
  @override
  List<HistoryEntryV2> build() {
    try {
      return ref.watch(historyRepositoryProvider).getEntries();
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(
    String expression,
    String result, {
    String? toolRoute,
    String? toolStateJson,
  }) async {
    final entry = HistoryEntryV2(
      id: const Uuid().v4(),
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
      toolRoute: toolRoute,
      toolStateJson: toolStateJson,
    );
    try {
      await ref.read(historyRepositoryProvider).addEntry(entry);
      state = [entry, ...state];
    } catch (_) {
      state = [entry, ...state];
    }
  }

  Future<void> delete(String id) async {
    try {
      await ref.read(historyRepositoryProvider).deleteEntry(id);
      state = state.where((e) => e.id != id).toList();
    } catch (_) {
      state = state.where((e) => e.id != id).toList();
    }
  }

  Future<void> clear() async {
    try {
      await ref.read(historyRepositoryProvider).clearAll();
      state = const [];
    } catch (_) {
      state = const [];
    }
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntryV2>>(
  () {
    return HistoryNotifier();
  },
);
