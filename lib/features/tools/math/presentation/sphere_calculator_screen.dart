import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/geometry_3d_engine.dart';

class SphereCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SphereCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SphereCalculatorScreen> createState() => _SphereCalculatorScreenState();
}

class _SphereCalculatorScreenState extends ConsumerState<SphereCalculatorScreen> {
  String _r = '4.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _r = map['r']?.toString() ?? '4.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _r = '4.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'r': _r});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/sphere_calculator',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final r = double.tryParse(_r) ?? 0.0;
    final res = Geometry3DEngine.sphere(r);
    final vol = res['volume'] as double;
    final sa = res['surfaceArea'] as double;
    final hVol = res['hemisphereVolume'] as double;
    final hArea = res['hemisphereSurfaceArea'] as double;

    return ToolPageScaffold(
      title: 'Sphere & Hemisphere 3D',
      description: 'Computes total surface area and volume of spheres and hemispheres',
      formula: 'V = (4/3)πr³,  A = 4πr²,  V_hemi = (2/3)πr³',
      onReset: _reset,
      onSave: () => _logHistory('Sphere r=$r', 'V=${vol.toStringAsFixed(2)}, A=${sa.toStringAsFixed(2)}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Volume = ${vol.toStringAsFixed(3)}',
          details: 'Surface Area: ${sa.toStringAsFixed(3)}\nHemisphere Volume: ${hVol.toStringAsFixed(3)}\nHemisphere Total Area: ${hArea.toStringAsFixed(3)}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Radius r',
            initialValue: _r,
            onChanged: (val) => setState(() => _r = val),
          ),
      ],
    );
  }
}
