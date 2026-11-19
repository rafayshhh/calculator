import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/physics_engine.dart';

class ForceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ForceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ForceScreen> createState() => _ForceScreenState();
}

class _ForceScreenState extends ConsumerState<ForceScreen> {
  String _mass = '10.0';
  String _acceleration = '9.8';
  double? _force;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _mass = data['mass']?.toString() ?? '10.0';
        _acceleration = data['acceleration']?.toString() ?? '9.8';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final m = double.tryParse(_mass);
    final a = double.tryParse(_acceleration);
    if (m == null || a == null) {
      setState(() {
        _force = null;
        _error = 'Please enter valid mass and acceleration';
      });
      return;
    }

    try {
      final f = PhysicsEngine.calculateForce(m, a);
      setState(() {
        _error = null;
        _force = f;
      });

      final stateJson = jsonEncode({'mass': _mass, 'acceleration': _acceleration});
      ref.read(historyProvider.notifier).add(
        'Force: $_mass kg × $_acceleration m/s²',
        '${f.toStringAsFixed(2)} N',
        toolRoute: '/tools/physics/force',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _force = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _mass = '10.0';
      _acceleration = '9.8';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'force',
      title: 'Force Calculator',
      description: "Compute net force according to Newton's Second Law of Motion (F = ma).",
      icon: Icons.fitness_center_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'F = m × a',
          description: 'Force equals mass multiplied by linear acceleration.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Mass (m)',
          suffix: 'kg',
          value: _mass,
          onChanged: (v) {
            _mass = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Acceleration (a)',
          suffix: 'm/s²',
          value: _acceleration,
          onChanged: (v) {
            _acceleration = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_force != null) ...[
          ResultDisplayCard(
            label: 'Net Force (F)',
            value: '${_force!.toStringAsFixed(2)} N',
            secondaryLabel: 'kiloNewtons',
            secondaryValue: '${(_force! / 1000.0).toStringAsFixed(3)} kN',
            formula: 'F = m × a',
            substitution: 'F = $_mass kg × $_acceleration m/s² = ${_force!.toStringAsFixed(2)} N',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
