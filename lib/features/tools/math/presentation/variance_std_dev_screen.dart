import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/statistics_engine.dart';

class VarianceStdDevScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const VarianceStdDevScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<VarianceStdDevScreen> createState() => _VarianceStdDevScreenState();
}

class _VarianceStdDevScreenState extends ConsumerState<VarianceStdDevScreen> {
  final TextEditingController _ctrl = TextEditingController(text: '10, 12, 23, 23, 16, 23, 21, 16');
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final dataset = StatisticsEngine.parseDataset(_ctrl.text);
      final res = StatisticsEngine.calculateVarianceStdDev(dataset);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'input': _ctrl.text});
      ref.read(historyProvider.notifier).add(
        'Std Dev: ${_ctrl.text}',
        's=${(res['sampleStandardDeviation'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/math/variance_std_dev',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'variance_std_dev',
      title: 'Variance & Standard Deviation',
      description: 'Compute sample and population dispersion, variance, and standard deviation.',
      icon: Icons.scatter_plot_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _ctrl.text = '10, 12, 23, 23, 16, 23, 21, 16';
        _calculate();
      },
      inputs: [
        TextField(
          controller: _ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Dataset Values',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _calculate(),
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Sample Standard Deviation (s)',
            value: (_result!['sampleStandardDeviation'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Sample Variance (s²)',
            secondaryValue: (_result!['sampleVariance'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: 's = √[Σ(x - x̄)² / (n - 1)]',
            substitution: 'Population σ = ${(_result!['standardDeviation'] as double).toStringAsFixed(4)}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Population Standard Deviation (σ)', value: '${(_result!['standardDeviation'] as double).toStringAsFixed(4)}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Population Variance (σ²)', value: '${(_result!['variance'] as double).toStringAsFixed(4)}'),
        ],
      ],
    );
  }
}
