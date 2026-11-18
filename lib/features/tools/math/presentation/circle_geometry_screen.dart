import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class CircleGeometryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CircleGeometryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CircleGeometryScreen> createState() => _CircleGeometryScreenState();
}

class _CircleGeometryScreenState extends ConsumerState<CircleGeometryScreen> {
  String _radius = '5.0';
  String _angle = '60.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _radius = map['radius']?.toString() ?? '5.0';
        _angle = map['angle']?.toString() ?? '60.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _radius = '5.0';
      _angle = '60.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'radius': _radius, 'angle': _angle});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/circle_geometry',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final radius = double.tryParse(_radius) ?? 0.0;
    final angle = double.tryParse(_angle) ?? 360.0;
    final res = Geometry3DEngine.circleMetrics(radius, angleDeg: angle);
    final area = res['area'] as double;
    final circ = res['circumference'] as double;
    final arc = res['arcLength'] as double;
    final sector = res['sectorArea'] as double;

    return ToolPageScaffold(
      title: 'Circle & Sector Geometry',
      description: 'Calculates radius, diameter, area, circumference, arc length, and sector',
      formula: 'A = πr²,  C = 2πr,  Arc = 2πr(θ/360°),  Sector = πr²(θ/360°)',
      onReset: _reset,
      onSave: () => _logHistory('Circle r=$radius, θ=$angle°', 'A=${area.toStringAsFixed(2)}, C=${circ.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Area = ${area.toStringAsFixed(3)}',
          details: 'Circumference: ${circ.toStringAsFixed(3)}\nDiameter: ${(radius * 2).toStringAsFixed(2)}\nArc Length: ${arc.toStringAsFixed(3)}\nSector Area: ${sector.toStringAsFixed(3)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Radius r',
            initialValue: _radius,
            onChanged: (val) => setState(() => _radius = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Angle θ (Degrees)',
            initialValue: _angle,
            onChanged: (val) => setState(() => _angle = val),
          ),
      ],
    );
  }
}
