import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/k_radius.dart';
import '../theme/k_theme_extension.dart';

class KCalculatorButton extends ConsumerWidget {
  final String label;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isAction;
  final bool isEqual;
  final bool isSecondary;
  final double? fontSize;
  final String? semanticLabel;

  const KCalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isOperator = false,
    this.isAction = false,
    this.isEqual = false,
    this.isSecondary = false,
    this.fontSize,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.kPalette;
    final borderColor = palette.glassBorder;

    Color bgColor;
    Color textColor;

    if (isOperator) {
      bgColor = palette.operatorBg;
      textColor = palette.operatorText;
    } else if (isAction) {
      bgColor = palette.actionBg;
      textColor = palette.actionText;
    } else if (isEqual) {
      bgColor = palette.equalsBg;
      textColor = palette.equalsText;
    } else if (isSecondary) {
      bgColor = palette.secondaryButtonBg;
      textColor = palette.secondaryButtonText;
    } else {
      bgColor = palette.numButtonBg;
      textColor = palette.numButtonText;
    }

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(KRadius.md),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize ?? 28,
                  fontWeight: isOperator || isEqual
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: textColor,
                ),
                semanticsLabel: semanticLabel ?? label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
