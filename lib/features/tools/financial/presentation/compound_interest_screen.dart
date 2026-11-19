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

class CompoundInterestScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CompoundInterestScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends ConsumerState<CompoundInterestScreen> {
  String _principal = '5000.0';
  String _rate = '6.0';
  String _years = '5.0';
  String _contribution = '200.0';
  CompoundInterestResult? _result;
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
    final c = double.tryParse(_contribution);
    if (p == null || r == null || t == null || c == null || p < 0 || r < 0 || t < 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative investment numbers';
      });
      return;
    }

    try {
      final res = FinancialEngine.calculateCompoundInterest(
        principal: p,
        annualRate: r,
        years: t,
        monthlyContribution: c,
      );
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'principal': _principal, 'rate': _rate, 'years': _years, 'contribution': _contribution});
      ref.read(historyProvider.notifier).add(
        'Compound Savings: \$$_principal + \$$_contribution/mo @ $_rate%',
        '\$${res.futureValue.toStringAsFixed(2)}',
        toolRoute: '/tools/financial/compound_interest',
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
      _principal = '5000.0';
      _rate = '6.0';
      _years = '5.0';
      _contribution = '200.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_compound_interest',
      title: 'Compound Interest & Savings',
      description: 'Calculate periodic compounding wealth growth with recurring monthly contributions.',
      icon: Icons.trending_up_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Initial Deposit (Principal)',
          prefix: '\$',
          value: _principal,
          onChanged: (v) {
            _principal = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Monthly Contribution',
          prefix: '\$',
          value: _contribution,
          onChanged: (v) {
            _contribution = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Annual Return Rate',
          suffix: '%',
          value: _rate,
          onChanged: (v) {
            _rate = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Duration',
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
            label: 'Total Future Balance',
            value: '\$${_result!.futureValue.toStringAsFixed(2)}',
            secondaryLabel: 'Interest Accrued',
            secondaryValue: '\$${_result!.totalInterest.toStringAsFixed(2)}',
            formula: 'A = P(1+r/n)^nt + PMT×[((1+r/n)^nt - 1)/(r/n)]',
            substitution: '\$$_principal + \$$_contribution/mo @ $_rate% = \$${_result!.futureValue.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
