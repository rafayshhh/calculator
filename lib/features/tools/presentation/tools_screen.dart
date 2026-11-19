import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../../../core/widgets/k_tool_card.dart';
import '../domain/tool_definition.dart';
import '../data/tools_registry.dart';
import '../application/recent_tools_provider.dart';
import '../application/tool_recommendations.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    final recents = ref.watch(recentToolsProvider);
    final recommendations = ToolRecommendations.getRecommendations(recents, 4);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Toolbox Hub'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            tooltip: 'All Tools Directory',
            onPressed: () => context.push('/tools/all'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(KSpacing.md),
          children: [
            // Quick Hero / All Tools CTA
            KGlassCard(
              padding: const EdgeInsets.all(KSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.explore_rounded, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: KSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '150+ Specialized Calculators',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'From physics & chemistry to finance & everyday math',
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/tools/all'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Browse All'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: KSpacing.lg),

            // Explore Categories Header
            Text(
              'EXPLORE CATEGORIES',
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: KSpacing.sm),

            // Categories Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 100,
                crossAxisSpacing: KSpacing.sm,
                mainAxisSpacing: KSpacing.sm,
              ),
              itemCount: ToolCategory.values.length,
              itemBuilder: (context, index) {
                final category = ToolCategory.values[index];
                final count = ToolsRegistry.getToolsByCategory(category).length;

                return KGlassCard(
                  onTap: () => context.push('/tools/category/${category.name}'),
                  padding: const EdgeInsets.all(KSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category.icon, color: primaryColor, size: 24),
                      const SizedBox(height: KSpacing.xs),
                      Text(
                        category.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$count tools',
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: KSpacing.lg),

            // Recommended Tools
            if (recommendations.isNotEmpty) ...[
              Text(
                'RECOMMENDED FOR YOU',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: KSpacing.sm),
              ...recommendations.map((tool) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: KSpacing.sm),
                  child: KToolCard(
                    tool: tool,
                    onTap: () => context.push(tool.route),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
