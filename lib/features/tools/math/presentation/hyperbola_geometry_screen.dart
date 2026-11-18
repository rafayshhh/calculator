import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class HyperbolaGeometryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const HyperbolaGeometryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<HyperbolaGeometryScreen> createState() => _HyperbolaGeometryScreenState();
}

class _HyperbolaGeometryScreenState extends ConsumerState<HyperbolaGeometryScreen> {
  String _a = '4.0';
  String _b = '3.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '4.0';
        _b = map['b']?.toString() ?? '3.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '4.0';
      _b = '3.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/hyperbola_geometry',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = double.tryParse(_a) ?? 0.0;
    final b = double.tryParse(_b) ?? 0.0;
    final res = Geometry3DEngine.hyperbola(a, b);
    final c = res['focalDistance'] as double;
    final e = res['eccentricity'] as double;
    final asymp = res['asymptotes'] as String;

    return ToolPageScaffold(
      title: 'Hyperbola Foci & Asymptotes',
      description: 'Focal distance, eccentricity, and linear asymptotes of hyperbola',
      formula: 'x²/a² - y²/b² = 1,  c = √(a² + b²),  y = ±(b/a)x',
      onReset: _reset,
      onSave: () => _logHistory('Hyperbola a=$a, b=$b', 'c=${c.toStringAsFixed(2)}, e=${e.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Foci c = ${c.toStringAsFixed(3)}',
          details: 'Eccentricity e: ${e.toStringAsFixed(4)}\nAsymptotes: $asymp\nFoci Points: ${res['foci']}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Semi-transverse Axis a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Semi-conjugate Axis b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
      ],
    );
  }
}
