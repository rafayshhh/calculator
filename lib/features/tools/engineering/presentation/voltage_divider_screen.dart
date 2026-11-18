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

enum VoltageDividerSolveTarget { vOut, r2 }

class VoltageDividerScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const VoltageDividerScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<VoltageDividerScreen> createState() =>
      _VoltageDividerScreenState();
}

class _VoltageDividerScreenState extends ConsumerState<VoltageDividerScreen> {
  VoltageDividerSolveTarget _target = VoltageDividerSolveTarget.vOut;
  String _vIn = '12';
  String _r1 = '1000';
  String _r2 = '2000';
  String _vOut = '8';

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final targetStr = data['target'] ?? 'vOut';
        _target = targetStr == 'r2'
            ? VoltageDividerSolveTarget.r2
            : VoltageDividerSolveTarget.vOut;
        _vIn = data['vIn'] ?? '12';
        _r1 = data['r1'] ?? '1000';
        _r2 = data['r2'] ?? '2000';
        _vOut = data['vOut'] ?? '8';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      final vinVal = double.tryParse(_vIn);
      final r1Val = double.tryParse(_r1);

      if (_target == VoltageDividerSolveTarget.vOut) {
        final r2Val = double.tryParse(_r2);
        if (vinVal == null || r1Val == null || r2Val == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid Vin, R1, and R2 values';
          });
          return;
        }
        final vOut = EngineeringEngine.calculateVoltageDividerOut(
          vinVal,
          r1Val,
          r2Val,
        );
        final ratio = r2Val / (r1Val + r2Val);
        final current = vinVal / (r1Val + r2Val);
        setState(() {
          _error = null;
          _results = {
            'target': 'Output Voltage (V_out)',
            'value':
                '${vOut.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} V',
            'secondary':
                'Division Ratio: ${(ratio * 100).toStringAsFixed(2)}% | Current: ${(current * 1000).toStringAsFixed(2)} mA',
            'formula': 'V_out = V_in · [R₂ / (R₁ + R₂)]',
            'substitution':
                'V_out = $vinVal V · [$r2Val Ω / ($r1Val + $r2Val Ω)]',
          };
        });
      } else {
        final voutVal = double.tryParse(_vOut);
        if (vinVal == null || r1Val == null || voutVal == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid Vin, Vout, and R1 values';
          });
          return;
        }
        final r2 = EngineeringEngine.calculateVoltageDividerR2(
          vinVal,
          voutVal,
          r1Val,
        );
        setState(() {
          _error = null;
          _results = {
            'target': 'Required Resistor (R₂)',
            'value':
                '${r2.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} Ω',
            'secondary': '${(r2 / 1000).toStringAsFixed(3)} kΩ',
            'formula': 'R₂ = (V_out · R₁) / (V_in - V_out)',
            'substitution':
                'R₂ = ($voutVal V · $r1Val Ω) / ($vinVal V - $voutVal V)',
          };
        });
      }

      final stateJson = jsonEncode({
        'target': _target.name,
        'vIn': _vIn,
        'r1': _r1,
        'r2': _r2,
        'vOut': _vOut,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Voltage Divider: ${_results!['target']}',
            _results!['value'],
            toolRoute: '/tools/engineering/voltage_divider',
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
      _target = VoltageDividerSolveTarget.vOut;
      _vIn = '12';
      _r1 = '1000';
      _r2 = '2000';
      _vOut = '8';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return FinancialToolScaffold(
      title: 'Voltage Divider',
      description: 'Calculate output voltage and resistor network ratio (Vout = Vin · R2 / (R1 + R2))',
      icon: Icons.alt_route_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<VoltageDividerSolveTarget>(
          segments: const [
            ButtonSegment(
              value: VoltageDividerSolveTarget.vOut,
              label: Text('Find V_out'),
            ),
            ButtonSegment(
              value: VoltageDividerSolveTarget.r2,
              label: Text('Find R₂'),
            ),
          ],
          selected: {_target},
          onSelectionChanged: (set) {
            setState(() {
              _target = set.first;
            });
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Input Voltage (V_in)',
          suffix: 'V',
          hint: 'e.g. 12',
          value: _vIn,
          onChanged: (val) {
            _vIn = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Top Resistor (R₁)',
          suffix: 'Ω',
          hint: 'e.g. 1000 (1 kΩ)',
          value: _r1,
          onChanged: (val) {
            _r1 = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.sm),
        if (_target == VoltageDividerSolveTarget.vOut)
          PremiumNumericField(
            label: 'Bottom Resistor (R₂)',
            suffix: 'Ω',
            hint: 'e.g. 2000 (2 kΩ)',
            value: _r2,
            onChanged: (val) {
              _r2 = val;
              _calculate();
            },
          )
        else
          PremiumNumericField(
            label: 'Desired Output Voltage (V_out)',
            suffix: 'V',
            hint: 'e.g. 8',
            value: _vOut,
            onChanged: (val) {
              _vOut = val;
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
        else if (_results != null)
          ResultDisplayCard(
            label: _results!['target'],
            value: _results!['value'],
            secondaryLabel: _results!['formula'],
            secondaryValue: _results!['secondary'],
          ),
      ],
    );
  }
}
