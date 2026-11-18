import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/finance_engine.dart';

class DiscountSaleScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DiscountSaleScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DiscountSaleScreen> createState() => _DiscountSaleScreenState();
}

class _DiscountSaleScreenState extends ConsumerState<DiscountSaleScreen> {
  String _origPrice = '120.0';
  String _discPercent = '25.0';
  String _taxPercent = '8.0';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final p = double.tryParse(_origPrice);
    final d = double.tryParse(_discPercent);
    final t = double.tryParse(_taxPercent);
    if (p == null || d == null || t == null || p < 0 || d < 0 || t < 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative price and percentages';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateDiscountAndSale(originalPrice: p, discountPercent: d, taxPercent: t);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'origPrice': _origPrice, 'discPercent': _discPercent, 'taxPercent': _taxPercent});
      ref.read(historyProvider.notifier).add(
        'Sale Price: \$$_origPrice - $_discPercent%',
        '\$${(res['finalPriceWithTax'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/finance/discount',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _origPrice = '120.0';
      _discPercent = '25.0';
      _taxPercent = '8.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'discount_sale',
      title: 'Discount & Sale Calculator',
      description: 'Compute final checkout price after stacked discounts and localized sales tax.',
      icon: Icons.sell_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Original Price',
          prefix: '\$',
          value: _origPrice,
          onChanged: (v) {
            _origPrice = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Discount Percentage',
          suffix: '%',
          value: _discPercent,
          onChanged: (v) {
            _discPercent = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Sales Tax',
          suffix: '%',
          value: _taxPercent,
          onChanged: (v) {
            _taxPercent = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Final Total with Tax',
            value: '\$${(_result!['finalPriceWithTax'] as double).toStringAsFixed(2)}',
            secondaryLabel: 'You Saved',
            secondaryValue: '\$${(_result!['savedAmount'] as double).toStringAsFixed(2)}',
            formula: 'Price = (Original - Discount) × (1 + Tax)',
            substitution: '\$$_origPrice - $_discPercent% + $_taxPercent% tax = \$${(_result!['finalPriceWithTax'] as double).toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
