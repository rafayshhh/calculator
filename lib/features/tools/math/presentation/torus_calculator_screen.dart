import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class TorusCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TorusCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TorusCalculatorScreen> createState() => _TorusCalculatorScreenState();
}

class _TorusCalculatorScreenState extends ConsumerState<TorusCalculatorScreen> {
  String _majorR = '6.0';
  String _minorR = '2.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _majorR = map['majorR']?.toString() ?? '6.0';
        _minorR = map['minorR']?.toString() ?? '2.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _majorR = '6.0';
      _minorR = '2.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'majorR': _majorR, 'minorR': _minorR});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/torus_calculator',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final majorR = double.tryParse(_majorR) ?? 0.0;
    final minorR = double.tryParse(_minorR) ?? 0.0;
    final res = Geometry3DEngine.torus(majorR, minorR);
    final vol = res['volume'] as double? ?? 0.0;
    final sa = res['surfaceArea'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Torus Surface Area & Volume',
      description: 'Ring torus 3D geometric properties',
      formula: 'V = 2π²Rr²,  A = 4π²Rr',
      onReset: _reset,
      onSave: () => _logHistory('Torus R=$majorR, r=$minorR', 'V=${vol.toStringAsFixed(2)}, A=${sa.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Volume = ${vol.toStringAsFixed(3)}',
          details: 'Total Surface Area: ${sa.toStringAsFixed(3)}\nTube Radius r: $minorR\nRing Radius R: $majorR',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Major Radius R (Center to tube)',
            initialValue: _majorR,
            onChanged: (val) => setState(() => _majorR = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Minor Radius r (Tube radius)',
            initialValue: _minorR,
            onChanged: (val) => setState(() => _minorR = val),
          ),
      ],
    );
  }
}
