import 'package:flutter/material.dart';

import '../constants/k_radius.dart';
import '../constants/k_spacing.dart';

import '../theme/k_theme_extension.dart';

class KPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const KPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<KPrimaryButton> createState() => _KPrimaryButtonState();
}

class _KPrimaryButtonState extends State<KPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KSpacing.lg,
            vertical: KSpacing.md,
          ),
          decoration: BoxDecoration(
            color: palette.primary,
            borderRadius: BorderRadius.circular(KRadius.md),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: palette.equalsText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
