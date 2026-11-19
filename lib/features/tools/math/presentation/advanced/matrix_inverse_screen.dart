import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/linear_algebra_engine.dart';

class MatrixInverseScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MatrixInverseScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MatrixInverseScreen> createState() => _MatrixInverseScreenState();
}

class _MatrixInverseScreenState extends ConsumerState<MatrixInverseScreen> {
  String _a = '4.0';
  String _b = '7.0';
  String _c = '2.0';
  String _d = '6.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '4.0';
        _b = map['b']?.toString() ?? '7.0';
        _c = map['c']?.toString() ?? '2.0';
        _d = map['d']?.toString() ?? '6.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '4.0';
      _b = '7.0';
      _c = '2.0';
      _d = '6.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b, 'c': _c, 'd': _d});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/matrix_inverse',
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
    final res = LinearAlgebraEngine.inverse2x2(a, b, c, d);
    final isInvertible = res['isInvertible'] as bool? ?? false;
    final det = res['determinant'] as double? ?? 0.0;
    final matStr = isInvertible ? res['matrixString'] as String : res['error'] as String;

    return ToolPageScaffold(
      title: 'Matrix Inversion Calculator',
      description: 'Computes determinant and matrix inverse A⁻¹',
      formula: 'A⁻¹ = (1 / det(A)) * adj(A)',
      onReset: _reset,
      onSave: () => _logHistory('Inverse [[$a, $b], [$c, $d]]', 'det=$det'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: isInvertible ? 'det = ${det.toStringAsFixed(2)}' : 'Non-Invertible (det = 0)',
          details: isInvertible
              ? 'Determinant: ${det.toStringAsFixed(3)}\nInverse A⁻¹:\n$matStr'
              : 'Determinant: 0.000\n$matStr',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'a₁₁',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'a₁₂',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'a₂₁',
            initialValue: _c,
            onChanged: (val) => setState(() => _c = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'a₂₂',
            initialValue: _d,
            onChanged: (val) => setState(() => _d = val),
          ),
      ],
    );
  }
}
