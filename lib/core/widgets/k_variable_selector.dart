import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import '../constants/k_radius.dart';

class KVariableSelector<T> extends StatelessWidget {
  final T selected;
  final List<T> items;
  final String Function(T) itemLabel;
  final String Function(T)? itemSymbol;
  final ValueChanged<T> onSelected;

  const KVariableSelector({
    super.key,
    required this.selected,
    required this.items,
    required this.itemLabel,
    this.itemSymbol,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);

    return Wrap(
      spacing: KSpacing.sm,
      runSpacing: KSpacing.sm,
      children: items.map((item) {
        final isSelected = item == selected;
        final label = itemLabel(item);
        final symbol = itemSymbol != null ? itemSymbol!(item) : null;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (symbol != null) ...[
                Text(
                  symbol,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (val) {
            if (val) onSelected(item);
          },
          shape: const RoundedRectangleBorder(borderRadius: KRadius.smRadius),
          selectedColor: primaryColor,
        );
      }).toList(),
    );
  }
}
