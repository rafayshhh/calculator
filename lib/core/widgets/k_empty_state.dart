import 'package:flutter/material.dart';

import '../constants/k_spacing.dart';
import '../theme/k_theme_extension.dart';

/// Standardized empty state component for Calculator.
/// Displays an icon, title, description, optional action button,
/// and optional suggestion chips.
class KEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<String>? suggestions;
  final ValueChanged<String>? onSuggestionSelected;

  const KEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = palette.primary;
    final textSecondary = palette.textSecondary;
    final textMuted = palette.textMuted;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(KSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(KSpacing.md),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: isDark ? 0.1 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: primaryAccent),
              ),
              const SizedBox(height: KSpacing.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 13, color: textMuted, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              if (suggestions != null && suggestions!.isNotEmpty) ...[
                const SizedBox(height: KSpacing.md),
                Wrap(
                  spacing: KSpacing.xs,
                  runSpacing: KSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: suggestions!.map((s) {
                    return ActionChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      onPressed: () => onSuggestionSelected?.call(s),
                      backgroundColor: primaryAccent.withValues(
                        alpha: isDark ? 0.12 : 0.08,
                      ),
                      side: BorderSide(
                        color: primaryAccent.withValues(alpha: 0.2),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: KSpacing.lg),
                FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
