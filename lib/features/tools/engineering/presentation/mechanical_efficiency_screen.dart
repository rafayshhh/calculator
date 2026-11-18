import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/engineering_engine.dart';

enum EfficiencySolveMode { efficiency, output, input }

class MechanicalEfficiencyScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MechanicalEfficiencyScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MechanicalEfficiencyScreen> createState() =>
      _MechanicalEfficiencyScreenState();
}

class _MechanicalEfficiencyScreenState
    extends ConsumerState<MechanicalEfficiencyScreen> {
  EfficiencySolveMode _mode = EfficiencySolveMode.efficiency;

  String _usefulOutput = '750';
  String _totalInput = '1000';
  String _efficiency = '75';

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final modeStr = data['mode'] ?? 'efficiency';
        _mode = EfficiencySolveMode.values.firstWhere(
          (e) => e.name == modeStr,
          orElse: () => EfficiencySolveMode.efficiency,
        );
        _usefulOutput = data['output'] ?? '750';
        _totalInput = data['input'] ?? '1000';
        _efficiency = data['efficiency'] ?? '75';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      if (_mode == EfficiencySolveMode.efficiency) {
        final output = double.tryParse(_usefulOutput);
        final input = double.tryParse(_totalInput);
        if (output == null || input == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid numerical output and input';
          });
          return;
        }
        final eff = EngineeringEngine.calculateEfficiency(output, input);
        setState(() {
          _error = null;
          _results = {
            'target': 'Mechanical Efficiency (η)',
            'value':
                '${eff.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}%',
            'formula': 'η = (Useful Output / Total Input) × 100%',
            'substitution': 'η = ($output / $input) × 100',
            'summary': 'Useful: $output J / W, Total: $input J / W',
          };
        });
      } else if (_mode == EfficiencySolveMode.output) {
        final input = double.tryParse(_totalInput);
        final eff = double.tryParse(_efficiency);
        if (input == null || eff == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid numerical input and efficiency';
          });
          return;
        }
        final out = EngineeringEngine.calculateUsefulOutput(input, eff);
        setState(() {
          _error = null;
          _results = {
            'target': 'Useful Work / Power Output',
            'value': out.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), ''),
            'formula': 'Output = Input × (η / 100)',
            'substitution': 'Output = $input × ($eff / 100)',
            'summary': 'Input: $input, Efficiency: $eff%',
          };
        });
      } else {
        final output = double.tryParse(_usefulOutput);
        final eff = double.tryParse(_efficiency);
        if (output == null || eff == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid numerical output and efficiency';
          });
          return;
        }
        final inp = EngineeringEngine.calculateTotalInput(output, eff);
        setState(() {
          _error = null;
          _results = {
            'target': 'Total Work / Power Input Required',
            'value': inp.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), ''),
            'formula': 'Input = (Output × 100) / η',
            'substitution': 'Input = ($output × 100) / $eff',
            'summary': 'Output: $output, Efficiency: $eff%',
          };
        });
      }

      final stateJson = jsonEncode({
        'mode': _mode.name,
        'output': _usefulOutput,
        'input': _totalInput,
        'efficiency': _efficiency,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Mechanical Efficiency: ${_results!['value']}',
            _results!['summary'],
            toolRoute: '/tools/engineering/mechanical_efficiency',
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
      _mode = EfficiencySolveMode.efficiency;
      _usefulOutput = '750';
      _totalInput = '1000';
      _efficiency = '75';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textSecondaryColor = isDark
        ? KColors.textSecondaryDark
        : KColors.textSecondaryLight;

    return FinancialToolScaffold(
      title: 'Mechanical Efficiency',
      description: 'Useful output vs. total input energy or power ratio',
      icon: Icons.speed_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<EfficiencySolveMode>(
          segments: const [
            ButtonSegment(
              value: EfficiencySolveMode.efficiency,
              label: Text('Solve η (%)'),
            ),
            ButtonSegment(
              value: EfficiencySolveMode.output,
              label: Text('Solve Output'),
            ),
            ButtonSegment(
              value: EfficiencySolveMode.input,
              label: Text('Solve Input'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (set) {
            setState(() {
              _mode = set.first;
            });
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_mode == EfficiencySolveMode.efficiency ||
            _mode == EfficiencySolveMode.input) ...[
          PremiumNumericField(
            label: 'Useful Work / Power Output',
            value: _usefulOutput,
            onChanged: (val) {
              _usefulOutput = val;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode == EfficiencySolveMode.efficiency ||
            _mode == EfficiencySolveMode.output) ...[
          PremiumNumericField(
            label: 'Total Work / Power Input',
            value: _totalInput,
            onChanged: (val) {
              _totalInput = val;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode == EfficiencySolveMode.output ||
            _mode == EfficiencySolveMode.input) ...[
          PremiumNumericField(
            label: 'Efficiency Percentage (η %)',
            value: _efficiency,
            onChanged: (val) {
              _efficiency = val;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
        ],
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
            secondaryLabel: 'Calculation Mode',
            secondaryValue: _mode.name.toUpperCase(),
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formula & Computation',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _results!['formula'],
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _results!['substitution'],
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
