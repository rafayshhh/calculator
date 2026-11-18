import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/linear_algebra_engine.dart';

class CrossDotProductScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CrossDotProductScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CrossDotProductScreen> createState() => _CrossDotProductScreenState();
}

class _CrossDotProductScreenState extends ConsumerState<CrossDotProductScreen> {
  String _ux = '1.0';
  String _uy = '2.0';
  String _uz = '3.0';
  String _vx = '4.0';
  String _vy = '5.0';
  String _vz = '6.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _ux = map['ux']?.toString() ?? '1.0';
        _uy = map['uy']?.toString() ?? '2.0';
        _uz = map['uz']?.toString() ?? '3.0';
        _vx = map['vx']?.toString() ?? '4.0';
        _vy = map['vy']?.toString() ?? '5.0';
        _vz = map['vz']?.toString() ?? '6.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _ux = '1.0';
      _uy = '2.0';
      _uz = '3.0';
      _vx = '4.0';
      _vy = '5.0';
      _vz = '6.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'ux': _ux, 'uy': _uy, 'uz': _uz, 'vx': _vx, 'vy': _vy, 'vz': _vz});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/cross_dot_product',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final ux = double.tryParse(_ux) ?? 0.0;
    final uy = double.tryParse(_uy) ?? 0.0;
    final uz = double.tryParse(_uz) ?? 0.0;
    final vx = double.tryParse(_vx) ?? 0.0;
    final vy = double.tryParse(_vy) ?? 0.0;
    final vz = double.tryParse(_vz) ?? 0.0;
    final res = LinearAlgebraEngine.crossAndDotProduct([ux, uy, uz], [vx, vy, vz]);
    final dot = res['dotProduct'] as double;
    final cp = res['crossProduct'] as List<double>;
    final crossMag = res['crossMagnitude'] as double;
    final angle = res['angleDegrees'] as double;

    return ToolPageScaffold(
      title: 'Cross & Dot Product (3D)',
      description: 'Computes 3D dot product, cross product vector, and parallelogram area',
      formula: 'u · v = ||u||||v||cos(θ),  u × v = det([i, j, k; ux, uy, uz; vx, vy, vz])',
      onReset: _reset,
      onSave: () => _logHistory('3D Vector Products', 'dot=$dot, crossMag=$crossMag'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'u × v = (${cp[0].toStringAsFixed(1)}, ${cp[1].toStringAsFixed(1)}, ${cp[2].toStringAsFixed(1)})',
          details: 'Dot Product: ${dot.toStringAsFixed(3)}\nCross Product Magnitude: ${crossMag.toStringAsFixed(4)}\nAngle Between Vectors: ${angle.toStringAsFixed(2)}°\nParallelogram Area: ${crossMag.toStringAsFixed(4)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'u_x',
            initialValue: _ux,
            onChanged: (val) => setState(() => _ux = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'u_y',
            initialValue: _uy,
            onChanged: (val) => setState(() => _uy = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'u_z',
            initialValue: _uz,
            onChanged: (val) => setState(() => _uz = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'v_x',
            initialValue: _vx,
            onChanged: (val) => setState(() => _vx = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'v_y',
            initialValue: _vy,
            onChanged: (val) => setState(() => _vy = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'v_z',
            initialValue: _vz,
            onChanged: (val) => setState(() => _vz = val),
          ),
      ],
    );
  }
}
