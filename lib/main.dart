import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/theme/k_theme.dart';
import 'features/history/domain/history_entry.dart';
import 'features/history/data/history_repository.dart';
import 'features/history/data/history_migration_service.dart';
import 'features/history/providers/history_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/calculator/providers/calculator_provider.dart';
import 'features/tools/application/recent_tools_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/settings/providers/app_settings_provider.dart';
import 'core/services/feedback_service.dart';
import 'core/services/kreate_logger.dart';
import 'app/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    Hive.registerAdapter(HistoryEntryAdapter());
    Hive.registerAdapter(HistoryEntryV2Adapter());
  } catch (e, st) {
    KreateLogger.error('Hive initialization error: $e', e, st);
  }

  try {
    await HistoryMigrationService.runMigration();
  } catch (e, st) {
    KreateLogger.error('History migration error: $e', e, st);
  }

  try {
    await ThemeNotifier.init();
    await AppSettingsNotifier.init();
    await FeedbackNotifier.init();
    await FavoritesNotifier.init();
    await RecentToolsNotifier.init();
    await CalculatorNotifier.init();
  } catch (e, st) {
    KreateLogger.error('Notifier initialization error: $e', e, st);
  }

  Box<HistoryEntryV2>? newBox;
  try {
    newBox = await Hive.openBox<HistoryEntryV2>('kreate_history_box_v2');
  } catch (e, st) {
    KreateLogger.error('Failed to open history box: $e', e, st);
    try {
      await Hive.deleteBoxFromDisk('kreate_history_box_v2');
      newBox = await Hive.openBox<HistoryEntryV2>('kreate_history_box_v2');
    } catch (e2, st2) {
      KreateLogger.error('Failed to recover history box: $e2', e2, st2);
    }
  }

  final historyRepo = HiveHistoryRepository(newBox);

  runApp(
    ProviderScope(
      overrides: [historyRepositoryProvider.overrideWithValue(historyRepo)],
      child: const KreateCalculatorApp(),
    ),
  );
}

class KreateCalculatorApp extends ConsumerWidget {
  const KreateCalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final colorTheme = ref.watch(colorThemeProvider);

    return MaterialApp.router(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: KTheme.buildTheme(
        brightness: Brightness.light,
        colorTheme: colorTheme,
      ),
      darkTheme: KTheme.buildTheme(
        brightness: Brightness.dark,
        colorTheme: colorTheme,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
