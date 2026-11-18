import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/physics_engine.dart';

class PressureScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PressureScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PressureScreen> createState() => _PressureScreenState();
}

class _PressureScreenState extends ConsumerState<PressureScreen> {
  String _force = '1000.0';
  String _area = '0.05';
  double? _pressure;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _force = data['force']?.toString() ?? '1000.0';
        _area = data['area']?.toString() ?? '0.05';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final f = double.tryParse(_force);
    final a = double.tryParse(_area);
    if (f == null || a == null) {
      setState(() {
        _pressure = null;
        _error = 'Please enter valid force and cross-sectional area';
      });
      return;
    }

    try {
      final p = PhysicsEngine.calculatePressure(f, a);
      setState(() {
        _error = null;
        _pressure = p;
      });

      final stateJson = jsonEncode({'force': _force, 'area': _area});
      ref.read(historyProvider.notifier).add(
        'Pressure: $_force N / $_area m²',
        '${p.toStringAsFixed(1)} Pa',
        toolRoute: '/tools/physics/pressure',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _pressure = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _force = '1000.0';
      _area = '0.05';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'pressure',
      title: 'Pressure Calculator',
      description: 'Compute hydrostatic and mechanical pressure (P = F / A) in Pascals and atmospheres.',
      icon: Icons.compress_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'P = F / A',
          description: 'Pressure equals perpendicular force divided by surface area.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Perpendicular Force (F)',
          suffix: 'N',
          value: _force,
          onChanged: (v) {
            _force = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Surface Area (A)',
          suffix: 'm²',
          value: _area,
          onChanged: (v) {
            _area = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_pressure != null) ...[
          ResultDisplayCard(
            label: 'Pressure (P)',
            value: '${_pressure!.toStringAsFixed(1)} Pa',
            secondaryLabel: 'kiloPascals (kPa)',
            secondaryValue: '${(_pressure! / 1000.0).toStringAsFixed(2)} kPa',
            formula: 'P = F / A',
            substitution: 'P = $_force N / $_area m² = ${_pressure!.toStringAsFixed(1)} Pa',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
