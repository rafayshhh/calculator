import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/everyday_engine.dart';

class PercentageCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PercentageCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends ConsumerState<PercentageCalculatorScreen> {
  int _modeIndex = 0; // 0: X% of Y, 1: X is what % of Y, 2: % change from X to Y
  String _valX = '25.0';
  String _valY = '200.0';
  double? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _modeIndex = data['modeIndex'] ?? 0;
        _valX = data['valX']?.toString() ?? '25.0';
        _valY = data['valY']?.toString() ?? '200.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final x = double.tryParse(_valX);
    final y = double.tryParse(_valY);
    if (x == null || y == null) {
      setState(() {
        _result = null;
        _error = 'Please enter valid numbers';
      });
      return;
    }

    try {
      double r;
      if (_modeIndex == 0) {
        r = EverydayEngine.calculatePercentageOf(x, y);
      } else if (_modeIndex == 1) {
        r = EverydayEngine.calculateIsWhatPercent(x, y);
      } else {
        r = EverydayEngine.calculatePercentageChange(x, y);
      }

      setState(() {
        _error = null;
        _result = r;
      });

      final stateJson = jsonEncode({'modeIndex': _modeIndex, 'valX': _valX, 'valY': _valY});
      ref.read(historyProvider.notifier).add(
        'Percentage: \${_modeIndex == 0 ? "$_valX% of $_valY" : _modeIndex == 1 ? "$_valX is what % of $_valY" : "% change from $_valX to $_valY"}',
        '\${r.toStringAsFixed(2)}\${_modeIndex != 0 ? "%" : ""}',
        toolRoute: '/tools/everyday/percentage',
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
      _modeIndex = 0;
      _valX = '25.0';
      _valY = '200.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final label = _modeIndex == 0
        ? '$_valX% of $_valY'
        : _modeIndex == 1
            ? '$_valX of $_valY'
            : 'Change from $_valX to $_valY';
    final unit = _modeIndex == 0 ? '' : '%';

    return ToolPageScaffold(
      toolId: 'percentage',
      title: 'Percentage Calculator',
      description: 'Compute percent of values, proportions, and percentage increase/decrease.',
      icon: Icons.percent_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('X% of Y')),
            ButtonSegment(value: 1, label: Text('X is % of Y')),
            ButtonSegment(value: 2, label: Text('% Change')),
          ],
          selected: {_modeIndex},
          onSelectionChanged: (s) {
            setState(() => _modeIndex = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: _modeIndex == 0 ? 'Percentage (X)' : 'Value (X)',
          suffix: _modeIndex == 0 ? '%' : '',
          value: _valX,
          onChanged: (v) {
            _valX = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Total / Base Value (Y)',
          value: _valY,
          onChanged: (v) {
            _valY = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: label,
            value: '\${_result!.toStringAsFixed(2)} \$unit',
            formula: _modeIndex == 0 ? '(X / 100) × Y' : _modeIndex == 1 ? '(X / Y) × 100' : '((Y - X) / X) × 100',
            substitution: 'Result = \${_result!.toStringAsFixed(2)} \$unit',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
