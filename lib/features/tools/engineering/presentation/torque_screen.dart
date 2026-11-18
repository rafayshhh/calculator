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

class TorqueScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TorqueScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TorqueScreen> createState() => _TorqueScreenState();
}

class _TorqueScreenState extends ConsumerState<TorqueScreen> {
  String _force = '100.0';
  String _radius = '0.5';
  String _angle = '90.0';
  double? _torque;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _force = data['force']?.toString() ?? '100.0';
        _radius = data['radius']?.toString() ?? '0.5';
        _angle = data['angle']?.toString() ?? '90.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final f = double.tryParse(_force);
    final r = double.tryParse(_radius);
    final a = double.tryParse(_angle);
    if (f == null || r == null || a == null) {
      setState(() {
        _torque = null;
        _error = 'Please enter valid force, radius, and angle';
      });
      return;
    }

    try {
      final t = EngineeringEngine.calculateTorque(f, r, angleDegrees: a);
      setState(() {
        _error = null;
        _torque = t;
      });

      final stateJson = jsonEncode({'force': _force, 'radius': _radius, 'angle': _angle});
      ref.read(historyProvider.notifier).add(
        'Torque: $_force N × $_radius m @ $_angle°',
        '${t.toStringAsFixed(2)} N·m',
        toolRoute: '/tools/engineering/torque',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _torque = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _force = '100.0';
      _radius = '0.5';
      _angle = '90.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'torque',
      title: 'Torque Calculator',
      description: 'Compute rotational moment of force (τ = r · F · sin θ) in Newton-meters.',
      icon: Icons.rotate_right_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'τ = r × F × sin(θ)',
          description: 'Rotational torque produced by a lever arm and applied force.',
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
          label: 'Lever Arm Radius (r)',
          suffix: 'm',
          value: _radius,
          onChanged: (v) {
            _radius = v;
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
        else if (_torque != null) ...[
          ResultDisplayCard(
            label: 'Torque (τ)',
            value: '${_torque!.toStringAsFixed(2)} N·m',
            secondaryLabel: 'Foot-Pounds (ft·lb)',
            secondaryValue: '${(_torque! * 0.737562).toStringAsFixed(2)} ft·lb',
            formula: 'τ = r × F × sin(θ)',
            substitution: 'τ = $_radius m × $_force N × sin($_angle°) = ${_torque!.toStringAsFixed(2)} N·m',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
