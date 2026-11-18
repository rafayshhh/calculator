import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import 'k_page_container.dart';
import 'specialized_tool_header.dart';
import 'related_tools_section.dart';
import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/tools/data/tools_registry.dart';
import '../../features/tools/domain/tool_definition.dart';

class ToolPageScaffold extends ConsumerWidget {
  final String? toolId;
  final String title;
  final String description;
  final IconData icon;
  final String? categoryText;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final List<Widget> inputs;
  final List<Widget> results;
  final Widget? actionButton;
  final Widget? formulaCard;
  final Widget? breakdownCard;
  final List<Widget>? bottomWidgets;
  final bool showRelatedTools;
  final VoidCallback? onShare;

  const ToolPageScaffold({
    super.key,
    this.toolId,
    required this.title,
    required this.description,
    required this.icon,
    this.categoryText,
    required this.onBack,
    required this.onRefresh,
    required this.inputs,
    required this.results,
    this.actionButton,
    this.formulaCard,
    this.breakdownCard,
    this.bottomWidgets,
    this.showRelatedTools = true,
    this.onShare,
  });

  String _deriveToolId() {
    if (toolId != null && toolId!.isNotEmpty) return toolId!;
    final match = ToolRegistry.tools.where(
      (t) => t.title.toLowerCase() == title.toLowerCase() || t.description.toLowerCase() == description.toLowerCase(),
    ).firstOrNull;
    return match?.id ?? '';
  }

  String _deriveCategoryText() {
    if (categoryText != null && categoryText!.isNotEmpty) return categoryText!;
    final tid = _deriveToolId();
    if (tid.isNotEmpty) {
      final match = ToolRegistry.tools.where((t) => t.id == tid).firstOrNull;
      if (match != null) {
        return '${match.category.displayName} • ${match.subcategory.displayName}';
      }
    }
    return '';
  }

  void _copyToolLink(BuildContext context) {
    final tid = _deriveToolId();
    final match = ToolRegistry.tools.where((t) => t.id == tid).firstOrNull;
    final path = match?.route ?? '/tools';

    Clipboard.setData(ClipboardData(text: path));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tool link copied: $path'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveToolId = _deriveToolId();
    final effectiveCategoryText = _deriveCategoryText();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textMutedColor = isDark ? KColors.textMutedDark : KColors.textMutedLight;

    final isFavorite = effectiveToolId.isNotEmpty && ref.watch(favoritesProvider).contains(effectiveToolId);

    return KPageContainer(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: 'Back to previous screen',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
          ),
        ),
        actions: [
          if (effectiveToolId.isNotEmpty)
            Semantics(
              label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
              button: true,
              child: IconButton(
                tooltip: isFavorite ? 'Favorited' : 'Favorite',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey<bool>(isFavorite),
                    color: isFavorite ? const Color(0xFFFFB300) : textMutedColor,
                  ),
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(effectiveToolId);
                },
              ),
            ),
          if (onShare != null)
            Semantics(
              label: 'Share calculation image',
              button: true,
              child: IconButton(
                tooltip: 'Share as Image',
                icon: const Icon(Icons.image_outlined, size: 20),
                onPressed: onShare,
              ),
            ),
          Semantics(
            label: 'Copy tool path',
            button: true,
            child: IconButton(
              tooltip: 'Share Link',
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () => _copyToolLink(context),
            ),
          ),
          Semantics(
            label: 'Reset inputs',
            button: true,
            child: IconButton(
              tooltip: 'Reset calculation',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 768;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSpacing.md,
                  vertical: KSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SpecializedToolHeader(
                      title: title,
                      description: description,
                      icon: icon,
                      categoryText: effectiveCategoryText,
                    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
                    const SizedBox(height: KSpacing.lg),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.tune_rounded, size: 16, color: primaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      'INPUTS',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: KSpacing.sm),
                                ...inputs,
                                if (actionButton != null) ...[
                                  const SizedBox(height: KSpacing.md),
                                  actionButton!,
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: KSpacing.xl),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.analytics_outlined, size: 16, color: primaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      'RESULTS & ANALYSIS',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: KSpacing.sm),
                                ...results,
                                if (formulaCard != null) ...[
                                  const SizedBox(height: KSpacing.md),
                                  formulaCard!,
                                ],
                                if (breakdownCard != null) ...[
                                  const SizedBox(height: KSpacing.md),
                                  breakdownCard!,
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      // Mobile Stack
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 15, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            'INPUTS',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KSpacing.sm),
                      ...inputs,
                      if (actionButton != null) ...[
                        const SizedBox(height: KSpacing.md),
                        actionButton!,
                      ],
                      const SizedBox(height: KSpacing.lg),
                      Row(
                        children: [
                          Icon(Icons.analytics_outlined, size: 15, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            'RESULTS & ANALYSIS',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KSpacing.sm),
                      ...results,
                      if (formulaCard != null) ...[
                        const SizedBox(height: KSpacing.md),
                        formulaCard!,
                      ],
                      if (breakdownCard != null) ...[
                        const SizedBox(height: KSpacing.md),
                        breakdownCard!,
                      ],
                    ],

                    ...?bottomWidgets,

                    if (showRelatedTools && effectiveToolId.isNotEmpty)
                      RelatedToolsSection(toolId: effectiveToolId),

                    const SizedBox(height: KSpacing.xxl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
