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

class GearRatioScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const GearRatioScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<GearRatioScreen> createState() => _GearRatioScreenState();
}

class _GearRatioScreenState extends ConsumerState<GearRatioScreen> {
  String _inputTeeth = '20';
  String _outputTeeth = '60';
  double? _ratio;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _inputTeeth = data['inputTeeth']?.toString() ?? '20';
        _outputTeeth = data['outputTeeth']?.toString() ?? '60';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final inT = double.tryParse(_inputTeeth);
    final outT = double.tryParse(_outputTeeth);
    if (inT == null || outT == null || inT <= 0 || outT <= 0) {
      setState(() {
        _ratio = null;
        _error = 'Please enter positive integer tooth counts';
      });
      return;
    }

    try {
      final r = EngineeringEngine.calculateGearRatio(inT, outT);
      setState(() {
        _error = null;
        _ratio = r;
      });

      final stateJson = jsonEncode({'inputTeeth': _inputTeeth, 'outputTeeth': _outputTeeth});
      ref.read(historyProvider.notifier).add(
        'Gear Ratio: $_outputTeeth / $_inputTeeth teeth',
        '${r.toStringAsFixed(2)}:1',
        toolRoute: '/tools/engineering/gear_ratio',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _ratio = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _inputTeeth = '20';
      _outputTeeth = '60';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'gear_ratio',
      title: 'Gear Ratio Calculator',
      description: 'Compute drive gear train ratio, torque multiplication, and speed reduction.',
      icon: Icons.settings_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'Gear Ratio = N_driven / N_driving',
          description: 'Ratio of follower gear tooth count to driver gear tooth count.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Driving Gear Teeth (N_in)',
          suffix: 'teeth',
          value: _inputTeeth,
          onChanged: (v) {
            _inputTeeth = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Driven Gear Teeth (N_out)',
          suffix: 'teeth',
          value: _outputTeeth,
          onChanged: (v) {
            _outputTeeth = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_ratio != null) ...[
          ResultDisplayCard(
            label: 'Gear Ratio',
            value: '${_ratio!.toStringAsFixed(2)}:1',
            secondaryLabel: 'Torque Multiplier',
            secondaryValue: '${_ratio!.toStringAsFixed(2)}x',
            formula: 'Ratio = N_out / N_in',
            substitution: 'Ratio = $_outputTeeth / $_inputTeeth = ${_ratio!.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
