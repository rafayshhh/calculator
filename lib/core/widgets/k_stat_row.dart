import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';

/// Reusable key-value metric row for secondary results, parameter summaries,
/// and financial/engineering breakdowns.
class KStatRow extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? tooltip;
  final bool isHighlighted;

  const KStatRow({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.tooltip,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryAccent = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);
    final textMuted = KColors.textMutedAdaptive(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isHighlighted ? primaryAccent : textSecondary,
                      fontSize: 13,
                      fontWeight: isHighlighted
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (tooltip != null) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: tooltip!,
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: KSpacing.sm),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isHighlighted ? primaryAccent : textPrimary,
                      fontSize: isHighlighted ? 15 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
