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

class EmiScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const EmiScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends ConsumerState<EmiScreen> {
  String _principal = '20000.0';
  String _rate = '8.5';
  String _months = '36';
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
        _error = 'Please enter positive principal, rate, and tenure';
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
        'EMI: \$$_principal @ $_rate% for $_months mos',
        '\$${res.monthlyPayment.toStringAsFixed(2)}/mo',
        toolRoute: '/tools/financial/emi',
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
      _principal = '20000.0';
      _rate = '8.5';
      _months = '36';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_emi',
      title: 'Equated Monthly Installment (EMI)',
      description: 'Compute precise monthly loan installment and total repayment breakdown.',
      icon: Icons.calendar_view_month_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Loan Principal',
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
          label: 'Tenure',
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
            label: 'Monthly EMI Payment',
            value: '\$${_result!.monthlyPayment.toStringAsFixed(2)}',
            secondaryLabel: 'Total Interest',
            secondaryValue: '\$${_result!.totalInterest.toStringAsFixed(2)}',
            formula: 'EMI = [P × r × (1+r)^n] / [(1+r)^n - 1]',
            substitution: 'EMI = \$${_result!.monthlyPayment.toStringAsFixed(2)} / month',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
