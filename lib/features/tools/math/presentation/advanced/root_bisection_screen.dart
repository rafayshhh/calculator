import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/calculus_engine.dart';

class RootBisectionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RootBisectionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RootBisectionScreen> createState() => _RootBisectionScreenState();
}

class _RootBisectionScreenState extends ConsumerState<RootBisectionScreen> {
  String _a = '0.0';
  String _b = '2.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '0.0';
        _b = map['b']?.toString() ?? '2.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '0.0';
      _b = '2.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/root_bisection',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = double.tryParse(_a) ?? 0.0;
    final b = double.tryParse(_b) ?? 2.0;
    double f(double x) => x * x - 2.0;
    final res = CalculusEngine.bisectionRoot(f, a, b);
    final rootVal = res['root'] as double;
    final iter = res['iterations'] as int;

    return ToolPageScaffold(
      title: 'Bisection Root Finder',
      description: 'Locates transcendental roots in interval [a, b] using binary subdivision',
      formula: 'c = (a + b) / 2, until |f(c)| < ε',
      onReset: _reset,
      onSave: () => _logHistory('Bisection root on [$a, $b]', 'x ≈ ${rootVal.toStringAsFixed(6)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Root x ≈ ${rootVal.toStringAsFixed(6)}',
          details: 'Iterations: $iter\nf(root) = ${(res['fc'] as double).toStringAsFixed(8)}\nConverged: ${res['converged']}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Interval Start a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Interval End b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
      ],
    );
  }
}
