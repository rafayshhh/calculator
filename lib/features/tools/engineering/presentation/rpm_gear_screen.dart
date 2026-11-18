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

class RpmGearScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RpmGearScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RpmGearScreen> createState() => _RpmGearScreenState();
}

class _RpmGearScreenState extends ConsumerState<RpmGearScreen> {
  String _inputRpm = '1800.0';
  String _gearRatio = '3.0';
  double? _outputRpm;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _inputRpm = data['inputRpm']?.toString() ?? '1800.0';
        _gearRatio = data['gearRatio']?.toString() ?? '3.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final rpm = double.tryParse(_inputRpm);
    final ratio = double.tryParse(_gearRatio);
    if (rpm == null || ratio == null || ratio <= 0) {
      setState(() {
        _outputRpm = null;
        _error = 'Please enter positive gear ratio and valid RPM';
      });
      return;
    }

    try {
      final out = EngineeringEngine.calculateRpmGear(rpm, ratio);
      setState(() {
        _error = null;
        _outputRpm = out;
      });

      final stateJson = jsonEncode({'inputRpm': _inputRpm, 'gearRatio': _gearRatio});
      ref.read(historyProvider.notifier).add(
        'RPM Gear: $_inputRpm RPM / $_gearRatio ratio',
        '${out.toStringAsFixed(1)} RPM',
        toolRoute: '/tools/engineering/rpm_gear',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _outputRpm = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _inputRpm = '1800.0';
      _gearRatio = '3.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'rpm_gear',
      title: 'RPM & Gear Speed',
      description: 'Compute driven shaft rotational speed from input RPM and gear reduction ratio.',
      icon: Icons.sync_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'RPM_out = RPM_in / Gear_Ratio',
          description: 'Output rotational speed after gear reduction stage.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Input Motor Speed (RPM_in)',
          suffix: 'RPM',
          value: _inputRpm,
          onChanged: (v) {
            _inputRpm = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Gear Ratio (Reduction)',
          suffix: ':1',
          value: _gearRatio,
          onChanged: (v) {
            _gearRatio = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_outputRpm != null) ...[
          ResultDisplayCard(
            label: 'Output Rotational Speed',
            value: '${_outputRpm!.toStringAsFixed(1)} RPM',
            secondaryLabel: 'Angular Velocity (ω)',
            secondaryValue: '${(_outputRpm! * 2 * 3.14159265 / 60.0).toStringAsFixed(2)} rad/s',
            formula: 'RPM_out = RPM_in / Ratio',
            substitution: 'RPM_out = $_inputRpm / $_gearRatio = ${_outputRpm!.toStringAsFixed(1)} RPM',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
