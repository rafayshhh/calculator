import 'package:flutter/material.dart';

import '../constants/k_spacing.dart';
import '../theme/k_theme_extension.dart';

class PremiumNumericField extends StatefulWidget {
  final String label;
  final String? prefix;
  final String? suffix;
  final String? hint;
  final String? value;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool hasError;
  final String? errorText;
  final TextInputType? keyboardType;

  const PremiumNumericField({
    super.key,
    this.label = '',
    this.prefix,
    this.suffix,
    this.hint,
    this.value,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.hasError = false,
    this.errorText,
    this.keyboardType,
  });

  @override
  State<PremiumNumericField> createState() => _PremiumNumericFieldState();
}

class _PremiumNumericFieldState extends State<PremiumNumericField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(PremiumNumericField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final val = widget.value ?? widget.initialValue ?? '';
    final oldVal = oldWidget.value ?? oldWidget.initialValue ?? '';
    if (oldVal != val && _controller.text != val) {
      final previousSelection = _controller.selection;
      _controller.value = TextEditingValue(
        text: val,
        selection:
            previousSelection.isValid &&
                previousSelection.baseOffset <= val.length
            ? previousSelection
            : TextSelection.collapsed(offset: val.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    final textSecondaryColor = palette.textSecondary;
    final textPrimaryColor = palette.textPrimary;
    final textMutedColor = palette.textMuted;
    final surfaceBg = palette.inputBg;
    final defaultBorder = palette.glassBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: TextStyle(
              color: widget.hasError ? palette.error : textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: KSpacing.xs),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KSpacing.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: surfaceBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.hasError ? palette.error : defaultBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: TextStyle(
                    color: textMutedColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: KSpacing.sm),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  keyboardType:
                      widget.keyboardType ??
                      const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? '0',
                    hintStyle: TextStyle(color: textMutedColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: KSpacing.sm,
                    ),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: textMutedColor,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  tooltip: 'Clear ${widget.label}',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              if (widget.suffix != null) ...[
                const SizedBox(width: KSpacing.xs),
                Text(
                  widget.suffix!,
                  style: TextStyle(
                    color: textMutedColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.hasError && widget.errorText != null) ...[
          const SizedBox(height: KSpacing.xs),
          Text(
            widget.errorText!,
            style: TextStyle(color: palette.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
