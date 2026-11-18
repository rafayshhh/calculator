import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/linear_algebra_engine.dart';

class VectorProjectionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const VectorProjectionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<VectorProjectionScreen> createState() => _VectorProjectionScreenState();
}

class _VectorProjectionScreenState extends ConsumerState<VectorProjectionScreen> {
  String _ux = '3.0';
  String _uy = '4.0';
  String _vx = '1.0';
  String _vy = '2.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _ux = map['ux']?.toString() ?? '3.0';
        _uy = map['uy']?.toString() ?? '4.0';
        _vx = map['vx']?.toString() ?? '1.0';
        _vy = map['vy']?.toString() ?? '2.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _ux = '3.0';
      _uy = '4.0';
      _vx = '1.0';
      _vy = '2.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'ux': _ux, 'uy': _uy, 'vx': _vx, 'vy': _vy});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/vector_projection',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final ux = double.tryParse(_ux) ?? 0.0;
    final uy = double.tryParse(_uy) ?? 0.0;
    final vx = double.tryParse(_vx) ?? 0.0;
    final vy = double.tryParse(_vy) ?? 0.0;
    final res = LinearAlgebraEngine.vectorProjection(u: [ux, uy], v: [vx, vy]);
    final scalarProj = res['scalarProjection'] as double? ?? 0.0;
    final angleDeg = res['angleDegrees'] as double? ?? 0.0;
    final proj = res['projectionVector'] as List<double>? ?? [0.0, 0.0];

    return ToolPageScaffold(
      title: 'Vector Projection & Angle',
      description: 'Computes scalar projection, vector projection of v onto u, and angle θ',
      formula: 'proj_u(v) = [(u · v) / ||u||²] * u,  cos(θ) = (u · v) / (||u|| ||v||)',
      onReset: _reset,
      onSave: () => _logHistory('proj_u(v) for u=[$ux, $uy], v=[$vx, $vy]', 'scalar=$scalarProj, θ=$angleDeg°'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'proj_u(v) = (${proj[0].toStringAsFixed(3)}, ${proj[1].toStringAsFixed(3)})',
          details: 'Scalar Projection: ${scalarProj.toStringAsFixed(4)}\nAngle θ: ${angleDeg.toStringAsFixed(2)}°\nDot Product: ${(res['dotProduct'] as double? ?? 0.0).toStringAsFixed(2)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Vector u_x',
            initialValue: _ux,
            onChanged: (val) => setState(() => _ux = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Vector u_y',
            initialValue: _uy,
            onChanged: (val) => setState(() => _uy = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Vector v_x',
            initialValue: _vx,
            onChanged: (val) => setState(() => _vx = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Vector v_y',
            initialValue: _vy,
            onChanged: (val) => setState(() => _vy = val),
          ),
      ],
    );
  }
}
