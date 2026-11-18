import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class TriangleSolverScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TriangleSolverScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TriangleSolverScreen> createState() => _TriangleSolverScreenState();
}

class _TriangleSolverScreenState extends ConsumerState<TriangleSolverScreen> {
  String _a = '5.0';
  String _b = '6.0';
  String _c = '7.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '5.0';
        _b = map['b']?.toString() ?? '6.0';
        _c = map['c']?.toString() ?? '7.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '5.0';
      _b = '6.0';
      _c = '7.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b, 'c': _c});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/triangle_solver',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = double.tryParse(_a) ?? 0.0;
    final b = double.tryParse(_b) ?? 0.0;
    final c = double.tryParse(_c) ?? 0.0;
    final res = Geometry3DEngine.solveTriangleSSS(a, b, c);
    final isValid = res['isValid'] as bool? ?? false;
    final area = res['area'] as double? ?? 0.0;
    final p = res['perimeter'] as double? ?? 0.0;
    final aA = res['angleA'] as double? ?? 0.0;
    final aB = res['angleB'] as double? ?? 0.0;
    final aC = res['angleC'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Triangle Solver (SSS & Angles)',
      description: 'Computes angles, area, perimeter, inradius, and circumradius for triangle',
      formula: 'Area = √[s(s-a)(s-b)(s-c)],  cos(A) = (b²+c²-a²)/(2bc)',
      onReset: _reset,
      onSave: () => _logHistory('Triangle a=$a, b=$b, c=$c', 'Area=${area.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Area = ${area.toStringAsFixed(3)}',
          details: 'Angles: A=${aA.toStringAsFixed(1)}°, B=${aB.toStringAsFixed(1)}°, C=${aC.toStringAsFixed(1)}°\nPerimeter: ${p.toStringAsFixed(2)}\nInradius: ${(res['inradius'] as double? ?? 0.0).toStringAsFixed(2)}\nCircumradius: ${(res['circumradius'] as double? ?? 0.0).toStringAsFixed(2)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Side a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Side b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Side c',
            initialValue: _c,
            onChanged: (val) => setState(() => _c = val),
          ),
      ],
    );
  }
}
