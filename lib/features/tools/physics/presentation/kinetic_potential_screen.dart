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

class KineticPotentialScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const KineticPotentialScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<KineticPotentialScreen> createState() => _KineticPotentialScreenState();
}

class _KineticPotentialScreenState extends ConsumerState<KineticPotentialScreen> {
  String _mass = '5.0';
  String _velocity = '10.0';
  String _height = '20.0';

  double? _ke;
  double? _pe;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _mass = data['mass']?.toString() ?? '5.0';
        _velocity = data['velocity']?.toString() ?? '10.0';
        _height = data['height']?.toString() ?? '20.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final m = double.tryParse(_mass);
    final v = double.tryParse(_velocity);
    final h = double.tryParse(_height);
    if (m == null || v == null || h == null) {
      setState(() {
        _ke = null;
        _pe = null;
        _error = 'Please enter valid mass, velocity, and height';
      });
      return;
    }

    try {
      final ke = PhysicsEngine.calculateKineticEnergy(m, v);
      final pe = PhysicsEngine.calculatePotentialEnergy(m, h);
      setState(() {
        _error = null;
        _ke = ke;
        _pe = pe;
      });

      final stateJson = jsonEncode({'mass': _mass, 'velocity': _velocity, 'height': _height});
      ref.read(historyProvider.notifier).add(
        'Mechanical Energy: KE=${ke.toStringAsFixed(1)}J, PE=${pe.toStringAsFixed(1)}J',
        '${(ke + pe).toStringAsFixed(1)} J',
        toolRoute: '/tools/physics/kinetic_potential',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _ke = null;
        _pe = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _mass = '5.0';
      _velocity = '10.0';
      _height = '20.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final totalE = (_ke != null && _pe != null) ? _ke! + _pe! : 0.0;

    return ToolPageScaffold(
      toolId: 'kinetic_potential',
      title: 'Kinetic & Potential Energy',
      description: 'Calculate kinetic energy (½mv²) and gravitational potential energy (mgh).',
      icon: Icons.energy_savings_leaf_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'KE = ½mv²  |  PE = mgh  |  E_total = KE + PE',
          description: 'Conservation of mechanical energy for a falling or moving body.',
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
          label: 'Velocity (v)',
          suffix: 'm/s',
          value: _velocity,
          onChanged: (v) {
            _velocity = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Height (h)',
          suffix: 'm',
          value: _height,
          onChanged: (v) {
            _height = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_ke != null && _pe != null) ...[
          ResultDisplayCard(
            label: 'Total Mechanical Energy (E)',
            value: '${totalE.toStringAsFixed(2)} J',
            secondaryLabel: 'Kinetic Energy (KE)',
            secondaryValue: '${_ke!.toStringAsFixed(2)} J',
            formula: 'E = ½mv² + mgh',
            substitution: 'KE = ${_ke!.toStringAsFixed(2)} J | PE = ${_pe!.toStringAsFixed(2)} J',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(
            label: 'Gravitational Potential Energy (PE)',
            value: '${_pe!.toStringAsFixed(2)} J',
          ),
        ],
      ],
    );
  }
}
