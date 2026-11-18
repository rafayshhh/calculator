import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/k_page_container.dart';
import '../../../favorites/providers/favorites_provider.dart';
import '../../../history/providers/history_provider.dart';

class DataSettingsScreen extends ConsumerWidget {
  const DataSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);
    final historyEntries = ref.watch(historyProvider);
    final favorites = ref.watch(favoritesProvider);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('Data & Storage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(KSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'LOCAL STORAGE',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: primaryColor),
                    const SizedBox(width: KSpacing.md),
                    Text(
                      '100% Offline & Private',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSpacing.xs),
                Text(
                  'All calculation logs, pinned tools, and preferences are stored exclusively on your local device via Hive. No telemetries or cloud servers are contacted.',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'CALCULATION HISTORY',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Calculations',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${historyEntries.length} items logged',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear'),
                  onPressed: historyEntries.isEmpty
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear History?'),
                              content: const Text(
                                  'Are you sure you want to permanently erase all saved calculation history?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Clear All',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(historyProvider.notifier).clearAll();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('History cleared')),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'PINNED FAVORITES',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite Tools',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${favorites.length} tools starred',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                    foregroundColor: Colors.amber[800] ?? Colors.amber,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Reset'),
                  onPressed: favorites.isEmpty
                      ? null
                      : () async {
                          await ref.read(favoritesProvider.notifier).clearAll();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Favorites reset')),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
