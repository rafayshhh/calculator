import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class RecentToolItem {
  final String toolId;
  final String route;
  final DateTime lastUsed;
  final int usageCount;

  const RecentToolItem({
    required this.toolId,
    required this.route,
    required this.lastUsed,
    this.usageCount = 1,
  });

  RecentToolItem copyWith({
    String? toolId,
    String? route,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return RecentToolItem(
      toolId: toolId ?? this.toolId,
      route: route ?? this.route,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'toolId': toolId,
        'route': route,
        'lastUsed': lastUsed.toIso8601String(),
        'usageCount': usageCount,
      };

  factory RecentToolItem.fromJson(Map<String, dynamic> json) => RecentToolItem(
        toolId: json['toolId'] as String,
        route: json['route'] as String,
        lastUsed: DateTime.parse(json['lastUsed'] as String),
        usageCount: json['usageCount'] as int? ?? 1,
      );
}

class RecentToolsNotifier extends Notifier<List<RecentToolItem>> {
  static const String boxName = 'kreate_recent_tools_box';

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<String>(boxName);
      }
    } catch (_) {}
  }

  @override
  List<RecentToolItem> build() {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<String>(boxName);
        final list = <RecentToolItem>[];
        for (final raw in box.values) {
          try {
            list.add(RecentToolItem.fromJson(jsonDecode(raw) as Map<String, dynamic>));
          } catch (_) {}
        }
        list.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
        return list;
      }
    } catch (_) {}
    return const [];
  }

  Future<void> recordToolUsage({
    required String toolId,
    required String route,
  }) async {
    final now = DateTime.now();
    final currentList = List<RecentToolItem>.from(state);
    final existingIndex = currentList.indexWhere((item) => item.toolId == toolId);

    RecentToolItem updated;
    if (existingIndex >= 0) {
      final old = currentList[existingIndex];
      updated = old.copyWith(
        lastUsed: now,
        usageCount: old.usageCount + 1,
        route: route,
      );
      currentList.removeAt(existingIndex);
    } else {
      updated = RecentToolItem(
        toolId: toolId,
        route: route,
        lastUsed: now,
        usageCount: 1,
      );
    }

    currentList.insert(0, updated);
    state = currentList;

    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<String>(boxName);
        await box.put(toolId, jsonEncode(updated.toJson()));
      }
    } catch (_) {}
  }

  Future<void> clearRecentTools() async {
    state = const [];
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<String>(boxName);
        await box.clear();
      }
    } catch (_) {}
  }
}

final recentToolsProvider =
    NotifierProvider<RecentToolsNotifier, List<RecentToolItem>>(
  RecentToolsNotifier.new,
);
