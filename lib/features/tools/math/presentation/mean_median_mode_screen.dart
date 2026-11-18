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

class MeanMedianModeScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MeanMedianModeScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MeanMedianModeScreen> createState() => _MeanMedianModeScreenState();
}

class _MeanMedianModeScreenState extends ConsumerState<MeanMedianModeScreen> {
  final TextEditingController _ctrl = TextEditingController(text: '4, 8, 6, 5, 3, 2, 8, 9, 2, 5');
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
      final res = StatisticsEngine.calculateMeanMedianMode(dataset);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'input': _ctrl.text});
      ref.read(historyProvider.notifier).add(
        'Central Tendency: ${_ctrl.text}',
        'Mean=${(res['mean'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/math/mean_median_mode',
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
      toolId: 'mean_median_mode',
      title: 'Mean, Median & Mode',
      description: 'Analyze central tendency metrics across sample datasets.',
      icon: Icons.equalizer_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _ctrl.text = '4, 8, 6, 5, 3, 2, 8, 9, 2, 5';
        _calculate();
      },
      inputs: [
        TextField(
          controller: _ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Dataset Values (Comma or space separated)',
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
            label: 'Arithmetic Mean (μ / x̄)',
            value: (_result!['mean'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Median',
            secondaryValue: '${_result!['median']}',
            formula: 'Mean = Σx / N',
            substitution: 'Mode: ${_result!['mode']}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Median', value: '${_result!['median']}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Mode', value: '${_result!['mode']}'),
        ],
      ],
    );
  }
}
