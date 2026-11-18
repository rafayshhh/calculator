import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class FibonacciGoldenScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const FibonacciGoldenScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<FibonacciGoldenScreen> createState() => _FibonacciGoldenScreenState();
}

class _FibonacciGoldenScreenState extends ConsumerState<FibonacciGoldenScreen> {
  String _n = '20';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _n = map['n']?.toString() ?? '20';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _n = '20';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'n': _n});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/fibonacci_golden',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final n = int.tryParse(_n) ?? 0;
    final res = NumberTheoryEngine.fibonacciAndGolden(n);
    final fn = res['fibonacciN'] as int? ?? 0;
    final ratio = res['ratio'] as double? ?? 0.0;
    final phi = res['goldenRatio'] as double? ?? 1.6180339887;
    final diff = res['difference'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Fibonacci & Golden Ratio (φ)',
      description: 'Calculates Fn, ratio Fn/Fn-1, and convergence to Golden Ratio φ',
      formula: 'F_n = F_{n-1} + F_{n-2},  lim (F_n / F_{n-1}) = φ = (1 + √5)/2',
      onReset: _reset,
      onSave: () => _logHistory('Fibonacci($n)', '$fn (ratio ${ratio.toStringAsFixed(6)})'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'F_$n = $fn',
          details: 'F_$n: $fn\nRatio F_$n / F_${n-1}: ${ratio.toStringAsFixed(8)}\nGolden Ratio φ: ${phi.toStringAsFixed(8)}\nAbsolute Error: ${diff.toStringAsExponential(4)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Index n',
            initialValue: _n,
            onChanged: (val) => setState(() => _n = val),
          ),
      ],
    );
  }
}
