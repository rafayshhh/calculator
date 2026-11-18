import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/calculus_engine.dart';

class LimitEvaluatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const LimitEvaluatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<LimitEvaluatorScreen> createState() => _LimitEvaluatorScreenState();
}

class _LimitEvaluatorScreenState extends ConsumerState<LimitEvaluatorScreen> {
  String _c = '2.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _c = map['c']?.toString() ?? '2.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _c = '2.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'c': _c});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/limit',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final c = double.tryParse(_c) ?? 2.0;
    double f(double x) => (x - c).abs() < 1e-12 ? double.nan : (x * x - c * c) / (x - c);
    final res = CalculusEngine.limitApproximation(f, c);
    final leftLim = res['leftLimit'] as double;
    final rightLim = res['rightLimit'] as double;
    final limVal = res['limit'] as double;

    return ToolPageScaffold(
      title: 'Function Limit Evaluator',
      description: 'Computes left, right, and two-sided limits as x approaches target c',
      formula: 'lim_{x→c} f(x),  f(x) = (x² - c²) / (x - c) = x + c',
      onReset: _reset,
      onSave: () => _logHistory('lim_{x->$c} f(x)', '${limVal.toStringAsFixed(4)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'lim = ${limVal.toStringAsFixed(4)}',
          details: 'Approaching c = $c\nLeft Limit: ${leftLim.toStringAsFixed(4)}\nRight Limit: ${rightLim.toStringAsFixed(4)}\nTwo-Sided Limit Exists: ${res['exists']}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Approach Point c',
            initialValue: _c,
            onChanged: (val) => setState(() => _c = val),
          ),
      ],
    );
  }
}
