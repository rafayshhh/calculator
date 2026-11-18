import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/statistics_engine.dart';

class DistributionsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DistributionsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DistributionsScreen> createState() => _DistributionsScreenState();
}

class _DistributionsScreenState extends ConsumerState<DistributionsScreen> {
  String _trialsN = '10';
  String _successesK = '6';
  String _probP = '0.5';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final n = int.tryParse(_trialsN);
    final k = int.tryParse(_successesK);
    final p = double.tryParse(_probP);

    if (n == null || k == null || p == null || n < 0 || k < 0 || k > n || p < 0 || p > 1) {
      setState(() {
        _result = null;
        _error = 'Values must satisfy 0 ≤ k ≤ n and 0 ≤ p ≤ 1';
      });
      return;
    }

    try {
      final res = StatisticsEngine.calculateBinomialDistribution(trials: n, successes: k, probability: p);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'n': _trialsN, 'k': _successesK, 'p': _probP});
      ref.read(historyProvider.notifier).add(
        'Binomial: n=$_trialsN, k=$_successesK, p=$_probP',
        'P(X=k)=${(res['exactProbability'] as double).toStringAsFixed(4)}',
        toolRoute: '/tools/math/distributions',
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
    setState(() {
      _trialsN = '10';
      _successesK = '6';
      _probP = '0.5';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'distributions',
      title: 'Probability Distributions',
      description: 'Compute binomial probability mass function P(X = k) and cumulative likelihoods.',
      icon: Icons.stacked_line_chart_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Number of Trials (n)',
                value: _trialsN,
                onChanged: (v) {
                  _trialsN = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Exact Successes (k)',
                value: _successesK,
                onChanged: (v) {
                  _successesK = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Success Prob (p)',
                value: _probP,
                onChanged: (v) {
                  _probP = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Exact Probability P(X = k)',
            value: (_result!['exactProbability'] as double).toStringAsFixed(6).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Percentage',
            secondaryValue: '${((_result!['exactProbability'] as double) * 100).toStringAsFixed(3)}%',
            formula: 'P(X=k) = (nCk) × p^k × (1-p)^(n-k)',
            substitution: 'P(X=$_successesK) = ${(_result!['exactProbability'] as double).toStringAsFixed(6)}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Cumulative P(X ≤ k)', value: '${(_result!['cumulativeProbability'] as double).toStringAsFixed(6)}'),
        ],
      ],
    );
  }
}
