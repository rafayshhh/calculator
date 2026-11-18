import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/engineering_engine.dart';

class LedResistorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const LedResistorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<LedResistorScreen> createState() => _LedResistorScreenState();
}

class _LedResistorScreenState extends ConsumerState<LedResistorScreen> {
  String _vSupply = '5';
  String _vForward = '2.0';
  String _currentMa = '20';

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _vSupply = data['vSupply'] ?? '5';
        _vForward = data['vForward'] ?? '2.0';
        _currentMa = data['currentMa'] ?? '20';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      final vsVal = double.tryParse(_vSupply);
      final vfVal = double.tryParse(_vForward);
      final maVal = double.tryParse(_currentMa);

      if (vsVal == null || vfVal == null || maVal == null) {
        setState(() {
          _results = null;
          _error =
              'Please enter valid supply voltage, forward voltage, and current';
        });
        return;
      }

      final currentAmps = maVal / 1000.0;
      final r = EngineeringEngine.calculateLedResistor(
        vsVal,
        vfVal,
        currentAmps,
      );
      final p = EngineeringEngine.calculateLedPower(vsVal, vfVal, currentAmps);
      final pMw = p * 1000.0;

      // Recommended standard resistor power rating (e.g. 1/4W, 1/2W)
      String rating = '1/8 W (0.125 W)';
      if (p > 0.5) {
        rating = '1 W+';
      } else if (p > 0.25) {
        rating = '1/2 W (0.5 W)';
      } else if (p > 0.125) {
        rating = '1/4 W (0.25 W)';
      }

      setState(() {
        _error = null;
        _results = {
          'target': 'Current-Limiting Resistor (R)',
          'value':
              '${r.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} Ω',
          'power': '${pMw.toStringAsFixed(2)} mW (Min rating: $rating)',
          'formula': 'R = (V_supply - V_f) / I',
          'substitution': 'R = ($vsVal V - $vfVal V) / $currentAmps A',
        };
      });

      final stateJson = jsonEncode({
        'vSupply': _vSupply,
        'vForward': _vForward,
        'currentMa': _currentMa,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'LED Resistor: ${_results!['value']}',
            'Vs: $_vSupply V, Vf: $_vForward V, I: $_currentMa mA',
            toolRoute: '/tools/engineering/led_resistor',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _results = null;
        _error = e
            .toString()
            .replaceAll('ArgumentError: ', '')
            .replaceAll('Invalid argument(s): ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _vSupply = '5';
      _vForward = '2.0';
      _currentMa = '20';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return FinancialToolScaffold(
      title: 'LED Resistor Calculator',
      description:
          'Current-limiting series resistor & power dissipation for LEDs',
      icon: Icons.lightbulb_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Power Supply Voltage (V_supply)',
          suffix: 'V',
          hint: 'e.g. 5 or 12',
          value: _vSupply,
          onChanged: (val) {
            _vSupply = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'LED Forward Voltage (V_f)',
          suffix: 'V',
          hint: 'Red: 2.0V, Blue/White: 3.2V',
          value: _vForward,
          onChanged: (val) {
            _vForward = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Desired LED Current (I)',
          suffix: 'mA',
          hint: 'Standard: 20 mA',
          value: _currentMa,
          onChanged: (val) {
            _currentMa = val;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(
            label: 'Calculation Error',
            value: _error!,
            isError: true,
          )
        else if (_results != null) ...[
          ResultDisplayCard(
            label: _results!['target'],
            value: _results!['value'],
            secondaryLabel: _results!['formula'],
            secondaryValue: _results!['substitution'],
          ),
          const SizedBox(height: KSpacing.sm),
          ResultDisplayCard(
            label: 'Resistor Power Dissipation',
            value: _results!['power'],
          ),
        ],
      ],
    );
  }
}
