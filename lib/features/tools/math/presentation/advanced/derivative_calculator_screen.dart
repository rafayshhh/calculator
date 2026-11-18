import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/calculus_engine.dart';

class DerivativeCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DerivativeCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DerivativeCalculatorScreen> createState() => _DerivativeCalculatorScreenState();
}

class _DerivativeCalculatorScreenState extends ConsumerState<DerivativeCalculatorScreen> {
  String _c2 = '1.0';
  String _c1 = '4.0';
  String _c0 = '5.0';
  String _x = '2.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _c2 = map['c2']?.toString() ?? '1.0';
        _c1 = map['c1']?.toString() ?? '4.0';
        _c0 = map['c0']?.toString() ?? '5.0';
        _x = map['x']?.toString() ?? '2.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _c2 = '1.0';
      _c1 = '4.0';
      _c0 = '5.0';
      _x = '2.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'c2': _c2, 'c1': _c1, 'c0': _c0, 'x': _x});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/derivative',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final c2 = double.tryParse(_c2) ?? 0.0;
    final c1 = double.tryParse(_c1) ?? 0.0;
    final c0 = double.tryParse(_c0) ?? 0.0;
    final x = double.tryParse(_x) ?? 0.0;
    final res = CalculusEngine.polynomialDerivative([c0, c1, c2], x);
    final fVal = res['fx'] as double;
    final d1 = res['firstDerivative'] as double;
    final d2 = res['secondDerivative'] as double;
    final polyStr = res['polyString'] as String;
    final derivStr = res['derivativeString'] as String;

    return ToolPageScaffold(
      title: 'Numerical & Polynomial Derivative',
      description: 'First and second order derivatives with concavity analysis',
      formula: 'f'(x) ≈ [f(x+h) - f(x-h)] / (2h), f''(x) ≈ [f(x+h) - 2f(x) + f(x-h)] / h²',
      onReset: _reset,
      onSave: () => _logHistory('d/dx($polyStr) at x=$x', 'f'=$d1, f''=$d2'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'f'(x) = ${d1.toStringAsFixed(4)}',
          details: 'P(x) = $polyStr\nP'(x) = $derivStr\nf($x) = ${fVal.toStringAsFixed(4)}\nf''($x) = ${d2.toStringAsFixed(4)}',
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
            label: 'Evaluate at x',
            initialValue: _x,
            onChanged: (val) => setState(() => _x = val),
          ),
      ],
    );
  }
}
