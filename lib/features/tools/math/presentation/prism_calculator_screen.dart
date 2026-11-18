import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class PrismCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PrismCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PrismCalculatorScreen> createState() => _PrismCalculatorScreenState();
}

class _PrismCalculatorScreenState extends ConsumerState<PrismCalculatorScreen> {
  String _l = '5.0';
  String _w = '4.0';
  String _h = '3.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _l = map['l']?.toString() ?? '5.0';
        _w = map['w']?.toString() ?? '4.0';
        _h = map['h']?.toString() ?? '3.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _l = '5.0';
      _w = '4.0';
      _h = '3.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'l': _l, 'w': _w, 'h': _h});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/prism_calculator',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final l = double.tryParse(_l) ?? 0.0;
    final w = double.tryParse(_w) ?? 0.0;
    final h = double.tryParse(_h) ?? 0.0;
    final res = Geometry3DEngine.prism(l, w, h);
    final vol = res['volume'] as double;
    final sa = res['surfaceArea'] as double;
    final diag = res['spaceDiagonal'] as double;

    return ToolPageScaffold(
      title: 'Rectangular Prism & Space Diagonal',
      description: 'Computes 3D cuboid volume, surface area, and space diagonal',
      formula: 'V = L * W * H,  A = 2(LW + LH + WH),  d = √(L² + W² + H²)',
      onReset: _reset,
      onSave: () => _logHistory('Prism $l x $w x $h', 'V=${vol.toStringAsFixed(2)}, d=${diag.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Volume = ${vol.toStringAsFixed(3)}',
          details: 'Total Surface Area: ${sa.toStringAsFixed(3)}\nSpace Diagonal: ${diag.toStringAsFixed(3)}\nFace Area (L×W): ${(l * w).toStringAsFixed(2)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Length L',
            initialValue: _l,
            onChanged: (val) => setState(() => _l = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Width W',
            initialValue: _w,
            onChanged: (val) => setState(() => _w = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Height H',
            initialValue: _h,
            onChanged: (val) => setState(() => _h = val),
          ),
      ],
    );
  }
}
