import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class PyramidCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PyramidCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PyramidCalculatorScreen> createState() => _PyramidCalculatorScreenState();
}

class _PyramidCalculatorScreenState extends ConsumerState<PyramidCalculatorScreen> {
  String _l = '6.0';
  String _w = '6.0';
  String _h = '9.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _l = map['l']?.toString() ?? '6.0';
        _w = map['w']?.toString() ?? '6.0';
        _h = map['h']?.toString() ?? '9.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _l = '6.0';
      _w = '6.0';
      _h = '9.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'l': _l, 'w': _w, 'h': _h});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/pyramid_calculator',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final l = double.tryParse(_l) ?? 0.0;
    final w = double.tryParse(_w) ?? 0.0;
    final h = double.tryParse(_h) ?? 0.0;
    final res = Geometry3DEngine.pyramid(l, w, h);
    final vol = res['volume'] as double;
    final totArea = res['totalArea'] as double;
    final baseArea = res['baseArea'] as double;

    return ToolPageScaffold(
      title: 'Pyramid Surface & Volume',
      description: 'Rectangular pyramid base area, slant faces, and volume',
      formula: 'V = (1/3) * L * W * h,  A = LW + L*s_w + W*s_l',
      onReset: _reset,
      onSave: () => _logHistory('Pyramid L=$l, W=$w, h=$h', 'V=${vol.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Volume = ${vol.toStringAsFixed(3)}',
          details: 'Base Area: ${baseArea.toStringAsFixed(2)}\nLateral Surface: ${(res['lateralArea'] as double).toStringAsFixed(3)}\nTotal Surface Area: ${totArea.toStringAsFixed(3)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Base Length L',
            initialValue: _l,
            onChanged: (val) => setState(() => _l = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Base Width W',
            initialValue: _w,
            onChanged: (val) => setState(() => _w = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Height h',
            initialValue: _h,
            onChanged: (val) => setState(() => _h = val),
          ),
      ],
    );
  }
}
