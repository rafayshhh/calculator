import 'package:flutter/material.dart';

import '../../../../../core/constants/k_colors.dart';
import '../../../../../core/constants/k_spacing.dart';
import '../../domain/conversion_category.dart';

class CategorySelector extends StatelessWidget {
  final ConversionCategory selectedCategory;
  final ValueChanged<ConversionCategory> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: KSpacing.md),
        itemCount: ConversionCategory.values.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: KSpacing.sm),
        itemBuilder: (context, index) {
          final category = ConversionCategory.values[index];
          final isSelected = category == selectedCategory;

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${category.displayName} conversion category',
            child: Tooltip(
              message: '${category.displayName} Conversions',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCategorySelected(category),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: KSpacing.md,
                      vertical: KSpacing.xs,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? KColors.primary.withValues(alpha: 0.15)
                          : KColors.surfaceElevated.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? KColors.primary
                            : KColors.glassBorder.withValues(alpha: 0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: KColors.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: isSelected
                              ? KColors.primary
                              : KColors.textMuted,
                        ),
                        const SizedBox(width: KSpacing.xs),
                        Text(
                          category.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? KColors.primary
                                : KColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
