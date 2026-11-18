import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import 'k_glass_card.dart';

class KErrorCard extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;

  const KErrorCard({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? KColors.error : Colors.red.shade700;

    return KGlassCard(
      padding: const EdgeInsets.all(KSpacing.md),
      borderColor: errorColor.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: errorColor, size: 20),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                child: Text(
                  title ?? 'Calculation Error',
                  style: TextStyle(
                    color: errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KSpacing.sm),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: KSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
