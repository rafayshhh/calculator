import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/advanced_statistics_engine.dart';

class PoissonDistributionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PoissonDistributionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PoissonDistributionScreen> createState() => _PoissonDistributionScreenState();
}

class _PoissonDistributionScreenState extends ConsumerState<PoissonDistributionScreen> {
  String _lambda = '4.0';
  String _k = '3';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _lambda = map['lambda']?.toString() ?? '4.0';
        _k = map['k']?.toString() ?? '3';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _lambda = '4.0';
      _k = '3';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'lambda': _lambda, 'k': _k});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/poisson_distribution',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final l = double.tryParse(_lambda) ?? 1.0;
    final k = int.tryParse(_k) ?? 0;
    final res = AdvancedStatisticsEngine.poissonDistribution(lambda: l, k: k);
    final pmf = res['pmf'] as double? ?? 0.0;
    final cdf = res['cdf'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Poisson Distribution Probability',
      description: 'Computes exact PMF P(X = k) and cumulative probability P(X ≤ k)',
      formula: 'P(X = k) = (λ^k · e^(-λ)) / k!',
      onReset: _reset,
      onSave: () => _logHistory('Poisson(λ=$l, k=$k)', 'P(X=$k)=${(pmf * 100).toStringAsFixed(2)}%'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'P(X = $k) = ${(pmf * 100).toStringAsFixed(2)}%',
          details: 'Exact PMF P(X = $k): ${pmf.toStringAsFixed(6)}\nCumulative P(X ≤ $k): ${cdf.toStringAsFixed(6)}\nDistribution Mean: $l\nStandard Deviation: ${(res['stdDev'] as double? ?? 0.0).toStringAsFixed(4)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Event Rate λ (Arrivals/Period)',
            initialValue: _lambda,
            onChanged: (val) => setState(() => _lambda = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Number of Occurrences k',
            initialValue: _k,
            onChanged: (val) => setState(() => _k = val),
          ),
      ],
    );
  }
}
