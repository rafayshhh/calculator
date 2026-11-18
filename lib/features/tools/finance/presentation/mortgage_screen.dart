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

class MortgageScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MortgageScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends ConsumerState<MortgageScreen> {
  String _homePrice = '350000.0';
  String _downPayment = '70000.0';
  String _rate = '6.8';
  String _years = '30.0';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final hp = double.tryParse(_homePrice);
    final dp = double.tryParse(_downPayment);
    final r = double.tryParse(_rate);
    final t = double.tryParse(_years);
    if (hp == null || dp == null || r == null || t == null || hp <= dp) {
      setState(() {
        _result = null;
        _error = 'Home price must exceed down payment';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateMortgage(homePrice: hp, downPayment: dp, annualRatePercent: r, termYears: t);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'homePrice': _homePrice, 'downPayment': _downPayment, 'rate': _rate, 'years': _years});
      ref.read(historyProvider.notifier).add(
        'Mortgage: \$$_homePrice with \$$_downPayment down',
        '\$${(res['totalMonthlyPayment'] as double).toStringAsFixed(2)}/mo',
        toolRoute: '/tools/finance/mortgage',
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
      _homePrice = '350000.0';
      _downPayment = '70000.0';
      _rate = '6.8';
      _years = '30.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'mortgage',
      title: 'Mortgage Calculator',
      description: 'Compute monthly mortgage payments, interest amortizations, and down payment ratios.',
      icon: Icons.home_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Home Purchase Price',
          prefix: '\$',
          value: _homePrice,
          onChanged: (v) {
            _homePrice = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Down Payment',
          prefix: '\$',
          value: _downPayment,
          onChanged: (v) {
            _downPayment = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Interest Rate',
          suffix: '%',
          value: _rate,
          onChanged: (v) {
            _rate = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Loan Term',
          suffix: 'years',
          value: _years,
          onChanged: (v) {
            _years = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Monthly Payment (P&I)',
            value: '\$${(_result!['totalMonthlyPayment'] as double).toStringAsFixed(2)}',
            secondaryLabel: 'Loan Principal',
            secondaryValue: '\$${(_result!['principal'] as double).toStringAsFixed(0)}',
            formula: 'Monthly = P × [r(1+r)^n] / [(1+r)^n - 1]',
            substitution: '\$${(_result!['totalMonthlyPayment'] as double).toStringAsFixed(2)} per month',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
