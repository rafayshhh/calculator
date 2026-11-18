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

class MomentumScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MomentumScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MomentumScreen> createState() => _MomentumScreenState();
}

class _MomentumScreenState extends ConsumerState<MomentumScreen> {
  String _mass = '1500.0';
  String _velocity = '20.0';
  double? _momentum;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _mass = data['mass']?.toString() ?? '1500.0';
        _velocity = data['velocity']?.toString() ?? '20.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final m = double.tryParse(_mass);
    final v = double.tryParse(_velocity);
    if (m == null || v == null) {
      setState(() {
        _momentum = null;
        _error = 'Please enter valid mass and velocity';
      });
      return;
    }

    try {
      final p = PhysicsEngine.calculateMomentum(m, v);
      setState(() {
        _error = null;
        _momentum = p;
      });

      final stateJson = jsonEncode({'mass': _mass, 'velocity': _velocity});
      ref.read(historyProvider.notifier).add(
        'Momentum: $_mass kg × $_velocity m/s',
        '${p.toStringAsFixed(2)} kg·m/s',
        toolRoute: '/tools/physics/momentum',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _momentum = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _mass = '1500.0';
      _velocity = '20.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'momentum',
      title: 'Momentum Calculator',
      description: 'Compute linear momentum (p = mv) of moving bodies.',
      icon: Icons.airline_stops_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'p = m × v',
          description: 'Linear momentum equals mass times velocity.',
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
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_momentum != null) ...[
          ResultDisplayCard(
            label: 'Linear Momentum (p)',
            value: '${_momentum!.toStringAsFixed(2)} kg·m/s',
            secondaryLabel: 'Newton-seconds',
            secondaryValue: '${_momentum!.toStringAsFixed(2)} N·s',
            formula: 'p = m × v',
            substitution: 'p = $_mass kg × $_velocity m/s = ${_momentum!.toStringAsFixed(2)} kg·m/s',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
