import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/k_stat_row.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/advanced_math_engine.dart';

class MatrixCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MatrixCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MatrixCalculatorScreen> createState() => _MatrixCalculatorScreenState();
}

class _MatrixCalculatorScreenState extends ConsumerState<MatrixCalculatorScreen> {
  // 2x2 Matrix: [[a, b], [c, d]]
  String _m00 = '4';
  String _m01 = '7';
  String _m10 = '2';
  String _m11 = '6';

  double? _det;
  String? _trace;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = double.tryParse(_m00);
    final b = double.tryParse(_m01);
    final c = double.tryParse(_m10);
    final d = double.tryParse(_m11);
    if (a == null || b == null || c == null || d == null) {
      setState(() {
        _det = null;
        _error = 'Please enter valid matrix elements';
      });
      return;
    }

    final detVal = AdvancedMathEngine.determinant2x2(a, b, c, d);
    final tr = a + d;

    setState(() {
      _error = null;
      _det = detVal;
      _trace = tr.toString();
    });

    final stateJson = jsonEncode({'m00': _m00, 'm01': _m01, 'm10': _m10, 'm11': _m11});
    ref.read(historyProvider.notifier).add(
      'Matrix 2x2: [[$_m00, $_m01], [$_m10, $_m11]]',
      'det=$detVal',
      toolRoute: '/tools/math/advanced/matrix',
      toolStateJson: stateJson,
    );
  }

  void _reset() {
    setState(() {
      _m00 = '4';
      _m01 = '7';
      _m10 = '2';
      _m11 = '6';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'matrix_calculator',
      title: 'Matrix Calculator',
      description: 'Compute matrix determinant (det A), trace, and inversion properties.',
      icon: Icons.grid_4x4_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text('2×2 Matrix Elements', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: KSpacing.sm),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'a₁₁', value: _m00, onChanged: (v) { _m00 = v; _calculate(); })),
            const SizedBox(width: KSpacing.md),
            Expanded(child: PremiumNumericField(label: 'a₁₂', value: _m01, onChanged: (v) { _m01 = v; _calculate(); })),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'a₂₁', value: _m10, onChanged: (v) { _m10 = v; _calculate(); })),
            const SizedBox(width: KSpacing.md),
            Expanded(child: PremiumNumericField(label: 'a₂₂', value: _m11, onChanged: (v) { _m11 = v; _calculate(); })),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_det != null) ...[
          ResultDisplayCard(
            label: 'Determinant (det A)',
            value: '${_det!.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), '')}',
            secondaryLabel: 'Trace (tr A)',
            secondaryValue: _trace ?? '',
            formula: 'det A = a₁₁a₂₂ - a₁₂a₂₁',
            substitution: '($_m00 × $_m11) - ($_m01 × $_m10) = $_det',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Invertible Matrix', value: _det != 0 ? 'Yes (det ≠ 0)' : 'No (Singular)'),
        ],
      ],
    );
  }
}
