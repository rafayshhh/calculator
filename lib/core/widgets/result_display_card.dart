import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import '../constants/k_radius.dart';
import 'k_glass_card.dart';
import '../../features/share/domain/calculation_share_data.dart';
import '../../features/share/presentation/dialogs/share_image_preview_dialog.dart';

class ResultDisplayCard extends StatelessWidget {
  final String label;
  final String? title;
  final String value;
  final String? secondaryLabel;
  final String? secondaryValue;
  final String? formula;
  final String? substitution;
  final String? details;
  final String? prefix;
  final String? suffix;
  final Widget? bottomContent;
  final bool isError;
  final VoidCallback? onShare;
  final VoidCallback? onReset;
  final VoidCallback? onCopy;

  const ResultDisplayCard({
    super.key,
    String? label,
    this.title,
    required this.value,
    this.secondaryLabel,
    this.secondaryValue,
    this.formula,
    this.substitution,
    this.details,
    this.prefix,
    this.suffix,
    this.bottomContent,
    this.isError = false,
    this.onShare,
    this.onReset,
    this.onCopy,
  }) : label = label ?? title ?? 'Result';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final errorColor = isDark ? KColors.error : Colors.red.shade700;
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    final displayVal = (prefix != null ? '$prefix ' : '') + value + (suffix != null ? ' $suffix' : '');

    return KGlassCard(
      padding: const EdgeInsets.all(KSpacing.md),
      borderColor: isError ? errorColor.withValues(alpha: 0.5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isError ? errorColor : primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isError && onCopy == null)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      color: textSecondary,
                      tooltip: 'Copy',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: displayVal));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    )
                  else if (onCopy != null)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      color: textSecondary,
                      tooltip: 'Copy',
                      onPressed: onCopy,
                    ),
                  if (!isError)
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 16),
                      color: textSecondary,
                      tooltip: 'Share as Image',
                      onPressed: onShare ??
                          () {
                            ShareImagePreviewDialog.show(
                              context,
                              CalculationShareData(
                                title: label,
                                expression: formula ?? label,
                                result: displayVal,
                                formula: formula,
                                substitution: substitution,
                                timestamp: DateTime.now(),
                              ),
                            );
                          },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: KSpacing.xs),
          SelectableText(
            displayVal,
            style: TextStyle(
              color: isError ? errorColor : textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (secondaryLabel != null && secondaryValue != null) ...[
            const SizedBox(height: KSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$secondaryLabel: ',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                Expanded(
                  child: Text(
                    secondaryValue!,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (formula != null) ...[
            const SizedBox(height: KSpacing.sm),
            Container(
              padding: const EdgeInsets.all(KSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.black12,
                borderRadius: KRadius.smRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formula!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (substitution != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      substitution!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (details != null) ...[
            const SizedBox(height: KSpacing.sm),
            Text(
              details!,
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
          if (bottomContent != null) ...[
            const SizedBox(height: KSpacing.sm),
            bottomContent!,
          ],
          if (onShare != null || onReset != null) ...[
            const SizedBox(height: KSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: KSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onReset != null)
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset'),
                  ),
                if (onShare != null) ...[
                  const SizedBox(width: KSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
