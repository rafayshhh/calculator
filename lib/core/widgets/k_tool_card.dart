import 'package:flutter/material.dart';
import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import 'k_glass_card.dart';
import '../../features/tools/domain/tool_definition.dart';

class KToolCard extends StatelessWidget {
  final ToolDefinition tool;
  final VoidCallback onTap;
  final Widget? trailing;

  const KToolCard({
    super.key,
    required this.tool,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(KSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tool.icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: KSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tool.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
