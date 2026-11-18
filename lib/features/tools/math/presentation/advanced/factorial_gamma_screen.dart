import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/k_stat_row.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/advanced_math_engine.dart';

class FactorialGammaScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const FactorialGammaScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<FactorialGammaScreen> createState() => _FactorialGammaScreenState();
}

class _FactorialGammaScreenState extends ConsumerState<FactorialGammaScreen> {
  String _valN = '5.0';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final n = double.tryParse(_valN);
    if (n == null || n > 170) {
      setState(() {
        _result = null;
        _error = 'Please enter a valid number (n ≤ 170 to avoid double overflow)';
      });
      return;
    }

    try {
      final res = AdvancedMathEngine.calculateFactorialGamma(n);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'valN': _valN});
      ref.read(historyProvider.notifier).add(
        'Factorial & Gamma: $_valN',
        'n!=${(res['factorial'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/math/advanced/factorial_gamma',
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
    setState(() => _valN = '5.0');
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'factorial_gamma',
      title: 'Factorial & Gamma Function',
      description: 'Evaluate integer factorials (n!) and real Gamma function values Γ(x).',
      icon: Icons.priority_high_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Input Value (n)',
          value: _valN,
          onChanged: (v) {
            _valN = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Factorial (n!)',
            value: (_result!['factorial'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Gamma Function Γ(n)',
            secondaryValue: (_result!['gamma'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: 'n! = Γ(n + 1)',
            substitution: '$_valN! = ${(_result!['factorial'] as double).toStringAsFixed(4)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
