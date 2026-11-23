import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Calculation History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All History?'),
                    content: const Text('This action will permanently delete all saved calculations.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          notifier.clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: KSpacing.md),
                    Text('No calculations yet', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Completed calculations will appear here', style: TextStyle(color: textSecondary, fontSize: 13)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(KSpacing.md),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: KSpacing.sm),
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final timeStr = DateFormat('MMM d, h:mm a').format(entry.timestamp);

                  return KGlassCard(
                    padding: const EdgeInsets.all(KSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.toolRoute != null ? 'SPECIALIZED TOOL' : timeStr,
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  color: textSecondary,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: '${entry.expression} = ${entry.result}'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Copied calculation to clipboard'), duration: Duration(seconds: 1)),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  color: textSecondary,
                                  onPressed: () => notifier.delete(entry.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SelectableText(
                          entry.expression,
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          '= ${entry.result}',
                          style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
