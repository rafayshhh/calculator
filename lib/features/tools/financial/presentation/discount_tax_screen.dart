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
import '../domain/financial_engine.dart';

class DiscountTaxScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DiscountTaxScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DiscountTaxScreen> createState() => _DiscountTaxScreenState();
}

class _DiscountTaxScreenState extends ConsumerState<DiscountTaxScreen> {
  String _price = '150.0';
  String _discount = '20.0';
  String _tax = '7.5';
  double? _finalPrice;
  double? _savings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final p = double.tryParse(_price);
    final d = double.tryParse(_discount);
    final t = double.tryParse(_tax);
    if (p == null || d == null || t == null || p < 0 || d < 0 || t < 0) {
      setState(() {
        _finalPrice = null;
        _savings = null;
        _error = 'Please enter valid non-negative numbers';
      });
      return;
    }

    try {
      final discRes = FinancialEngine.calculateDiscount(originalPrice: p, discountPercent: d);
      final discounted = discRes['finalPrice']!;
      final taxRes = FinancialEngine.calculateTax(amount: discounted, taxRatePercent: t);
      final fin = taxRes['total']!;

      setState(() {
        _error = null;
        _finalPrice = fin;
        _savings = discRes['discountAmount'];
      });

      final stateJson = jsonEncode({'price': _price, 'discount': _discount, 'tax': _tax});
      ref.read(historyProvider.notifier).add(
        'Discount & Tax: \$$_price - $_discount% + $_tax% tax',
        '\$${fin.toStringAsFixed(2)}',
        toolRoute: '/tools/financial/discount_tax',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _finalPrice = null;
        _savings = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _price = '150.0';
      _discount = '20.0';
      _tax = '7.5';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_discount_tax',
      title: 'Discount & Tax',
      description: 'Compute final checkout price with applied promotional discount and tax.',
      icon: Icons.price_check_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Original Price',
          prefix: '\$',
          value: _price,
          onChanged: (v) {
            _price = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Discount',
          suffix: '%',
          value: _discount,
          onChanged: (v) {
            _discount = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Sales Tax',
          suffix: '%',
          value: _tax,
          onChanged: (v) {
            _tax = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_finalPrice != null) ...[
          ResultDisplayCard(
            label: 'Final Total with Tax',
            value: '\$${_finalPrice!.toStringAsFixed(2)}',
            secondaryLabel: 'Discount Savings',
            secondaryValue: '\$${_savings!.toStringAsFixed(2)}',
            formula: 'Total = (Price - Discount) × (1 + Tax)',
            substitution: 'Total = \$${_finalPrice!.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
