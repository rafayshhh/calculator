import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/calculus_engine.dart';

class IntegralCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const IntegralCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<IntegralCalculatorScreen> createState() => _IntegralCalculatorScreenState();
}

class _IntegralCalculatorScreenState extends ConsumerState<IntegralCalculatorScreen> {
  String _c2 = '1.0';
  String _c1 = '0.0';
  String _c0 = '0.0';
  String _a = '0.0';
  String _b = '3.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _c2 = map['c2']?.toString() ?? '1.0';
        _c1 = map['c1']?.toString() ?? '0.0';
        _c0 = map['c0']?.toString() ?? '0.0';
        _a = map['a']?.toString() ?? '0.0';
        _b = map['b']?.toString() ?? '3.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _c2 = '1.0';
      _c1 = '0.0';
      _c0 = '0.0';
      _a = '0.0';
      _b = '3.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'c2': _c2, 'c1': _c1, 'c0': _c0, 'a': _a, 'b': _b});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/integral',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final c2 = double.tryParse(_c2) ?? 0.0;
    final c1 = double.tryParse(_c1) ?? 0.0;
    final c0 = double.tryParse(_c0) ?? 0.0;
    final a = double.tryParse(_a) ?? 0.0;
    final b = double.tryParse(_b) ?? 0.0;
    final res = CalculusEngine.polynomialDefiniteIntegral([c0, c1, c2], a, b);
    final integralVal = res['integral'] as double;

    return ToolPageScaffold(
      title: 'Definite Integral Calculator',
      description: 'Computes exact polynomial and Simpson integration across bounds [a, b]',
      formula: "∫_a^b P(x)dx = [F(b) - F(a)], F'(x) = P(x)",
      onReset: _reset,
      onSave: () => _logHistory('∫_{$a}^{$b} P(x)dx', '${integralVal.toStringAsFixed(4)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '∫ P(x)dx = ${integralVal.toStringAsFixed(4)}',
          details: 'Bounds: [$a, $b]\nAntiderivative F(b) = ${(res['antiderivativeAtB'] as double).toStringAsFixed(4)}\nAntiderivative F(a) = ${(res['antiderivativeAtA'] as double).toStringAsFixed(4)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Coeff x²',
            initialValue: _c2,
            onChanged: (val) => setState(() => _c2 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Coeff x',
            initialValue: _c1,
            onChanged: (val) => setState(() => _c1 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Constant',
            initialValue: _c0,
            onChanged: (val) => setState(() => _c0 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Lower Bound a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Upper Bound b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
      ],
    );
  }
}
