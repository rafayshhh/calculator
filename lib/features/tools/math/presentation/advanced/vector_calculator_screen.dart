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

class VectorCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const VectorCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<VectorCalculatorScreen> createState() => _VectorCalculatorScreenState();
}

class _VectorCalculatorScreenState extends ConsumerState<VectorCalculatorScreen> {
  String _x1 = '1.0';
  String _y1 = '2.0';
  String _z1 = '3.0';
  String _x2 = '4.0';
  String _y2 = '5.0';
  String _z2 = '6.0';

  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final x1 = double.tryParse(_x1);
    final y1 = double.tryParse(_y1);
    final z1 = double.tryParse(_z1);
    final x2 = double.tryParse(_x2);
    final y2 = double.tryParse(_y2);
    final z2 = double.tryParse(_z2);

    if (x1 == null || y1 == null || z1 == null || x2 == null || y2 == null || z2 == null) {
      setState(() {
        _result = null;
        _error = 'Please enter valid 3D vector coordinates';
      });
      return;
    }

    try {
      final res = AdvancedMathEngine.calculateVectors3D(v1: [x1, y1, z1], v2: [x2, y2, z2]);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'x1': _x1, 'y1': _y1, 'z1': _z1, 'x2': _x2, 'y2': _y2, 'z2': _z2});
      ref.read(historyProvider.notifier).add(
        'Vectors: <$_x1, $_y1, $_z1> · <$_x2, $_y2, $_z2>',
        'Dot=${(res['dotProduct'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/math/advanced/vector',
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
      _x1 = '1.0';
      _y1 = '2.0';
      _z1 = '3.0';
      _x2 = '4.0';
      _y2 = '5.0';
      _z2 = '6.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'vector_calculator',
      title: '3D Vector Calculator',
      description: 'Compute vector dot product, cross product, magnitude, and angle between 3D vectors.',
      icon: Icons.navigation_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text('Vector u (x, y, z)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: KSpacing.xs),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'u_x', value: _x1, onChanged: (v) { _x1 = v; _calculate(); })),
            const SizedBox(width: KSpacing.sm),
            Expanded(child: PremiumNumericField(label: 'u_y', value: _y1, onChanged: (v) { _y1 = v; _calculate(); })),
            const SizedBox(width: KSpacing.sm),
            Expanded(child: PremiumNumericField(label: 'u_z', value: _z1, onChanged: (v) { _z1 = v; _calculate(); })),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        const Text('Vector v (x, y, z)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: KSpacing.xs),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'v_x', value: _x2, onChanged: (v) { _x2 = v; _calculate(); })),
            const SizedBox(width: KSpacing.sm),
            Expanded(child: PremiumNumericField(label: 'v_y', value: _y2, onChanged: (v) { _y2 = v; _calculate(); })),
            const SizedBox(width: KSpacing.sm),
            Expanded(child: PremiumNumericField(label: 'v_z', value: _z2, onChanged: (v) { _z2 = v; _calculate(); })),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Dot Product (u · v)',
            value: (_result!['dotProduct'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Angle (θ)',
            secondaryValue: '${(_result!['angleDegrees'] as double).toStringAsFixed(2)}°',
            formula: 'u · v = |u||v| cos(θ)',
            substitution: 'Angle between vectors = ${(_result!['angleDegrees'] as double).toStringAsFixed(2)}°',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(
            label: 'Cross Product (u × v)',
            value: '<${(_result!['crossProduct'] as List<double>).map((e) => e.toStringAsFixed(2)).join(', ')}>',
          ),
        ],
      ],
    );
  }
}
