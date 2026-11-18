import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class RegularPolygonScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RegularPolygonScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RegularPolygonScreen> createState() => _RegularPolygonScreenState();
}

class _RegularPolygonScreenState extends ConsumerState<RegularPolygonScreen> {
  String _n = '6';
  String _s = '4.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _n = map['n']?.toString() ?? '6';
        _s = map['s']?.toString() ?? '4.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _n = '6';
      _s = '4.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'n': _n, 's': _s});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/regular_polygon',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final n = int.tryParse(_n) ?? 3;
    final s = double.tryParse(_s) ?? 0.0;
    final res = Geometry3DEngine.regularPolygon(n, s);
    final area = res['area'] as double? ?? 0.0;
    final p = res['perimeter'] as double? ?? 0.0;
    final ap = res['apothem'] as double? ?? 0.0;
    final intAngle = res['interiorAngleDeg'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Regular Polygon Calculator',
      description: 'Calculates interior angles, apothem, perimeter, and area of regular n-gon',
      formula: 'Area = (n * s * a) / 2,  a = s / [2 tan(π/n)],  Angle = (n-2)*180°/n',
      onReset: _reset,
      onSave: () => _logHistory('$n-gon side=$s', 'Area=${area.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Area = ${area.toStringAsFixed(3)}',
          details: 'Perimeter: ${p.toStringAsFixed(2)}\nApothem: ${ap.toStringAsFixed(3)}\nInterior Angle: ${intAngle.toStringAsFixed(1)}°\nExterior Angle: ${(360.0 / n).toStringAsFixed(1)}°',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Number of Sides n',
            initialValue: _n,
            onChanged: (val) => setState(() => _n = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Side Length s',
            initialValue: _s,
            onChanged: (val) => setState(() => _s = val),
          ),
      ],
    );
  }
}
