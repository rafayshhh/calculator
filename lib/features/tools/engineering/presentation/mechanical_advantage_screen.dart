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

class MechanicalAdvantageScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MechanicalAdvantageScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MechanicalAdvantageScreen> createState() => _MechanicalAdvantageScreenState();
}

class _MechanicalAdvantageScreenState extends ConsumerState<MechanicalAdvantageScreen> {
  String _outputForce = '500.0';
  String _inputForce = '100.0';
  double? _ma;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _outputForce = data['outputForce']?.toString() ?? '500.0';
        _inputForce = data['inputForce']?.toString() ?? '100.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final fo = double.tryParse(_outputForce);
    final fi = double.tryParse(_inputForce);
    if (fo == null || fi == null || fi <= 0) {
      setState(() {
        _ma = null;
        _error = 'Please enter valid forces with positive effort force';
      });
      return;
    }

    try {
      final res = EngineeringEngine.calculateMechanicalAdvantage(fo, fi);
      setState(() {
        _error = null;
        _ma = res;
      });

      final stateJson = jsonEncode({'outputForce': _outputForce, 'inputForce': _inputForce});
      ref.read(historyProvider.notifier).add(
        'Mechanical Advantage: $_outputForce N / $_inputForce N',
        '${res.toStringAsFixed(2)}:1',
        toolRoute: '/tools/engineering/mechanical_advantage',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _ma = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _outputForce = '500.0';
      _inputForce = '100.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'mechanical_advantage',
      title: 'Mechanical Advantage',
      description: 'Compute mechanical force multiplication factor (MA = F_out / F_in).',
      icon: Icons.handyman_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'MA = F_load / F_effort',
          description: 'Force multiplication factor of a simple machine or mechanism.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Load / Output Force (F_out)',
          suffix: 'N',
          value: _outputForce,
          onChanged: (v) {
            _outputForce = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Effort / Input Force (F_in)',
          suffix: 'N',
          value: _inputForce,
          onChanged: (v) {
            _inputForce = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_ma != null) ...[
          ResultDisplayCard(
            label: 'Mechanical Advantage (MA)',
            value: '${_ma!.toStringAsFixed(2)}:1',
            secondaryLabel: 'Force Multiplication',
            secondaryValue: '${_ma!.toStringAsFixed(2)}x',
            formula: 'MA = F_out / F_in',
            substitution: 'MA = $_outputForce N / $_inputForce N = ${_ma!.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
