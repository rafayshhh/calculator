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

class RcTimeConstantScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RcTimeConstantScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RcTimeConstantScreen> createState() => _RcTimeConstantScreenState();
}

class _RcTimeConstantScreenState extends ConsumerState<RcTimeConstantScreen> {
  String _resistance = '10000.0';
  String _capacitance = '0.0001';
  double? _tau;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _resistance = data['resistance']?.toString() ?? '10000.0';
        _capacitance = data['capacitance']?.toString() ?? '0.0001';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final r = double.tryParse(_resistance);
    final c = double.tryParse(_capacitance);
    if (r == null || c == null || r <= 0 || c <= 0) {
      setState(() {
        _tau = null;
        _error = 'Please enter positive resistance and capacitance values';
      });
      return;
    }

    try {
      final t = EngineeringEngine.calculateRcTimeConstant(r, c);
      setState(() {
        _error = null;
        _tau = t;
      });

      final stateJson = jsonEncode({'resistance': _resistance, 'capacitance': _capacitance});
      ref.read(historyProvider.notifier).add(
        'RC Time Constant: $_resistance Ω × $_capacitance F',
        '${t.toStringAsFixed(3)} s',
        toolRoute: '/tools/engineering/rc_time_constant',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _tau = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _resistance = '10000.0';
      _capacitance = '0.0001';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'rc_time_constant',
      title: 'RC Time Constant',
      description: 'Calculate charging and discharging time constant (τ = R · C) of RC circuits.',
      icon: Icons.timer_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'τ = R × C  |  t_99% ≈ 5τ',
          description: 'Time required for capacitor to charge to 63.2% of supply voltage.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Resistance (R)',
          suffix: 'Ω',
          value: _resistance,
          onChanged: (v) {
            _resistance = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Capacitance (C)',
          suffix: 'F',
          value: _capacitance,
          onChanged: (v) {
            _capacitance = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_tau != null) ...[
          ResultDisplayCard(
            label: 'Time Constant (τ)',
            value: '${_tau!.toStringAsFixed(3)} s',
            secondaryLabel: 'Full Charge (5τ)',
            secondaryValue: '${(_tau! * 5.0).toStringAsFixed(3)} s',
            formula: 'τ = R × C',
            substitution: 'τ = $_resistance Ω × $_capacitance F = ${_tau!.toStringAsFixed(3)} s',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
