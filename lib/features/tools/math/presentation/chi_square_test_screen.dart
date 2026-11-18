import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/advanced_statistics_engine.dart';

class ChiSquareTestScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ChiSquareTestScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ChiSquareTestScreen> createState() => _ChiSquareTestScreenState();
}

class _ChiSquareTestScreenState extends ConsumerState<ChiSquareTestScreen> {
  String _observed = '22, 18, 20, 25, 15';
  String _expected = '20, 20, 20, 20, 20';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _observed = map['observed']?.toString() ?? '22, 18, 20, 25, 15';
        _expected = map['expected']?.toString() ?? '20, 20, 20, 20, 20';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _observed = '22, 18, 20, 25, 15';
      _expected = '20, 20, 20, 20, 20';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'observed': _observed, 'expected': _expected});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/chi_square_test',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final obs = _observed.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    final exp = _expected.split(',').map((e) => double.tryParse(e.trim()) ?? 1.0).toList();
    final res = AdvancedStatisticsEngine.chiSquareTest(obs, exp);
    final chi = res['chiSquare'] as double? ?? 0.0;
    final df = res['degreesOfFreedom'] as int? ?? 0;

    return ToolPageScaffold(
      title: 'Chi-Square (χ²) Goodness of Fit',
      description: 'Tests observed frequencies against theoretical expected values',
      formula: 'χ² = ∑ [(O_i - E_i)² / E_i],  df = k - 1',
      onReset: _reset,
      onSave: () => _logHistory('χ² test df=$df', 'χ²=${chi.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'χ² = ${chi.toStringAsFixed(3)}',
          details: 'Chi-Square Test Statistic: ${chi.toStringAsFixed(4)}\nDegrees of Freedom (df): $df\nNumber of Bins: ${res['categoriesCount'] ?? 0}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Observed values (comma-separated)',
            initialValue: _observed,
            onChanged: (val) => setState(() => _observed = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Expected values (comma-separated)',
            initialValue: _expected,
            onChanged: (val) => setState(() => _expected = val),
          ),
      ],
    );
  }
}
