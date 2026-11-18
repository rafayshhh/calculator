import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/calculus_engine.dart';

class CurveTangentScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CurveTangentScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CurveTangentScreen> createState() => _CurveTangentScreenState();
}

class _CurveTangentScreenState extends ConsumerState<CurveTangentScreen> {
  String _x0 = '2.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _x0 = map['x0']?.toString() ?? '2.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _x0 = '2.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'x0': _x0});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/curve_tangent',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final x0 = double.tryParse(_x0) ?? 2.0;
    double f(double x) => x * x;
    final res = CalculusEngine.tangentAndNormalLine(f, x0);
    final tanEq = res['tangentEquation'] as String;
    final normEq = res['normalEquation'] as String;
    final mTan = res['tangentSlope'] as double;

    return ToolPageScaffold(
      title: 'Tangent & Normal Line Equations',
      description: 'Computes tangent and normal slopes and linear equations at curve point',
      formula: 'y - y₀ = m(x - x₀),  m_normal = -1 / m',
      onReset: _reset,
      onSave: () => _logHistory('Tangent at x₀=$x0', '$tanEq'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$tanEq',
          details: 'Tangent: $tanEq\nNormal: $normEq\nPoint: ($x0, ${(res['y0'] as double).toStringAsFixed(2)})\nSlope m = ${mTan.toStringAsFixed(4)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Curve Point x₀',
            initialValue: _x0,
            onChanged: (val) => setState(() => _x0 = val),
          ),
      ],
    );
  }
}
