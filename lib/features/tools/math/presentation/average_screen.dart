import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/math_utilities_engine.dart';

class AverageScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const AverageScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<AverageScreen> createState() => _AverageScreenState();
}

class _AverageScreenState extends ConsumerState<AverageScreen> {
  final TextEditingController _ctrl = TextEditingController(text: '12, 15, 23, 42, 55, 68');
  AverageResult? _result;
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
    final raw = _ctrl.text.replaceAll(',', ' ').split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    final numbers = <double>[];
    for (final s in raw) {
      final v = double.tryParse(s);
      if (v != null) numbers.add(v);
    }

    if (numbers.isEmpty) {
      setState(() {
        _result = null;
        _error = 'Please enter a comma or space separated list of numbers';
      });
      return;
    }

    try {
      final res = MathUtilitiesEngine.calculateAverage(numbers);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'input': _ctrl.text});
      ref.read(historyProvider.notifier).add(
        'Average: ${_ctrl.text}',
        'Mean: ${res.mean.toStringAsFixed(2)}',
        toolRoute: '/tools/math/average',
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
      toolId: 'average',
      title: 'Average & Mean Calculator',
      description: 'Calculate arithmetic mean, median, sum, and range of number sets.',
      icon: Icons.functions_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _ctrl.text = '12, 15, 23, 42, 55, 68';
        _calculate();
      },
      inputs: [
        TextField(
          controller: _ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Dataset Values (Comma or Space Separated)',
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
            label: 'Arithmetic Mean (Average)',
            value: _result!.mean.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Sample Size',
            secondaryValue: '${_result!.count} values',
            formula: 'Mean = (Σ x) / N',
            substitution: 'Sum = ${_result!.sum}, Count = ${_result!.count}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Median', value: '${_result!.median}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Minimum Value', value: '${_result!.min}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Maximum Value', value: '${_result!.max}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Total Sum', value: '${_result!.sum}'),
        ],
      ],
    );
  }
}
