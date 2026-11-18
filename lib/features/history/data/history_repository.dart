import 'package:hive/hive.dart';

import '../domain/history_entry.dart';

abstract class HistoryRepository {
  Future<void> addEntry(HistoryEntryV2 entry);
  Future<void> deleteEntry(String id);
  Future<void> clearAll();
  List<HistoryEntryV2> getEntries();
}

class HiveHistoryRepository implements HistoryRepository {
  final Box<HistoryEntryV2>? _box;

  HiveHistoryRepository(this._box);

  @override
  Future<void> addEntry(HistoryEntryV2 entry) async {
    await _box?.put(entry.id, entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _box?.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _box?.clear();
  }

  @override
  List<HistoryEntryV2> getEntries() {
    final box = _box;
    if (box == null) return const [];
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
