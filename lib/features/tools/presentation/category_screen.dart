import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/widgets/k_tool_card.dart';
import '../domain/tool_definition.dart';
import '../data/tools_registry.dart';

class CategoryScreen extends StatelessWidget {
  final ToolCategory category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    final tools = ToolsRegistry.getToolsByCategory(category);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(category.displayName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: tools.isEmpty
            ? Center(
                child: Text(
                  'No tools in this category yet',
                  style: TextStyle(color: textSecondary),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(KSpacing.md),
                itemCount: tools.length,
                separatorBuilder: (_, __) => const SizedBox(height: KSpacing.sm),
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return KToolCard(
                    tool: tool,
                    onTap: () => context.push(tool.route),
                  );
                },
              ),
      ),
    );
  }
}
