import 'package:hive/hive.dart';
import '../../../core/services/kreate_logger.dart';
import '../domain/history_entry.dart';

class HistoryMigrationService {
  HistoryMigrationService._();

  static const String oldBoxName = 'kreate_history_box';
  static const String newBoxName = 'kreate_history_box_v2';

  static Future<void> runMigration() async {
    try {
      final oldExists = await Hive.boxExists(oldBoxName);
      if (!oldExists) return;

      KreateLogger.info('Starting history migration from V1 to V2...');
      final oldBox = await Hive.openBox<HistoryEntry>(oldBoxName);
      final newBox = await Hive.openBox<HistoryEntryV2>(newBoxName);

      if (oldBox.isNotEmpty) {
        for (final entry in oldBox.values) {
          final v2Entry = HistoryEntryV2(
            id: entry.id,
            expression: entry.expression,
            result: entry.result,
            timestamp: entry.timestamp,
          );
          await newBox.put(v2Entry.id, v2Entry);
        }
        KreateLogger.info('Migrated ${oldBox.length} entries to V2 history box.');
      }

      await oldBox.close();
      await Hive.deleteBoxFromDisk(oldBoxName);
      KreateLogger.info('Old history box cleaned up.');
    } catch (e, st) {
      KreateLogger.error('Error during history migration: $e', e, st);
    }
  }
}
