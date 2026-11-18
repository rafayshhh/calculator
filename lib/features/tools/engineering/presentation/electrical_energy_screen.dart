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

class ElectricalEnergyScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ElectricalEnergyScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ElectricalEnergyScreen> createState() =>
      _ElectricalEnergyScreenState();
}

class _ElectricalEnergyScreenState
    extends ConsumerState<ElectricalEnergyScreen> {
  String _powerWatts = '1000';
  String _hoursPerDay = '5';
  String _days = '30';
  String _costPerKWh = '0.15';

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _powerWatts = data['powerWatts'] ?? '1000';
        _hoursPerDay = data['hoursPerDay'] ?? '5';
        _days = data['days'] ?? '30';
        _costPerKWh = data['costPerKWh'] ?? '0.15';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      final pVal = double.tryParse(_powerWatts);
      final hVal = double.tryParse(_hoursPerDay);
      final dVal = double.tryParse(_days) ?? 30.0;
      final costVal = double.tryParse(_costPerKWh) ?? 0.15;

      if (pVal == null || hVal == null) {
        setState(() {
          _results = null;
          _error = 'Please enter valid power and usage hours';
        });
        return;
      }

      final dailyKWh = EngineeringEngine.calculateEnergyKWh(pVal, hVal);
      final totalHours = hVal * dVal;
      final totalKWh = EngineeringEngine.calculateEnergyKWh(pVal, totalHours);
      final totalWh = EngineeringEngine.calculateEnergyWattHours(
        pVal,
        totalHours,
      );
      final totalCost = EngineeringEngine.calculateEnergyCost(
        pVal,
        totalHours,
        costVal,
      );

      setState(() {
        _error = null;
        _results = {
          'target': 'Total Energy Consumption',
          'value':
              '${totalKWh.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} kWh',
          'daily':
              '${dailyKWh.toStringAsFixed(2)} kWh/day (${(dailyKWh * 1000).toStringAsFixed(0)} Wh)',
          'totalCost': '\$${totalCost.toStringAsFixed(2)}',
          'totalWh': '${totalWh.toStringAsFixed(0)} Wh',
          'formula':
              'Energy = Power · Time (${dVal.toStringAsFixed(0)} days @ $hVal hrs/day)',
          'substitution': 'Cost: $totalKWh kWh · \$$costVal/kWh',
        };
      });

      final stateJson = jsonEncode({
        'powerWatts': _powerWatts,
        'hoursPerDay': _hoursPerDay,
        'days': _days,
        'costPerKWh': _costPerKWh,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Electrical Energy: ${_results!['value']}',
            'Cost: ${_results!['totalCost']} (${_results!['daily']})',
            toolRoute: '/tools/engineering/electrical_energy',
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
      _powerWatts = '1000';
      _hoursPerDay = '5';
      _days = '30';
      _costPerKWh = '0.15';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return FinancialToolScaffold(
      title: 'Electrical Energy & Cost',
      description: 'Calculate appliance kWh energy consumption and utility electricity bill costs',
      icon: Icons.bolt_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Appliance Power Rating (P)',
          suffix: 'Watts',
          hint: 'e.g. 1000 (1 kW)',
          value: _powerWatts,
          onChanged: (val) {
            _powerWatts = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Daily Usage Duration',
          suffix: 'hrs/day',
          hint: 'e.g. 5',
          value: _hoursPerDay,
          onChanged: (val) {
            _hoursPerDay = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Billing Time Period',
          suffix: 'days',
          hint: 'e.g. 30 (1 month)',
          value: _days,
          onChanged: (val) {
            _days = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Electricity Rate',
          suffix: '\$/kWh',
          hint: 'e.g. 0.15',
          value: _costPerKWh,
          onChanged: (val) {
            _costPerKWh = val;
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
          Row(
            children: [
              Expanded(
                child: ResultDisplayCard(
                  label: 'Estimated Cost',
                  value: _results!['totalCost'],
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                child: ResultDisplayCard(
                  label: 'Daily Usage',
                  value: _results!['daily'],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
