import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/k_theme_extension.dart';
import '../../settings/providers/theme_provider.dart';
import '../../../core/widgets/quick_launcher_dialog.dart';
import '../../history/presentation/history_sheet.dart';

class WebDesktopShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const WebDesktopShell({super.key, required this.navigationShell});

  void _onBranchTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.kPalette;
    final primaryColor = palette.primary;
    final bgElevated = palette.backgroundElevated;
    final indicatorColor = palette.glassSurface;
    final borderColor = palette.glassBorder;
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;

    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          Container(
            width: 260,
            color: bgElevated,
            child: Column(
              children: [
                // Branding
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.calculate_rounded, color: primaryColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'CALCULATOR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 24, endIndent: 24),
                const SizedBox(height: 16),
                
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        selectedIcon: Icons.dashboard_rounded,
                        label: 'Overview',
                        isSelected: navigationShell.currentIndex == 1 && GoRouterState.of(context).uri.toString() == '/tools',
                        onTap: () {
                          if (navigationShell.currentIndex != 1) {
                            navigationShell.goBranch(1, initialLocation: true);
                          } else {
                            context.go('/tools');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.calculate_outlined,
                        selectedIcon: Icons.calculate_rounded,
                        label: 'Calculator',
                        isSelected: navigationShell.currentIndex == 0,
                        onTap: () => _onBranchTapped(0),
                      ),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.grid_view_outlined,
                        selectedIcon: Icons.grid_view_rounded,
                        label: 'All Tools',
                        isSelected: navigationShell.currentIndex == 1 && GoRouterState.of(context).uri.toString().contains('/tools/directory'),
                        onTap: () {
                          if (navigationShell.currentIndex != 1) {
                            navigationShell.goBranch(1);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.go('/tools/directory');
                            });
                          } else {
                            context.go('/tools/directory');
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text(
                          'SYSTEM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      _NavItem(
                        icon: Icons.history_rounded,
                        selectedIcon: Icons.history_rounded,
                        label: 'History',
                        isSelected: false,
                        onTap: () => HistorySheet.show(context),
                      ),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings_rounded,
                        label: 'Settings',
                        isSelected: navigationShell.currentIndex == 2,
                        onTap: () => _onBranchTapped(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical Divider
          VerticalDivider(width: 1, thickness: 1, color: borderColor),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      // Search / Launcher Button
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () => QuickLauncherDialog.show(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: indicatorColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_rounded, size: 20, color: textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Search tools...',
                                    style: TextStyle(color: textSecondary, fontSize: 14),
                                  ),
                                  const SizedBox(width: 32),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: palette.surfaceElevated,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Ctrl+K',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Theme Toggle
                      IconButton(
                        tooltip: 'Toggle Theme',
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: textSecondary,
                        ),
                        onPressed: () {
                          final currentMode = Theme.of(context).brightness == Brightness.dark 
                              ? ThemeMode.light 
                              : ThemeMode.dark;
                          ref.read(themeProvider.notifier).setThemeMode(currentMode);
                        },
                      ),
                      const SizedBox(width: 8),
                      // History
                      IconButton(
                        tooltip: 'History',
                        icon: Icon(Icons.history_rounded, color: textSecondary),
                        onPressed: () => HistorySheet.show(context),
                      ),
                    ],
                  ),
                ),
                
                // Active Route Content
                Expanded(
                  child: ClipRect(
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? palette.primary : palette.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? palette.primary : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
