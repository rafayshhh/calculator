import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class ParabolaGeometryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ParabolaGeometryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ParabolaGeometryScreen> createState() => _ParabolaGeometryScreenState();
}

class _ParabolaGeometryScreenState extends ConsumerState<ParabolaGeometryScreen> {
  String _a = '1.0';
  String _b = '-4.0';
  String _c = '3.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '1.0';
        _b = map['b']?.toString() ?? '-4.0';
        _c = map['c']?.toString() ?? '3.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '1.0';
      _b = '-4.0';
      _c = '3.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b, 'c': _c});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/parabola_geometry',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = double.tryParse(_a) ?? 1.0;
    final b = double.tryParse(_b) ?? 0.0;
    final c = double.tryParse(_c) ?? 0.0;
    final res = Geometry3DEngine.parabola(a, b, c);
    final vStr = res['vertex'] as String? ?? 'N/A';
    final fStr = res['focus'] as String? ?? 'N/A';
    final dStr = res['directrix'] as String? ?? 'N/A';
    final axis = res['axisOfSymmetry'] as String? ?? 'N/A';

    return ToolPageScaffold(
      title: 'Parabola Conic Properties',
      description: 'Vertex, focus, directrix equation, and axis of symmetry',
      formula: 'y = ax² + bx + c,  Vertex = (-b/2a, c - b²/4a),  Focus = (h, k + 1/4a)',
      onReset: _reset,
      onSave: () => _logHistory('Parabola $a x² + $b x + $c', 'Vertex $vStr'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Vertex: $vStr',
          details: 'Focus: $fStr\nDirectrix: $dStr\nAxis of Symmetry: $axis\nOrientation: ${res['direction']}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Coefficient a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Coefficient b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Constant c',
            initialValue: _c,
            onChanged: (val) => setState(() => _c = val),
          ),
      ],
    );
  }
}
