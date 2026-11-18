import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class ConeCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ConeCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ConeCalculatorScreen> createState() => _ConeCalculatorScreenState();
}

class _ConeCalculatorScreenState extends ConsumerState<ConeCalculatorScreen> {
  String _r = '3.0';
  String _h = '4.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _r = map['r']?.toString() ?? '3.0';
        _h = map['h']?.toString() ?? '4.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _r = '3.0';
      _h = '4.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'r': _r, 'h': _h});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/cone_calculator',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final r = double.tryParse(_r) ?? 0.0;
    final h = double.tryParse(_h) ?? 0.0;
    final res = Geometry3DEngine.cone(r, h);
    final vol = res['volume'] as double;
    final s = res['slantHeight'] as double;
    final totArea = res['totalArea'] as double;
    final latArea = res['lateralArea'] as double;

    return ToolPageScaffold(
      title: 'Cone Slant, Surface & Volume',
      description: 'Right circular cone slant height, lateral area, and volume',
      formula: 's = √(r² + h²),  V = (1/3)πr²h,  A_lat = πrs',
      onReset: _reset,
      onSave: () => _logHistory('Cone r=$r, h=$h', 'V=${vol.toStringAsFixed(2)}, s=${s.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Volume = ${vol.toStringAsFixed(3)}',
          details: 'Slant Height s: ${s.toStringAsFixed(3)}\nTotal Surface: ${totArea.toStringAsFixed(3)}\nLateral Area: ${latArea.toStringAsFixed(3)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Radius r',
            initialValue: _r,
            onChanged: (val) => setState(() => _r = val),
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
