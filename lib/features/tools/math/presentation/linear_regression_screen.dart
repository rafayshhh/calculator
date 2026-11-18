import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/advanced_statistics_engine.dart';

class LinearRegressionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const LinearRegressionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<LinearRegressionScreen> createState() => _LinearRegressionScreenState();
}

class _LinearRegressionScreenState extends ConsumerState<LinearRegressionScreen> {
  String _xData = '1, 2, 3, 4, 5';
  String _yData = '2, 3.8, 6.1, 8.2, 9.9';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _xData = map['xData']?.toString() ?? '1, 2, 3, 4, 5';
        _yData = map['yData']?.toString() ?? '2, 3.8, 6.1, 8.2, 9.9';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _xData = '1, 2, 3, 4, 5';
      _yData = '2, 3.8, 6.1, 8.2, 9.9';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'xData': _xData, 'yData': _yData});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/linear_regression',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final xList = _xData.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    final yList = _yData.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    final res = AdvancedStatisticsEngine.linearRegression(xList, yList);
    final eq = res['equation'] as String? ?? 'N/A';
    final r = res['r'] as double? ?? 0.0;
    final r2 = res['rSquared'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Ordinary Least Squares Linear Regression',
      description: 'Finds best fit line y = mx + b, Pearson's r, and R² coefficient of determination',
      formula: 'y = mx + b,  m = [n∑xy - ∑x∑y] / [n∑x² - (∑x)²]',
      onReset: _reset,
      onSave: () => _logHistory('Regression n=${xList.length}', '$eq (R²=${r2.toStringAsFixed(3)})'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$eq',
          details: 'Regression Equation: $eq\nPearson Correlation r: ${r.toStringAsFixed(4)}\nCoefficient of Determination R²: ${(r2 * 100).toStringAsFixed(2)}%\nData Points Count: ${res['n'] ?? 0}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'X values (comma-separated)',
            initialValue: _xData,
            onChanged: (val) => setState(() => _xData = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Y values (comma-separated)',
            initialValue: _yData,
            onChanged: (val) => setState(() => _yData = val),
          ),
      ],
    );
  }
}
