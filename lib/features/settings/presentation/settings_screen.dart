import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_color_theme.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/constants/kreate_links.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../../../core/widgets/k_page_container.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimaryColor = KColors.textPrimaryAdaptive(context);
    final textSecondaryColor = KColors.textSecondaryAdaptive(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final feedback = ref.watch(feedbackProvider);
    final themeMode = ref.watch(themeProvider);
    final colorTheme = ref.watch(colorThemeProvider);

    return KPageContainer(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: KSpacing.md,
          vertical: KSpacing.sm,
        ),
        children: [
          // 1. APP BRANDING BANNER
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.lg),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calculate_rounded,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: KSpacing.md),
                Text(
                  'Calculator',
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Calculator Version 1.0',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 2. APPEARANCE & THEMES
          _buildSectionHeader('APPEARANCE & THEME', primaryColor),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.brightness_6_rounded, color: primaryColor, size: 20),
                    const SizedBox(width: KSpacing.sm),
                    Text(
                      'Display Mode',
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Switch between Light, Dark, or System mode',
                  style: TextStyle(color: textSecondaryColor, fontSize: 12),
                ),
                const SizedBox(height: KSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded, size: 16),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 16),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 16),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      FeedbackService.settingChange(feedback);
                      ref
                          .read(themeProvider.notifier)
                          .setThemeMode(newSelection.first);
                    },
                  ),
                ),
                const SizedBox(height: KSpacing.lg),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                ),
                const SizedBox(height: KSpacing.md),
                Row(
                  children: [
                    Icon(Icons.palette_rounded, color: primaryColor, size: 20),
                    const SizedBox(width: KSpacing.sm),
                    Text(
                      'Color Themes',
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select from 3 signature accent palettes',
                  style: TextStyle(color: textSecondaryColor, fontSize: 12),
                ),
                const SizedBox(height: KSpacing.md),
                Row(
                  children: [
                    (
                      theme: KColorTheme.kreateBlue,
                      name: 'Electric Cyan',
                      tag: 'Signature',
                      color: const Color(0xFF00E5FF),
                    ),
                    (
                      theme: KColorTheme.emeraldGreen,
                      name: 'Emerald Mint',
                      tag: 'Nature',
                      color: const Color(0xFF00E676),
                    ),
                    (
                      theme: KColorTheme.royalPurple,
                      name: 'Royal Violet',
                      tag: 'Vibrant',
                      color: const Color(0xFFB388FF),
                    ),
                  ].map((t) {
                    final isSelected = colorTheme == t.theme;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            FeedbackService.settingChange(feedback);
                            ref
                                .read(colorThemeProvider.notifier)
                                .setColorTheme(t.theme);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? t.color.withValues(alpha: 0.15)
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? t.color
                                    : (isDark
                                        ? Colors.white12
                                        : Colors.black12),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: t.color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: t.color.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Colors.black,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? primaryColor
                                        : textPrimaryColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.tag,
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 3. PUBLISHER & DEVELOPER
          _buildSectionHeader('PUBLISHER & DEVELOPER', primaryColor),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.sm),
            child: Column(
              children: [
                // Publisher: KreateKode
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Color(0xFF00E5FF),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Publisher',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'KreateKode',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.verified_rounded,
                      color: Color(0xFF00E5FF), size: 20),
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                // Developer: RafayShhh
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF00E676),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Developer',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'RafayShhh (Muhammad Abdul Rafay)',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.code_rounded,
                      color: Color(0xFF00E676), size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 4. SOCIAL LINKS & GITHUB REPO
          _buildSectionHeader('SOCIAL LINKS & REPOSITORY', primaryColor),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.sm),
            child: Column(
              children: [
                // GitHub Repository
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.code_rounded, color: primaryColor, size: 22),
                  ),
                  title: Text(
                    'GitHub Repository',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'github.com/rafayshhh/calculator',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(context, KreateLinks.repo);
                  },
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                // Instagram
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1306C).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFFE1306C),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Instagram',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '@kreatekode',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(context, KreateLinks.instagram);
                  },
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                // Developer GitHub Profile
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB388FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: Color(0xFFB388FF),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'GitHub Profile',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '@rafayshhh',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(context, KreateLinks.github);
                  },
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                // Website
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF00E676),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Official Website',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'kreatekode.website',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(context, KreateLinks.website);
                  },
                ),
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
