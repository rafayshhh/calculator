import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/k_radius.dart';
import '../theme/k_theme_extension.dart';

class KGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurAmount;
  final Color? color;
  final Color? borderColor;

  const KGlassCard({
    super.key,
    required this.child,
    this.borderRadius = KRadius.lg,
    this.padding,
    this.blurAmount = 20.0,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? palette.glassSurface : palette.surface;
    final defaultBorder = palette.glassBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? defaultBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? defaultBorder,
              width: 1.0,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        ),
      ),
    );
  }
}
