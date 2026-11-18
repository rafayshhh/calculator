import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/k_theme_extension.dart';
import '../../../core/widgets/quick_launcher_dialog.dart';
import 'web_desktop_shell.dart';

class AppNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigationShell({super.key, required this.navigationShell});

  void _onBranchTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    final primaryColor = palette.primary;
    final bgElevated = palette.backgroundElevated;
    final indicatorColor = palette.glassSurface;
    final borderColor = palette.glassBorder;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          QuickLauncherDialog.show(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          QuickLauncherDialog.show(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              // Desktop/Web: Professional split-pane sidebar UI
              return WebDesktopShell(navigationShell: navigationShell);
            } else if (constraints.maxWidth >= 600) {
              // Tablet: 3-destination Navigation Rail
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _onBranchTapped,
                      backgroundColor: bgElevated,
                      indicatorColor: indicatorColor,
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: IconButton(
                          tooltip: 'Quick Launcher (Ctrl+K)',
                          icon: const Icon(Icons.search_rounded),
                          onPressed: () => QuickLauncherDialog.show(context),
                        ),
                      ),
                      destinations: [
                        NavigationRailDestination(
                          icon: const Icon(Icons.calculate_outlined),
                          selectedIcon: Icon(
                            Icons.calculate,
                            color: primaryColor,
                          ),
                          label: const Text('Calculator'),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.grid_view_outlined),
                          selectedIcon: Icon(
                            Icons.grid_view,
                            color: primaryColor,
                          ),
                          label: const Text('Tools'),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.settings_outlined),
                          selectedIcon: Icon(
                            Icons.settings,
                            color: primaryColor,
                          ),
                          label: const Text('Settings'),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 1,
                      color: borderColor,
                    ),
                    Expanded(child: navigationShell),
                  ],
                ),
              );
            } else {
              // Mobile: 3-destination Bottom Navigation Bar
              return Scaffold(
                body: navigationShell,
                bottomNavigationBar: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onBranchTapped,
                  backgroundColor: bgElevated,
                  indicatorColor: indicatorColor,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.calculate_outlined),
                      selectedIcon: Icon(Icons.calculate, color: primaryColor),
                      label: 'Calculator',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view, color: primaryColor),
                      label: 'Tools',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings, color: primaryColor),
                      label: 'Settings',
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
