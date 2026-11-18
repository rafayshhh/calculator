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

class VelocityScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const VelocityScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<VelocityScreen> createState() => _VelocityScreenState();
}

class _VelocityScreenState extends ConsumerState<VelocityScreen> {
  String _distance = '100.0';
  String _time = '9.58';
  double? _velocity;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _distance = data['distance']?.toString() ?? '100.0';
        _time = data['time']?.toString() ?? '9.58';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final d = double.tryParse(_distance);
    final t = double.tryParse(_time);
    if (d == null || t == null) {
      setState(() {
        _velocity = null;
        _error = 'Please enter valid distance and elapsed time';
      });
      return;
    }

    try {
      final v = PhysicsEngine.calculateVelocity(d, t);
      setState(() {
        _error = null;
        _velocity = v;
      });

      final stateJson = jsonEncode({'distance': _distance, 'time': _time});
      ref.read(historyProvider.notifier).add(
        'Velocity: $_distance m / $_time s',
        '${v.toStringAsFixed(2)} m/s',
        toolRoute: '/tools/physics/velocity',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _velocity = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _distance = '100.0';
      _time = '9.58';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'velocity',
      title: 'Velocity Calculator',
      description: 'Compute average linear velocity from displacement and elapsed time.',
      icon: Icons.speed_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'v = d / t',
          description: 'Velocity equals displacement divided by time.',
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
          label: 'Elapsed Time (t)',
          suffix: 's',
          value: _time,
          onChanged: (v) {
            _time = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_velocity != null) ...[
          ResultDisplayCard(
            label: 'Average Velocity (v)',
            value: '${_velocity!.toStringAsFixed(2)} m/s',
            secondaryLabel: 'Kilometers per Hour',
            secondaryValue: '${(_velocity! * 3.6).toStringAsFixed(2)} km/h',
            formula: 'v = d / t',
            substitution: 'v = $_distance m / $_time s = ${_velocity!.toStringAsFixed(2)} m/s',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
