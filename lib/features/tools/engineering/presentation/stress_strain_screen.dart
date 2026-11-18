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
import '../domain/engineering_engine.dart';

class StressStrainScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const StressStrainScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<StressStrainScreen> createState() => _StressStrainScreenState();
}

class _StressStrainScreenState extends ConsumerState<StressStrainScreen> {
  String _force = '50000.0';
  String _area = '0.002';
  String _deltaL = '0.005';
  String _origL = '2.0';

  double? _stress;
  double? _strain;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _force = data['force']?.toString() ?? '50000.0';
        _area = data['area']?.toString() ?? '0.002';
        _deltaL = data['deltaL']?.toString() ?? '0.005';
        _origL = data['origL']?.toString() ?? '2.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final f = double.tryParse(_force);
    final a = double.tryParse(_area);
    final dl = double.tryParse(_deltaL);
    final l = double.tryParse(_origL);

    if (f == null || a == null || dl == null || l == null || a <= 0 || l <= 0) {
      setState(() {
        _stress = null;
        _strain = null;
        _error = 'Please enter positive area and original length';
      });
      return;
    }

    try {
      final s = EngineeringEngine.calculateStress(f, a);
      final e = EngineeringEngine.calculateStrain(dl, l);
      setState(() {
        _error = null;
        _stress = s;
        _strain = e;
      });

      final stateJson = jsonEncode({'force': _force, 'area': _area, 'deltaL': _deltaL, 'origL': _origL});
      ref.read(historyProvider.notifier).add(
        'Stress/Strain: ${(s / 1e6).toStringAsFixed(2)} MPa, strain=$e',
        '${(s / 1e6).toStringAsFixed(2)} MPa',
        toolRoute: '/tools/engineering/stress_strain',
        toolStateJson: stateJson,
      );
    } catch (err) {
      setState(() {
        _stress = null;
        _strain = null;
        _error = err.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _force = '50000.0';
      _area = '0.002';
      _deltaL = '0.005';
      _origL = '2.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final mpa = _stress != null ? _stress! / 1e6 : 0.0;

    return ToolPageScaffold(
      toolId: 'stress_strain',
      title: 'Stress & Strain Calculator',
      description: 'Compute normal stress (σ = F/A) and engineering strain (ε = ΔL/L).',
      icon: Icons.square_foot_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'σ = F / A  |  ε = ΔL / L',
          description: 'Mechanical stress and normalized elongation strain.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Axial Load (F)',
          suffix: 'N',
          value: _force,
          onChanged: (v) {
            _force = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Cross-Section Area (A)',
          suffix: 'm²',
          value: _area,
          onChanged: (v) {
            _area = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Elongation / Deflection (ΔL)',
          suffix: 'm',
          value: _deltaL,
          onChanged: (v) {
            _deltaL = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Original Gauge Length (L)',
          suffix: 'm',
          value: _origL,
          onChanged: (v) {
            _origL = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_stress != null && _strain != null) ...[
          ResultDisplayCard(
            label: 'Normal Stress (σ)',
            value: '${mpa.toStringAsFixed(2)} MPa',
            secondaryLabel: 'Engineering Strain (ε)',
            secondaryValue: '${(_strain! * 100).toStringAsFixed(3)}%',
            formula: 'σ = F / A | ε = ΔL / L',
            substitution: 'σ = ${_stress!.toStringAsFixed(0)} Pa | ε = ${_strain!.toStringAsFixed(4)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
