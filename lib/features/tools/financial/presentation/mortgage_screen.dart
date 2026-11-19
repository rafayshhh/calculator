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

class MortgageScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MortgageScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends ConsumerState<MortgageScreen> {
  String _principal = '300000.0';
  String _rate = '6.5';
  String _years = '30';
  LoanResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final p = double.tryParse(_principal);
    final r = double.tryParse(_rate);
    final y = int.tryParse(_years);
    if (p == null || r == null || y == null || p <= 0 || r <= 0 || y <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid positive values';
      });
      return;
    }

    try {
      final res = FinancialEngine.calculateLoan(principal: p, annualRate: r, termMonths: y * 12);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'principal': _principal, 'rate': _rate, 'years': _years});
      ref.read(historyProvider.notifier).add(
        'Mortgage: \$$_principal @ $_rate% for $_years yrs',
        '\$${res.monthlyPayment.toStringAsFixed(2)}/mo',
        toolRoute: '/tools/financial/mortgage',
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
      _principal = '300000.0';
      _rate = '6.5';
      _years = '30';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_mortgage',
      title: 'Mortgage Amortization',
      description: 'Compute residential mortgage installments and aggregate interest payments.',
      icon: Icons.home_work_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Total Mortgage Borrowed',
          prefix: '\$',
          value: _principal,
          onChanged: (v) {
            _principal = v;
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
            label: 'Monthly Principal & Interest',
            value: '\$${_result!.monthlyPayment.toStringAsFixed(2)}',
            secondaryLabel: 'Lifetime Interest',
            secondaryValue: '\$${_result!.totalInterest.toStringAsFixed(2)}',
            formula: 'Monthly = P × [r(1+r)^n] / [(1+r)^n - 1]',
            substitution: '\$${_result!.monthlyPayment.toStringAsFixed(2)} / month',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
