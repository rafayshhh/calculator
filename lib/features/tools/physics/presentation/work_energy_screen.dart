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

class WorkEnergyScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const WorkEnergyScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<WorkEnergyScreen> createState() => _WorkEnergyScreenState();
}

class _WorkEnergyScreenState extends ConsumerState<WorkEnergyScreen> {
  String _force = '50.0';
  String _distance = '10.0';
  String _angle = '0.0';
  double? _work;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _force = data['force']?.toString() ?? '50.0';
        _distance = data['distance']?.toString() ?? '10.0';
        _angle = data['angle']?.toString() ?? '0.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final f = double.tryParse(_force);
    final d = double.tryParse(_distance);
    final a = double.tryParse(_angle);
    if (f == null || d == null || a == null) {
      setState(() {
        _work = null;
        _error = 'Please enter valid numbers for force, distance, and angle';
      });
      return;
    }

    try {
      final w = PhysicsEngine.calculateWork(f, d, angleDegrees: a);
      setState(() {
        _error = null;
        _work = w;
      });

      final stateJson = jsonEncode({'force': _force, 'distance': _distance, 'angle': _angle});
      ref.read(historyProvider.notifier).add(
        'Work: $_force N × $_distance m @ $_angle°',
        '${w.toStringAsFixed(2)} J',
        toolRoute: '/tools/physics/work_energy',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _work = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _force = '50.0';
      _distance = '10.0';
      _angle = '0.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'work_energy',
      title: 'Work & Energy Calculator',
      description: 'Compute mechanical work done (W = F · d · cos θ) in Joules.',
      icon: Icons.bolt_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'W = F × d × cos(θ)',
          description: 'Mechanical work done by a force over displacement at angle θ.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Applied Force (F)',
          suffix: 'N',
          value: _force,
          onChanged: (v) {
            _force = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Displacement (d)',
          suffix: 'm',
          value: _distance,
          onChanged: (v) {
            _distance = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Force Angle (θ)',
          suffix: '°',
          value: _angle,
          onChanged: (v) {
            _angle = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_work != null) ...[
          ResultDisplayCard(
            label: 'Mechanical Work (W)',
            value: '${_work!.toStringAsFixed(2)} J',
            secondaryLabel: 'kiloJoules',
            secondaryValue: '${(_work! / 1000.0).toStringAsFixed(3)} kJ',
            formula: 'W = F × d × cos(θ)',
            substitution: 'W = $_force N × $_distance m × cos($_angle°) = ${_work!.toStringAsFixed(2)} J',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
