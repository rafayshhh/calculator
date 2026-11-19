import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/finance_engine.dart';

class SimpleInterestScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SimpleInterestScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SimpleInterestScreen> createState() => _SimpleInterestScreenState();
}

class _SimpleInterestScreenState extends ConsumerState<SimpleInterestScreen> {
  String _principal = '5000.0';
  String _rate = '5.0';
  String _years = '3.0';
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
        _error = 'Please enter valid non-negative principal, rate, and time';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateSimpleInterest(principal: p, annualRatePercent: r, timeYears: t);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'principal': _principal, 'rate': _rate, 'years': _years});
      ref.read(historyProvider.notifier).add(
        'Simple Interest: \$$_principal @ $_rate% for $_years yrs',
        '\$${(res['interest'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/finance/simple_interest',
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
      _rate = '5.0';
      _years = '3.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'simple_interest',
      title: 'Simple Interest Calculator',
      description: 'Compute linear interest accumulation (I = P · r · t).',
      icon: Icons.savings_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Principal Amount',
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
          label: 'Time Duration',
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
            label: 'Total Accumulated Interest',
            value: '\$${(_result!['interest'] as double).toStringAsFixed(2)}',
            secondaryLabel: 'Final Total Amount',
            secondaryValue: '\$${(_result!['finalAmount'] as double).toStringAsFixed(2)}',
            formula: 'I = P × r × t',
            substitution: '\$$_principal × $_rate% × $_years yrs = \$${(_result!['interest'] as double).toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
