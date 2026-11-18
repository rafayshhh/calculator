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

class RangeIqrScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RangeIqrScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RangeIqrScreen> createState() => _RangeIqrScreenState();
}

class _RangeIqrScreenState extends ConsumerState<RangeIqrScreen> {
  final TextEditingController _ctrl = TextEditingController(text: '3, 7, 8, 5, 12, 14, 21, 13, 18');
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
      final res = StatisticsEngine.calculateRangeIQR(dataset);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'input': _ctrl.text});
      ref.read(historyProvider.notifier).add(
        'Range & IQR: ${_ctrl.text}',
        'IQR=${res['iqr']}',
        toolRoute: '/tools/math/range_iqr',
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
      toolId: 'range_iqr',
      title: 'Range & Interquartile Range (IQR)',
      description: 'Compute statistical spread, quartiles Q1/Q3, and outlier threshold fences.',
      icon: Icons.border_vertical_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _ctrl.text = '3, 7, 8, 5, 12, 14, 21, 13, 18';
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
            label: 'Interquartile Range (IQR)',
            value: '${_result!['iqr']}',
            secondaryLabel: 'Statistical Range',
            secondaryValue: '${_result!['range']}',
            formula: 'IQR = Q3 - Q1',
            substitution: 'Q1 = ${_result!['q1']}, Q3 = ${_result!['q3']}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Lower Outlier Fence', value: '${_result!['lowerFence']}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Upper Outlier Fence', value: '${_result!['upperFence']}'),
        ],
      ],
    );
  }
}
