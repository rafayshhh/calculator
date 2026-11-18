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

class ElectricalPowerScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ElectricalPowerScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ElectricalPowerScreen> createState() => _ElectricalPowerScreenState();
}

class _ElectricalPowerScreenState extends ConsumerState<ElectricalPowerScreen> {
  String _voltage = '120.0';
  String _current = '5.0';
  double? _power;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _voltage = data['voltage']?.toString() ?? '120.0';
        _current = data['current']?.toString() ?? '5.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final v = double.tryParse(_voltage);
    final i = double.tryParse(_current);
    if (v == null || i == null) {
      setState(() {
        _power = null;
        _error = 'Please enter valid voltage and current';
      });
      return;
    }

    try {
      final p = PhysicsEngine.calculateElectricalPower(v, i);
      setState(() {
        _error = null;
        _power = p;
      });

      final stateJson = jsonEncode({'voltage': _voltage, 'current': _current});
      ref.read(historyProvider.notifier).add(
        'Electrical Power: $_voltage V × $_current A',
        '${p.toStringAsFixed(2)} W',
        toolRoute: '/tools/physics/electrical_power',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _power = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _voltage = '120.0';
      _current = '5.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'electrical_power',
      title: 'Electrical Power Calculator',
      description: 'Compute electric power (P = VI) in Watts and kiloWatts.',
      icon: Icons.power_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'P = V × I',
          description: 'Electric power equals potential difference multiplied by current.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Voltage (V)',
          suffix: 'V',
          value: _voltage,
          onChanged: (v) {
            _voltage = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Current (I)',
          suffix: 'A',
          value: _current,
          onChanged: (v) {
            _current = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_power != null) ...[
          ResultDisplayCard(
            label: 'Electrical Power (P)',
            value: '${_power!.toStringAsFixed(2)} W',
            secondaryLabel: 'kiloWatts (kW)',
            secondaryValue: '${(_power! / 1000.0).toStringAsFixed(3)} kW',
            formula: 'P = V × I',
            substitution: 'P = $_voltage V × $_current A = ${_power!.toStringAsFixed(2)} W',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
