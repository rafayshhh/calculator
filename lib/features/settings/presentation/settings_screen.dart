import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/constants/kreate_links.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../../../core/widgets/k_page_container.dart';
import '../../calculator/domain/math_engine.dart';
import '../providers/app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPrecisionDialog(
      BuildContext context, WidgetRef ref, int currentPrecision) {
    final options = [
      {'label': 'Auto (Floating)', 'value': -1},
      {'label': '2 Decimal Places', 'value': 2},
      {'label': '4 Decimal Places', 'value': 4},
      {'label': '6 Decimal Places', 'value': 6},
      {'label': '8 Decimal Places', 'value': 8},
      {'label': '10 Decimal Places', 'value': 10},
      {'label': '12 Decimal Places', 'value': 12},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final primaryColor = KColors.primaryAdaptive(ctx);
        final textPrimaryColor = KColors.textPrimaryAdaptive(ctx);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Decimal Precision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final val = opt['value'] as int;
                final isSelected = val == currentPrecision;
                return ListTile(
                  title: Text(
                    opt['label'] as String,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryColor : textPrimaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: primaryColor)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDecimalPrecision(val);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAngleModeDialog(
      BuildContext context, WidgetRef ref, AngleMode currentMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final primaryColor = KColors.primaryAdaptive(ctx);
        final textPrimaryColor = KColors.textPrimaryAdaptive(ctx);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Default Angle Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Degrees (DEG)',
                  style: TextStyle(
                    fontWeight: currentMode == AngleMode.degrees
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentMode == AngleMode.degrees
                        ? primaryColor
                        : textPrimaryColor,
                  ),
                ),
                subtitle: const Text('Standard 360° circle (default)'),
                trailing: currentMode == AngleMode.degrees
                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                    : null,
                onTap: () {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setDefaultAngleMode(AngleMode.degrees);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'Radians (RAD)',
                  style: TextStyle(
                    fontWeight: currentMode == AngleMode.radians
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentMode == AngleMode.radians
                        ? primaryColor
                        : textPrimaryColor,
                  ),
                ),
                subtitle: const Text('Calculus & physics mathematical unit'),
                trailing: currentMode == AngleMode.radians
                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                    : null,
                onTap: () {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setDefaultAngleMode(AngleMode.radians);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'Gradians (GRAD)',
                  style: TextStyle(
                    fontWeight: currentMode == AngleMode.gradians
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentMode == AngleMode.gradians
                        ? primaryColor
                        : textPrimaryColor,
                  ),
                ),
                subtitle: const Text('Geodesy & surveying 400-grade circle'),
                trailing: currentMode == AngleMode.gradians
                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                    : null,
                onTap: () {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setDefaultAngleMode(AngleMode.gradians);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimaryColor = KColors.textPrimaryAdaptive(context);
    final textSecondaryColor = KColors.textSecondaryAdaptive(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final feedback = ref.watch(feedbackProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: KSpacing.md,
          vertical: KSpacing.sm,
        ),
        children: [
          // 1. CALCULATION ENGINE
          _buildSectionHeader('CALCULATION ENGINE', primaryColor),
          KGlassCard(
            child: Column(
              children: [
                ListTile(
                  leading:
                      Icon(Icons.format_list_numbered_rounded, color: primaryColor),
                  title: Text(
                    'Decimal Precision',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    appSettings.precisionLabel,
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    _showPrecisionDialog(
                        context, ref, appSettings.decimalPrecision);
                  },
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                ),
                ListTile(
                  leading: Icon(Icons.rotate_90_degrees_cw_rounded,
                      color: primaryColor),
                  title: Text(
                    'Angle Mode',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    appSettings.angleModeLabel,
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    _showAngleModeDialog(
                        context, ref, appSettings.defaultAngleMode);
                  },
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                ),
                SwitchListTile(
                  secondary: Icon(Icons.space_bar_rounded, color: primaryColor),
                  title: Text(
                    'Thousands Separator',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    appSettings.useThousandsSeparator
                        ? '1,234,567.89'
                        : '1234567.89',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  value: appSettings.useThousandsSeparator,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    FeedbackService.settingChange(feedback);
                    ref
                        .read(appSettingsProvider.notifier)
                        .setThousandsSeparator(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 2. APPEARANCE & THEME
          _buildSectionHeader('APPEARANCE & THEME', primaryColor),
          KGlassCard(
            child: ListTile(
              leading: Icon(Icons.palette_outlined, color: primaryColor),
              title: Text(
                'Theme & Accent Palette',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Dark, Light, AMOLED & 6 vibrant color themes',
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () {
                FeedbackService.toolSelect(feedback);
                context.push('/settings/theme');
              },
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 3. INTERACTION & FEEDBACK
          _buildSectionHeader('INTERACTION & FEEDBACK', primaryColor),
          KGlassCard(
            child: ListTile(
              leading: Icon(Icons.vibration_rounded, color: primaryColor),
              title: Text(
                'Haptic & Audio Feedback',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Keypad touch feedback intensity & audio clicks',
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () {
                FeedbackService.toolSelect(feedback);
                context.push('/settings/haptics');
              },
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 4. STORAGE & HISTORY
          _buildSectionHeader('STORAGE & HISTORY', primaryColor),
          KGlassCard(
            child: ListTile(
              leading: Icon(Icons.storage_outlined, color: primaryColor),
              title: Text(
                'History & Favorites Data',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Calculation logs capacity, favorites & cache',
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () {
                FeedbackService.toolSelect(feedback);
                context.push('/settings/data');
              },
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 5. CREATOR & COMMUNITY
          _buildSectionHeader('CREATOR & COMMUNITY', primaryColor),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.person_rounded,
                            color: primaryColor, size: 26),
                      ),
                    ),
                    const SizedBox(width: KSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muhammad Abdul Rafay',
                            style: TextStyle(
                              color: textPrimaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Creator & Lead Developer · ${KreateLinks.creatorHandle}',
                            style: TextStyle(
                              color: textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSpacing.md),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                ),
                const SizedBox(height: KSpacing.sm),
                // 4 Interactive Creator Action Tiles
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFFE1306C), size: 22),
                  title: Text(
                    'Instagram: @kreatekode',
                    style: TextStyle(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  trailing:
                      const Icon(Icons.open_in_new_rounded, size: 16),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(
                        context, KreateLinks.instagram);
                  },
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.code_rounded,
                      color: Color(0xFF00E5FF), size: 22),
                  title: Text(
                    'GitHub: @rafayshhh',
                    style: TextStyle(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  trailing:
                      const Icon(Icons.open_in_new_rounded, size: 16),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(
                        context, KreateLinks.github);
                  },
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shop_rounded,
                      color: Color(0xFFFFB300), size: 22),
                  title: Text(
                    'Google Play Store: KreateKode',
                    style: TextStyle(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  trailing:
                      const Icon(Icons.open_in_new_rounded, size: 16),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(
                        context, KreateLinks.playStore);
                  },
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_rounded,
                      color: Color(0xFF00E676), size: 22),
                  title: Text(
                    'Website: kreatekode.website',
                    style: TextStyle(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  trailing:
                      const Icon(Icons.open_in_new_rounded, size: 16),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(
                        context, KreateLinks.website);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),

          // 6. APPLICATION INFO & CODE REPO
          _buildSectionHeader('APPLICATION INFO', primaryColor),
          KGlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: primaryColor,
                  ),
                  title: Text(
                    'About Calculator',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Version 1.0.0 · 150 Mathematical Tools Suite',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    context.push('/settings/about');
                  },
                ),
                Divider(
                  color: isDark
                      ? KColors.glassBorderDark
                      : KColors.glassBorderLight,
                  height: 1,
                ),
                ListTile(
                  leading: Icon(
                    Icons.hub_rounded,
                    color: primaryColor,
                  ),
                  title: Text(
                    'Source Code Repository',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'github.com/rafayshhh/calculator',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 16),
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
                ),
                ListTile(
                  leading: const Icon(
                    Icons.bug_report_rounded,
                    color: Color(0xFFFFB300),
                  ),
                  title: Text(
                    'Report a Bug / Issue',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Submit an issue on GitHub',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 16),
                  onTap: () {
                    FeedbackService.toolSelect(feedback);
                    KreateLinks.launchUrlExternal(context, KreateLinks.issues);
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
