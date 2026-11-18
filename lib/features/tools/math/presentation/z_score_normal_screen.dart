import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/advanced_statistics_engine.dart';

class ZScoreNormalScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ZScoreNormalScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ZScoreNormalScreen> createState() => _ZScoreNormalScreenState();
}

class _ZScoreNormalScreenState extends ConsumerState<ZScoreNormalScreen> {
  String _x = '115.0';
  String _mean = '100.0';
  String _stdDev = '15.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _x = map['x']?.toString() ?? '115.0';
        _mean = map['mean']?.toString() ?? '100.0';
        _stdDev = map['stdDev']?.toString() ?? '15.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _x = '115.0';
      _mean = '100.0';
      _stdDev = '15.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'x': _x, 'mean': _mean, 'stdDev': _stdDev});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/z_score_normal',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final x = double.tryParse(_x) ?? 0.0;
    final mean = double.tryParse(_mean) ?? 0.0;
    final stdDev = double.tryParse(_stdDev) ?? 1.0;
    final res = AdvancedStatisticsEngine.calculateZScore(rawScore: x, mean: mean, stdDev: stdDev);
    final z = res['zScore'] as double? ?? 0.0;
    final pLess = res['pLessEqual'] as double? ?? 0.0;
    final pGreater = res['pGreaterEqual'] as double? ?? 0.0;
    final percentile = res['percentile'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Z-Score & Normal Distribution CDF',
      description: 'Calculates standard score Z, cumulative probability, and tail p-values',
      formula: 'Z = (x - μ) / σ,  Φ(Z) = P(X ≤ x)',
      onReset: _reset,
      onSave: () => _logHistory('Z-score for x=$x (μ=$mean, σ=$stdDev)', 'Z=${z.toStringAsFixed(2)}, p=${pLess.toStringAsFixed(4)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Z = ${z.toStringAsFixed(3)}',
          details: 'Z-Score: ${z.toStringAsFixed(4)}\nPercentile Rank: ${percentile.toStringAsFixed(2)}%\nP(X ≤ x): ${pLess.toStringAsFixed(5)}\nP(X ≥ x): ${pGreater.toStringAsFixed(5)}\nTwo-Tailed p: ${(res['pTwoTailed'] as double? ?? 0.0).toStringAsFixed(5)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Raw Score x',
            initialValue: _x,
            onChanged: (val) => setState(() => _x = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Population Mean μ',
            initialValue: _mean,
            onChanged: (val) => setState(() => _mean = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Standard Deviation σ',
            initialValue: _stdDev,
            onChanged: (val) => setState(() => _stdDev = val),
          ),
      ],
    );
  }
}
