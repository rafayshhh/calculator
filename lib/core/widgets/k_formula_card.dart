import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import 'k_glass_card.dart';

class KFormulaCard extends StatelessWidget {
  final String? title;
  final String formula;
  final String? substitution;
  final String? notes;
  final String? description;

  const KFormulaCard({
    super.key,
    this.title,
    required this.formula,
    this.substitution,
    this.notes,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    return KGlassCard(
      padding: const EdgeInsets.all(KSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'Formula & Working',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: KSpacing.sm),
          SelectableText(
            formula,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          if (substitution != null) ...[
            const SizedBox(height: KSpacing.xs),
            SelectableText(
              substitution!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ],
          if (notes != null || description != null) ...[
            const SizedBox(height: KSpacing.xs),
            Text(
              (notes ?? description)!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
