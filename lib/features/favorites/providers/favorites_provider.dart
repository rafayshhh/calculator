import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  static const String boxName = 'kreate_favorites_box';
  static const String key = 'favorite_tool_ids';

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (_) {}
  }

  @override
  Set<String> build() {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final raw = box.get(key, defaultValue: <dynamic>[]) as List<dynamic>?;
        if (raw != null) {
          return raw.map((e) => e.toString()).toSet();
        }
      }
    } catch (_) {}
    return <String>{};
  }

  Future<void> toggleFavorite(String toolId) async {
    final next = Set<String>.from(state);
    if (next.contains(toolId)) {
      next.remove(toolId);
    } else {
      next.add(toolId);
    }
    state = next;
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.put(key, next.toList());
      }
    } catch (_) {}
  }

  bool isFavorite(String toolId) => state.contains(toolId);

  Future<void> clearAll() async {
    state = <String>{};
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.delete(key);
      }
    } catch (_) {}
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
