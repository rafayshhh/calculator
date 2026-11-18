import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/financial_engine.dart';

class SalesTaxScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SalesTaxScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SalesTaxScreen> createState() => _SalesTaxScreenState();
}

class _SalesTaxScreenState extends ConsumerState<SalesTaxScreen> {
  String _amount = '100.0';
  String _rate = '8.25';
  Map<String, double>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = double.tryParse(_amount);
    final r = double.tryParse(_rate);
    if (a == null || r == null || a < 0 || r < 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative numbers';
      });
      return;
    }

    try {
      final res = FinancialEngine.calculateTax(amount: a, taxRatePercent: r);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'amount': _amount, 'rate': _rate});
      ref.read(historyProvider.notifier).add(
        'Sales Tax: \$$_amount @ $_rate%',
        '\$${res['total']!.toStringAsFixed(2)}',
        toolRoute: '/tools/financial/sales_tax',
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
      _amount = '100.0';
      _rate = '8.25';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_sales_tax',
      title: 'Sales Tax Calculator',
      description: 'Compute retail sales tax amount and total transaction cost.',
      icon: Icons.receipt_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Pre-Tax Amount',
          prefix: '\$',
          value: _amount,
          onChanged: (v) {
            _amount = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Sales Tax Rate',
          suffix: '%',
          value: _rate,
          onChanged: (v) {
            _rate = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Total Amount (with Tax)',
            value: '\$${_result!['total']!.toStringAsFixed(2)}',
            secondaryLabel: 'Sales Tax Charged',
            secondaryValue: '\$${_result!['taxAmount']!.toStringAsFixed(2)}',
            formula: 'Total = Amount × (1 + Rate)',
            substitution: '\$$_amount + $_rate% = \$${_result!['total']!.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
