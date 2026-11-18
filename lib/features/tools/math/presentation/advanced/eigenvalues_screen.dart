import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/linear_algebra_engine.dart';

class EigenvaluesScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const EigenvaluesScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<EigenvaluesScreen> createState() => _EigenvaluesScreenState();
}

class _EigenvaluesScreenState extends ConsumerState<EigenvaluesScreen> {
  String _a = '4.0';
  String _b = '1.0';
  String _c = '2.0';
  String _d = '3.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '4.0';
        _b = map['b']?.toString() ?? '1.0';
        _c = map['c']?.toString() ?? '2.0';
        _d = map['d']?.toString() ?? '3.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '4.0';
      _b = '1.0';
      _c = '2.0';
      _d = '3.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b, 'c': _c, 'd': _d});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/eigenvalues',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = double.tryParse(_a) ?? 0.0;
    final b = double.tryParse(_b) ?? 0.0;
    final c = double.tryParse(_c) ?? 0.0;
    final d = double.tryParse(_d) ?? 0.0;
    final res = LinearAlgebraEngine.eigenvalues2x2(a, b, c, d);
    final eigStr = res['eigenvaluesString'] as String;
    final tr = res['trace'] as double;
    final dt = res['determinant'] as double;

    return ToolPageScaffold(
      title: 'Matrix Eigenvalues & Trace',
      description: 'Computes eigenvalues, trace, and determinant for 2x2 matrix',
      formula: 'det(A - λI) = 0  =>  λ² - Tr(A)λ + det(A) = 0',
      onReset: _reset,
      onSave: () => _logHistory('Eigenvalues [[$a, $b], [$c, $d]]', '$eigStr'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$eigStr',
          details: 'Trace: ${tr.toStringAsFixed(3)}\nDeterminant: ${dt.toStringAsFixed(3)}\nEquation: ${res['characteristicEq']}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Matrix [0,0]',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Matrix [0,1]',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Matrix [1,0]',
            initialValue: _c,
            onChanged: (val) => setState(() => _c = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Matrix [1,1]',
            initialValue: _d,
            onChanged: (val) => setState(() => _d = val),
          ),
      ],
    );
  }
}
