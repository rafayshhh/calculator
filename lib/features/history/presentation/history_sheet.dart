import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/utils/web_state_serializer.dart';
import '../../../core/widgets/k_empty_state.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../../calculator/providers/calculator_provider.dart';
import '../../share/presentation/dialogs/share_image_preview_dialog.dart';
import '../../tools/application/tool_share_adapter.dart';
import '../domain/history_entry.dart';
import '../providers/history_provider.dart';

class HistorySheet extends ConsumerWidget {
  const HistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    if (isDesktop) {
      return showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: const HistorySheet(),
          ),
        ),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.85,
          child: const HistorySheet(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final feedback = ref.watch(feedbackProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimaryColor = KColors.textPrimaryAdaptive(context);
    final textMutedColor = KColors.textMutedAdaptive(context);
    final sheetBg = isDark
        ? KColors.backgroundElevatedDark
        : KColors.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? KColors.glassBorderDark : KColors.glassBorderLight,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KSpacing.md,
              KSpacing.md,
              KSpacing.sm,
              KSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: primaryColor),
                    const SizedBox(width: KSpacing.sm),
                    Text(
                      'Calculation History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (history.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: KColors.error,
                        ),
                        onPressed: () => _showClearDialog(context, ref),
                        tooltip: 'Clear History',
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: textMutedColor),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? KColors.glassBorderDark : KColors.glassBorderLight,
            height: 1,
          ),
          Expanded(
            child: history.isEmpty
                ? const KEmptyState(
                    icon: Icons.history_rounded,
                    title: 'No calculations yet',
                    description: 'Your calculations and formulas from any calculator will appear here automatically.',
                  ).animate().fadeIn()
                : ListView.separated(
                    padding: const EdgeInsets.all(KSpacing.md),
                    itemCount: history.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: KSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return Dismissible(
                        key: Key(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: KSpacing.lg),
                          decoration: BoxDecoration(
                            color: KColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: KColors.error),
                        ),
                        onDismissed: (_) {
                          FeedbackService.selection(feedback);
                          ref.read(historyProvider.notifier).delete(entry.id);
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              FeedbackService.toolSelect(feedback);
                              _onEntryTap(context, ref, entry);
                            },
                            child: KGlassCard(
                              padding: const EdgeInsets.all(KSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (entry.toolRoute != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Tool',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                      Expanded(
                                        child: Text(
                                          entry.expression,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            color: entry.toolRoute != null
                                                ? primaryColor
                                                : (isDark
                                                      ? KColors
                                                            .textSecondaryDark
                                                      : KColors
                                                            .textSecondaryLight),
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: KSpacing.xs),
                                  Text(
                                    entry.result,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimaryColor,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: KSpacing.xs),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(entry.timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textMutedColor,
                                        ),
                                      ),
                                      // Entry Actions: Copy & Share as Image
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.copy_rounded,
                                              size: 16,
                                            ),
                                            color: textMutedColor,
                                            tooltip: 'Copy result',
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              FeedbackService.selection(
                                                feedback,
                                              );
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: entry.result,
                                                ),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Copied: ${entry.result}',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.image_outlined,
                                              size: 16,
                                            ),
                                            color: textMutedColor,
                                            tooltip: 'Share as Image',
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              FeedbackService.toolSelect(
                                                feedback,
                                              );
                                              final shareData =
                                                  ToolShareAdapter.fromHistoryEntry(
                                                    entry,
                                                    context: context,
                                                  );
                                              ShareImagePreviewDialog.show(
                                                context,
                                                shareData,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _onEntryTap(BuildContext context, WidgetRef ref, HistoryEntryV2 entry) {
    if (entry.toolRoute != null) {
      // Capture router before pop — context is deactivated after the sheet closes
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      if (entry.toolStateJson != null) {
        final encodedState = WebStateSerializer.encodeState(
          entry.toolStateJson!,
        );
        final uri = Uri(
          path: entry.toolRoute!,
          queryParameters: {'state': encodedState},
        );
        router.go(uri.toString());
      } else {
        router.go(entry.toolRoute!);
      }
    } else {
      ref.read(calculatorProvider.notifier).clear();
      ref.read(calculatorProvider.notifier).append(entry.result);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (isToday) {
      return 'Today · $time';
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} · $time';
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark
              ? KColors.surfaceElevatedDark
              : KColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark
                  ? KColors.glassBorderDark
                  : KColors.glassBorderLight,
              width: 1,
            ),
          ),
          title: Text(
            'Clear History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? KColors.textPrimaryDark
                  : KColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'Are you sure you want to delete all calculation history?\nThis action cannot be undone.',
            style: TextStyle(
              color: isDark
                  ? KColors.textSecondaryDark
                  : KColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? KColors.textSecondaryDark
                      : KColors.textSecondaryLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(historyProvider.notifier).clear();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KColors.error.withValues(alpha: 0.2),
                foregroundColor: KColors.error,
                elevation: 0,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
