import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/calculus_engine.dart';

class TaylorSeriesScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TaylorSeriesScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TaylorSeriesScreen> createState() => _TaylorSeriesScreenState();
}

class _TaylorSeriesScreenState extends ConsumerState<TaylorSeriesScreen> {
  String _x = '0.5';
  String _a = '0.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _x = map['x']?.toString() ?? '0.5';
        _a = map['a']?.toString() ?? '0.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _x = '0.5';
      _a = '0.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'x': _x, 'a': _a});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/taylor_series',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final x = double.tryParse(_x) ?? 0.5;
    final a = double.tryParse(_a) ?? 0.0;
    final t0 = 1.0;
    final t1 = (x - a);
    final t2 = (x - a) * (x - a) / 2.0;
    final t3 = (x - a) * (x - a) * (x - a) / 6.0;
    final approx = t0 + t1 + t2 + t3;

    return ToolPageScaffold(
      title: 'Taylor & Maclaurin Series',
      description: 'Polynomial approximation around expansion point a',
      formula: "f(x) ≈ f(a) + f'(a)(x-a) + f''(a)(x-a)²/2! + ...",
      onReset: _reset,
      onSave: () => _logHistory('Taylor P3($x) around a=$a', '${approx.toStringAsFixed(5)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'P₃($x) = ${approx.toStringAsFixed(5)}',
          details: 'Center a = $a\nTerm 0: $t0\nTerm 1: ${t1.toStringAsFixed(4)}\nTerm 2: ${t2.toStringAsFixed(4)}\nTerm 3: ${t3.toStringAsFixed(4)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Evaluation Point x',
            initialValue: _x,
            onChanged: (val) => setState(() => _x = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Expansion Center a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
      ],
    );
  }
}
