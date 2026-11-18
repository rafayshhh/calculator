import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import '../constants/k_radius.dart';
import 'k_glass_card.dart';
import '../../features/tools/data/tools_registry.dart';
import '../../features/tools/domain/tool_definition.dart';

class QuickLauncherDialog extends StatefulWidget {
  const QuickLauncherDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const QuickLauncherDialog(),
    );
  }

  @override
  State<QuickLauncherDialog> createState() => _QuickLauncherDialogState();
}

class _QuickLauncherDialogState extends State<QuickLauncherDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ToolDefinition> _results = [];

  @override
  void initState() {
    super.initState();
    _results = ToolsRegistry.allTools.take(8).toList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _results = ToolsRegistry.allTools.take(8).toList();
      } else {
        _results = ToolsRegistry.allTools.where((tool) {
          return tool.title.toLowerCase().contains(query) ||
              tool.description.toLowerCase().contains(query) ||
              tool.category.displayName.toLowerCase().contains(query) ||
              tool.keywords.any((k) => k.toLowerCase().contains(query));
        }).take(8).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 500),
        child: KGlassCard(
          padding: const EdgeInsets.all(KSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search tools, calculations, formulas...',
                  prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.black12,
                  border: OutlineInputBorder(
                    borderRadius: KRadius.mdRadius,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KSpacing.md,
                    vertical: KSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: KSpacing.md),
              Flexible(
                child: _results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(KSpacing.lg),
                        child: Text(
                          'No matching calculators found',
                          style: TextStyle(color: textSecondary),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tool = _results[index];
                          return ListTile(
                            leading: Icon(tool.icon, color: primaryColor),
                            title: Text(
                              tool.title,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              tool.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                            trailing: Text(
                              tool.category.displayName,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push(tool.route);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
