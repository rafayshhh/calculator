import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_color_theme.dart';
import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_radius.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/services/feedback_service.dart';
import '../../providers/theme_provider.dart';

class ThemePreviewSelector extends ConsumerWidget {
  const ThemePreviewSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColorTheme = ref.watch(colorThemeProvider);
    final feedbackIntensity = ref.watch(feedbackProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: KColorTheme.values.map((theme) {
        final isSelected = theme == currentColorTheme;
        final palette = theme.palette(isDark ? Brightness.dark : Brightness.light);

        return Padding(
          padding: const EdgeInsets.only(bottom: KSpacing.sm),
          child: InkWell(
            borderRadius: BorderRadius.circular(KRadius.md),
            onTap: () {
              FeedbackService.settingChange(feedbackIntensity);
              ref.read(colorThemeProvider.notifier).setColorTheme(theme);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(KSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.accentColor.withValues(alpha: 0.12)
                    : (isDark
                        ? KColors.surfaceElevatedDark.withValues(alpha: 0.5)
                        : KColors.surfaceElevatedLight.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(KRadius.md),
                border: Border.all(
                  color: isSelected
                      ? theme.accentColor
                      : (isDark ? KColors.glassBorderDark : KColors.glassBorderLight),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.background,
                      border: Border.all(color: palette.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: theme.accentColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: KSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              theme.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: KSpacing.xs),
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: theme.accentColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          theme.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
