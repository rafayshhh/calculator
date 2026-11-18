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

class LoanPaymentScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const LoanPaymentScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<LoanPaymentScreen> createState() => _LoanPaymentScreenState();
}

class _LoanPaymentScreenState extends ConsumerState<LoanPaymentScreen> {
  String _principal = '25000.0';
  String _rate = '6.5';
  String _years = '5.0';
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
    if (p == null || r == null || t == null || p <= 0 || r <= 0 || t <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter positive principal, rate, and tenure';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateLoan(principal: p, annualRatePercent: r, timeYears: t);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'principal': _principal, 'rate': _rate, 'years': _years});
      ref.read(historyProvider.notifier).add(
        'Loan Payment: \$$_principal @ $_rate% for $_years yrs',
        '\$${(res['monthlyPayment'] as double).toStringAsFixed(2)}/mo',
        toolRoute: '/tools/finance/loan_payment',
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
      _principal = '25000.0';
      _rate = '6.5';
      _years = '5.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'loan_payment',
      title: 'Loan Payment Calculator',
      description: 'Calculate monthly installment payments and interest totals on personal or auto loans.',
      icon: Icons.payments_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Loan Amount (Principal)',
          prefix: '\$',
          value: _principal,
          onChanged: (v) {
            _principal = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Annual Interest Rate',
          suffix: '%',
          value: _rate,
          onChanged: (v) {
            _rate = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Term Length',
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
            label: 'Monthly Payment (EMI)',
            value: '\$${(_result!['monthlyPayment'] as double).toStringAsFixed(2)}',
            secondaryLabel: 'Total Interest',
            secondaryValue: '\$${(_result!['totalInterest'] as double).toStringAsFixed(2)}',
            formula: 'EMI = [P × r × (1+r)^n] / [(1+r)^n - 1]',
            substitution: '\$$_principal @ $_rate% for $_years yrs = \$${(_result!['monthlyPayment'] as double).toStringAsFixed(2)}/mo',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
