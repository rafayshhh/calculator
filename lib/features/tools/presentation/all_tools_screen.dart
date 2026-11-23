import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/widgets/k_tool_card.dart';
import '../domain/tool_definition.dart';
import '../data/tools_registry.dart';
import '../application/recent_tools_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class AllToolsScreen extends ConsumerStatefulWidget {
  const AllToolsScreen({super.key});

  @override
  ConsumerState<AllToolsScreen> createState() => _AllToolsScreenState();
}

class _AllToolsScreenState extends ConsumerState<AllToolsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    final recents = ref.watch(recentToolsProvider);
    final favorites = ref.watch(favoritesProvider);

    final filteredAll = ToolsRegistry.allTools.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.category.displayName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('All Tools Directory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'All Tools'),
            Tab(text: 'Favorites'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(KSpacing.md),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search 150+ tools...',
                  hintStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.black12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KSpacing.md,
                    vertical: KSpacing.sm,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: All Tools
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: KSpacing.md),
                    itemCount: filteredAll.length,
                    separatorBuilder: (_, __) => const SizedBox(height: KSpacing.sm),
                    itemBuilder: (context, index) {
                      final tool = filteredAll[index];
                      return KToolCard(
                        tool: tool,
                        onTap: () => context.push(tool.route),
                      );
                    },
                  ),

                  // Tab 2: Favorites
                  favorites.isEmpty
                      ? Center(
                          child: Text(
                            'No favorite calculators starred yet',
                            style: TextStyle(color: textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: KSpacing.md),
                          itemCount: favorites.length,
                          separatorBuilder: (_, __) => const SizedBox(height: KSpacing.sm),
                          itemBuilder: (context, index) {
                            final toolId = favorites.elementAt(index);
                            final tool = ToolsRegistry.getToolById(toolId);
                            if (tool == null) return const SizedBox.shrink();
                            return KToolCard(
                              tool: tool,
                              onTap: () => context.push(tool.route),
                            );
                          },
                        ),

                  // Tab 3: Recent
                  recents.isEmpty
                      ? Center(
                          child: Text(
                            'No recent tools recorded',
                            style: TextStyle(color: textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: KSpacing.md),
                          itemCount: recents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: KSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = recents[index];
                            final tool = ToolsRegistry.getToolById(item.toolId);
                            if (tool == null) return const SizedBox.shrink();
                            return KToolCard(
                              tool: tool,
                              onTap: () => context.push(tool.route),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
