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

class PercentileScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PercentileScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PercentileScreen> createState() => _PercentileScreenState();
}

class _PercentileScreenState extends ConsumerState<PercentileScreen> {
  final TextEditingController _ctrl = TextEditingController(text: '15, 20, 35, 40, 50');
  String _pPercent = '75';
  double? _result;
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
    final p = double.tryParse(_pPercent);
    if (p == null || p < 0 || p > 100) {
      setState(() {
        _result = null;
        _error = 'Percentile must be between 0 and 100';
      });
      return;
    }

    try {
      final dataset = StatisticsEngine.parseDataset(_ctrl.text);
      final res = StatisticsEngine.calculatePercentile(dataset, p);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'input': _ctrl.text, 'p': _pPercent});
      ref.read(historyProvider.notifier).add(
        'Percentile: ${_pPercent}th percentile of dataset',
        res.toStringAsFixed(2),
        toolRoute: '/tools/math/percentile',
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
      toolId: 'percentile',
      title: 'Percentile Calculator',
      description: 'Compute arbitrary kth percentile thresholds using linear rank interpolation.',
      icon: Icons.stacked_bar_chart_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _ctrl.text = '15, 20, 35, 40, 50';
        _pPercent = '75';
        _calculate();
      },
      inputs: [
        TextField(
          controller: _ctrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Dataset Values', border: OutlineInputBorder()),
          onChanged: (_) => _calculate(),
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Percentile (0 - 100)',
          suffix: '%',
          value: _pPercent,
          onChanged: (v) {
            _pPercent = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: '${_pPercent}th Percentile Value',
            value: _result!.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: 'Percentile Rank Interpolation',
            substitution: 'Rank = (P / 100) × (N - 1)',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
