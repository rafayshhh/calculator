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

class CompoundInterestScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CompoundInterestScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends ConsumerState<CompoundInterestScreen> {
  String _principal = '10000.0';
  String _rate = '7.0';
  String _years = '10.0';
  int _compoundsPerYear = 12;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final p = double.tryParse(_principal);
    final r = double.tryParse(_rate);
    final t = double.tryParse(_years);
    if (p == null || r == null || t == null || p < 0 || r < 0 || t < 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative investment values';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateCompoundInterest(
        principal: p,
        annualRatePercent: r,
        timeYears: t,
        compoundingFrequency: _compoundsPerYear,
      );
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'principal': _principal, 'rate': _rate, 'years': _years, 'freq': _compoundsPerYear});
      ref.read(historyProvider.notifier).add(
        'Compound Interest: \$$_principal @ $_rate% for $_years yrs',
        '\$${(res['futureValue'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/finance/compound_interest',
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
      _principal = '10000.0';
      _rate = '7.0';
      _years = '10.0';
      _compoundsPerYear = 12;
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'compound_interest',
      title: 'Compound Interest',
      description: 'Compute compound interest accrual and future investment balances.',
      icon: Icons.trending_up_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'A = P × (1 + r/n)^(nt)',
          description: 'Future balance with interest compounded n times per year.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Initial Principal (P)',
          prefix: '\$',
          value: _principal,
          onChanged: (v) {
            _principal = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Annual Interest Rate (r)',
          suffix: '%',
          value: _rate,
          onChanged: (v) {
            _rate = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Investment Period (t)',
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
            label: 'Future Value (A)',
            value: '\$${(_result!['futureValue'] as double).toStringAsFixed(2)}',
            secondaryLabel: 'Total Interest Earned',
            secondaryValue: '\$${(_result!['totalInterest'] as double).toStringAsFixed(2)}',
            formula: 'A = P × (1 + r/n)^(nt)',
            substitution: '\$$_principal @ $_rate% for $_years yrs = \$${(_result!['futureValue'] as double).toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
