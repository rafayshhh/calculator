import 'package:flutter/material.dart';

import '../constants/k_spacing.dart';
import '../theme/k_theme_extension.dart';

class SpecializedToolHeader extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? categoryText;

  const SpecializedToolHeader({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.categoryText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = palette.primary;
    final secondaryColor = palette.secondary;
    final textPrimaryColor = palette.textPrimary;
    final textMutedColor = palette.textMuted;

    return Column(
      children: [
        if (categoryText != null && categoryText!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.18),
              ),
            ),
            child: Text(
              categoryText!.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: KSpacing.sm),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Icon(icon, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: KSpacing.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            description,
            style: TextStyle(fontSize: 13, color: textMutedColor, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
