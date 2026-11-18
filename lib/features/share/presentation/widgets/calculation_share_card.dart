import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/theme/k_theme_extension.dart';
import '../../domain/calculation_share_data.dart';

/// Branded, high-resolution, tool-aware visual card rendered for social sharing and exporting.
/// Fixed, predictable 480px width canvas with full active theme support.
class CalculationShareCard extends StatelessWidget {
  final CalculationShareData data;

  const CalculationShareCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final activeThemeColors = context.kTheme;
    final brightness = data.brightness ?? activeThemeColors.brightness;
    final colorTheme = data.colorTheme ?? activeThemeColors.colorTheme;
    final palette = colorTheme.palette(brightness);
    final isDark = brightness == Brightness.dark;

    final dateFormat = DateFormat('MMM d, yyyy · HH:mm');
    final formattedTime = data.timestamp != null
        ? dateFormat.format(data.timestamp!)
        : null;

    final primaryAccent = palette.primary;
    final secondaryAccent = palette.secondary;
    final bgStart = isDark ? palette.background : palette.backgroundElevated;
    final bgEnd = isDark ? palette.surface : palette.surfaceElevated;
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;
    final textMuted = palette.textMuted;
    final border = palette.glassBorder;

    return Container(
      width: 480,
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(KSpacing.xl),
      decoration: BoxDecoration(
        color: bgStart,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryAccent.withValues(alpha: isDark ? 0.25 : 0.15),
            blurRadius: 32,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            bgStart,
            bgEnd,
            isDark ? palette.surfaceElevated : palette.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Brand & App Title
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Icon(
                      data.icon ?? Icons.calculate_rounded,
                      color: primaryAccent,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Calculator',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryAccent,
                          ),
                        ),
                        if (data.category != null) ...[
                          Text(
                            ' · ',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                          Text(
                            data.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: KSpacing.md),
          Divider(color: border, height: 1),
          const SizedBox(height: KSpacing.md),

          // Inputs Section (if provided)
          if (data.inputs.isNotEmpty) ...[
            Text(
              'INPUT VALUES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: textMuted,
              ),
            ),
            const SizedBox(height: KSpacing.xs),
            Wrap(
              spacing: KSpacing.xs,
              runSpacing: KSpacing.xs,
              children: data.inputs.map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryAccent.withValues(
                      alpha: isDark ? 0.08 : 0.06,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: '${field.label}: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: field.formattedValue,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: KSpacing.md),
          ],

          // Formula & Steps (if provided)
          if (data.formula != null && data.formula!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(KSpacing.sm),
              decoration: BoxDecoration(
                color: primaryAccent.withValues(alpha: isDark ? 0.06 : 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.functions_rounded,
                        size: 14,
                        color: primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'FORMULA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: primaryAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    data.formula!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryAccent,
                    ),
                  ),
                  if (data.substitution != null &&
                      data.substitution!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.substitution!,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: KSpacing.md),
          ],

          // Expression (if no structured inputs or standard calculation)
          if (data.inputs.isEmpty && data.expression.isNotEmpty) ...[
            Text(
              data.expression,
              softWrap: true,
              style: GoogleFonts.inter(
                fontSize: data.expression.length > 40 ? 16 : 20,
                fontWeight: FontWeight.w400,
                color: textSecondary,
                letterSpacing: 0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: KSpacing.xs),
          ],

          // Primary Result (Prominent Visual Callout)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KSpacing.md,
              vertical: KSpacing.md,
            ),
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryAccent.withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CALCULATED RESULT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: primaryAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.result,
                  softWrap: true,
                  style: GoogleFonts.inter(
                    fontSize: data.result.length > 30
                        ? 18
                        : data.result.length > 20
                        ? 24
                        : 32,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          // Custom Result Widget (For specialized outputs like 2D Graphs or Tables)
          if (data.customResultWidget != null) ...[
            const SizedBox(height: KSpacing.md),
            data.customResultWidget!,
          ],

          // Secondary Results / Extra Stats (if present)
          if (data.secondaryResults.isNotEmpty) ...[
            const SizedBox(height: KSpacing.sm),
            Wrap(
              spacing: KSpacing.xs,
              runSpacing: KSpacing.xs,
              children: data.secondaryResults.map((stat) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryAccent.withValues(
                      alpha: isDark ? 0.08 : 0.05,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    '${stat.label}: ${stat.formattedValue}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Metadata Key-Value pairs (if present)
          if (data.metadata != null && data.metadata!.isNotEmpty) ...[
            const SizedBox(height: KSpacing.sm),
            Wrap(
              spacing: KSpacing.xs,
              runSpacing: KSpacing.xs,
              children: data.metadata!.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.glassSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(fontSize: 10, color: textMuted),
                  ),
                );
              }).toList(),
            ),
          ],

          // Notes (if present)
          if (data.notes != null && data.notes!.isNotEmpty) ...[
            const SizedBox(height: KSpacing.xs),
            Text(
              data.notes!,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: textMuted,
              ),
            ),
          ],

          const SizedBox(height: KSpacing.md),
          Divider(color: border, height: 1),
          const SizedBox(height: KSpacing.sm),

          // Footer: Timestamp & Official Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (formattedTime != null)
                Expanded(
                  child: Text(
                    formattedTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                )
              else
                const SizedBox.shrink(),
              const SizedBox(width: 8),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    Text(
                      'Calculator  •  ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                    Text(
                      'github.com/rafayshhh',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryAccent,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
