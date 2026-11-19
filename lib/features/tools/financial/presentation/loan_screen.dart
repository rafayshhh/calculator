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

class LoanScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const LoanScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends ConsumerState<LoanScreen> {
  String _principal = '15000.0';
  String _rate = '7.0';
  String _months = '24';
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
    final m = int.tryParse(_months);
    if (p == null || r == null || m == null || p <= 0 || r <= 0 || m <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid positive numbers';
      });
      return;
    }

    try {
      final res = FinancialEngine.calculateLoan(principal: p, annualRate: r, termMonths: m);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'principal': _principal, 'rate': _rate, 'months': _months});
      ref.read(historyProvider.notifier).add(
        'Loan: \$$_principal @ $_rate% for $_months mos',
        '\$${res.monthlyPayment.toStringAsFixed(2)}/mo',
        toolRoute: '/tools/financial/loan',
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
      _principal = '15000.0';
      _rate = '7.0';
      _months = '24';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_loan',
      title: 'Loan Amortization',
      description: 'Compute total principal amortization, interest costs, and paydown schedule.',
      icon: Icons.account_balance_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Principal Loan Amount',
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
          label: 'Term (Months)',
          suffix: 'months',
          value: _months,
          onChanged: (v) {
            _months = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Monthly Repayment',
            value: '\$${_result!.monthlyPayment.toStringAsFixed(2)}',
            secondaryLabel: 'Total Lifetime Payment',
            secondaryValue: '\$${_result!.totalPayment.toStringAsFixed(2)}',
            formula: 'Amortized Monthly Payment',
            substitution: 'Total Repaid: \$${_result!.totalPayment.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
