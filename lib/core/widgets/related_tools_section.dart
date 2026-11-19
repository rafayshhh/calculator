import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import 'k_glass_card.dart';
import '../../features/tools/data/tools_registry.dart';

class RelatedToolsSection extends StatelessWidget {
  final String? toolId;

  const RelatedToolsSection({super.key, this.toolId});

  @override
  Widget build(BuildContext context) {
    if (toolId == null) {
      return const SizedBox.shrink();
    }
    final related = ToolsRegistry.getRelatedTools(toolId!);
    if (related.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: KSpacing.sm),
          child: Text(
            'RELATED CALCULATORS',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: KSpacing.sm),
            itemBuilder: (context, index) {
              final tool = related[index];
              return SizedBox(
                width: 170,
                child: KGlassCard(
                  onTap: () => context.push(tool.route),
                  padding: const EdgeInsets.all(KSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tool.icon, size: 22, color: primaryColor),
                      const SizedBox(height: KSpacing.xs),
                      Text(
                        tool.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
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
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
