import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/k_page_container.dart';
import '../../providers/theme_provider.dart';
import '../widgets/theme_preview_selector.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeProvider);
    final feedbackIntensity = ref.watch(feedbackProvider);
    final textPrimaryColor = KColors.textPrimaryAdaptive(context);
    final textSecondaryColor = KColors.textSecondaryAdaptive(context);
    final primaryColor = KColors.primaryAdaptive(context);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(KSpacing.md),
        children: [
          // Section 1: Appearance Mode
          _buildSectionHeader('APPEARANCE', primaryColor),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.brightness_6_rounded, color: primaryColor),
                    const SizedBox(width: KSpacing.md),
                    Text(
                      'Appearance Mode',
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSpacing.xs),
                Text(
                  'Select whether Calculator follows your system theme or stays in Light or Dark mode.',
                  style: TextStyle(fontSize: 12, color: textSecondaryColor),
                ),
                const SizedBox(height: KSpacing.md),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.settings_brightness),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {currentThemeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    FeedbackService.settingChange(feedbackIntensity);
                    ref
                        .read(themeProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return primaryColor.withValues(alpha: 0.2);
                      }
                      return isDark
                          ? KColors.surfaceElevatedDark
                          : KColors.surfaceElevatedLight;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return primaryColor;
                      }
                      return textSecondaryColor;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xl),

          // Section 2: Color Theme Selection
          _buildSectionHeader('COLOR PALETTE', primaryColor),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_rounded, color: primaryColor),
                    const SizedBox(width: KSpacing.md),
                    Text(
                      'Color Identity',
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSpacing.xs),
                Text(
                  'Choose from 6 meticulously crafted color palettes with full Light & Dark variants.',
                  style: TextStyle(fontSize: 12, color: textSecondaryColor),
                ),
                const SizedBox(height: KSpacing.md),
                const ThemePreviewSelector(),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
