import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class EllipseGeometryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const EllipseGeometryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<EllipseGeometryScreen> createState() => _EllipseGeometryScreenState();
}

class _EllipseGeometryScreenState extends ConsumerState<EllipseGeometryScreen> {
  String _a = '6.0';
  String _b = '4.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '6.0';
        _b = map['b']?.toString() ?? '4.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '6.0';
      _b = '4.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/ellipse_geometry',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = double.tryParse(_a) ?? 0.0;
    final b = double.tryParse(_b) ?? 0.0;
    final res = Geometry3DEngine.ellipse(a, b);
    final area = res['area'] as double;
    final perim = res['perimeter'] as double;
    final c = res['focalDistance'] as double;
    final e = res['eccentricity'] as double;

    return ToolPageScaffold(
      title: 'Ellipse Area, Perimeter & Foci',
      description: 'Calculates area, Ramanujan perimeter, foci, and eccentricity',
      formula: 'A = πab,  c = √(a² - b²),  e = c / a',
      onReset: _reset,
      onSave: () => _logHistory('Ellipse a=$a, b=$b', 'A=${area.toStringAsFixed(2)}, P=${perim.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Area = ${area.toStringAsFixed(3)}',
          details: 'Perimeter (Ramanujan): ${perim.toStringAsFixed(3)}\nFocal Distance c: ${c.toStringAsFixed(3)}\nEccentricity e: ${e.toStringAsFixed(4)}\nFoci: ${res['foci']}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Semi-major Axis a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Semi-minor Axis b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
      ],
    );
  }
}
