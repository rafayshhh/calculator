import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/discount_provider.dart';

class DiscountCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;

  const DiscountCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState
    extends ConsumerState<DiscountCalculatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(discountProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discountProvider);
    final notifier = ref.read(discountProvider.notifier);

    return ToolPageScaffold(
      toolId: 'discount',
      title: 'Discount Calculator',
      description: 'Calculate final checkout prices, applied savings, and total discount amount',
      icon: Icons.local_offer_outlined,
      onBack: () {
        notifier.reset();
        context.pop();
      },
      onRefresh: notifier.reset,
      inputs: [
        PremiumNumericField(
          label: 'Original Price',
          prefix: '\$',
          value: state.originalPrice,
          onChanged: notifier.setOriginalPrice,
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Discount Percentage',
          suffix: '%',
          value: state.discountPercentage,
          onChanged: notifier.setDiscountPercentage,
        ),
      ],
      results: [
        if (state.result != null || state.hasError) ...[
          ResultDisplayCard(
            label: 'Final Price',
            value: state.hasError
                ? 'Error'
                : '\$${state.result!.finalPrice.toStringAsFixed(2)}',
            secondaryLabel: state.hasError ? null : 'You Save',
            secondaryValue: state.hasError
                ? null
                : '\$${state.result!.discountAmount.toStringAsFixed(2)} (${state.discountPercentage}%)',
            isError: state.hasError,
          ),
          if (state.result != null && !state.hasError) ...[
            const SizedBox(height: KSpacing.md),
            KFormulaCard(
              title: 'Discount Calculation',
              formula: 'Final Price = Original × (1 - Discount / 100)',
              substitution:
                  '\$${state.originalPrice} × (1 - ${state.discountPercentage}%) = \$${state.result!.finalPrice.toStringAsFixed(2)}',
              notes:
                  'Savings Amount = \$${state.result!.discountAmount.toStringAsFixed(2)}',
            ),
          ],
        ],
      ],
    );
  }
}
