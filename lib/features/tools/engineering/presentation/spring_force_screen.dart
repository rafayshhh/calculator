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

class SpringForceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SpringForceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SpringForceScreen> createState() => _SpringForceScreenState();
}

class _SpringForceScreenState extends ConsumerState<SpringForceScreen> {
  String _k = '250.0';
  String _displacement = '0.04';
  double? _force;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _k = data['k']?.toString() ?? '250.0';
        _displacement = data['displacement']?.toString() ?? '0.04';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final kVal = double.tryParse(_k);
    final xVal = double.tryParse(_displacement);
    if (kVal == null || xVal == null) {
      setState(() {
        _force = null;
        _error = 'Please enter valid spring constant and displacement';
      });
      return;
    }

    try {
      final f = EngineeringEngine.calculateSpringForce(kVal, xVal);
      setState(() {
        _error = null;
        _force = f;
      });

      final stateJson = jsonEncode({'k': _k, 'displacement': _displacement});
      ref.read(historyProvider.notifier).add(
        'Spring Force: $_k N/m × $_displacement m',
        '${f.toStringAsFixed(2)} N',
        toolRoute: '/tools/engineering/spring_force',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _force = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _k = '250.0';
      _displacement = '0.04';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'spring_force',
      title: "Spring Force (Hooke's Law)",
      description: "Calculate restoring elastic force (F = -kx) from Hooke's Law.",
      icon: Icons.all_inclusive_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'F = k × x',
          description: 'Restoring force equals spring constant multiplied by extension/compression.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Spring Constant (k)',
          suffix: 'N/m',
          value: _k,
          onChanged: (v) {
            _k = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Displacement (x)',
          suffix: 'm',
          value: _displacement,
          onChanged: (v) {
            _displacement = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_force != null) ...[
          ResultDisplayCard(
            label: 'Spring Restoring Force (F)',
            value: '${_force!.toStringAsFixed(2)} N',
            secondaryLabel: 'Stored Elastic Energy',
            secondaryValue: '${(0.5 * double.parse(_k) * double.parse(_displacement) * double.parse(_displacement)).toStringAsFixed(3)} J',
            formula: 'F = k × x',
            substitution: 'F = $_k N/m × $_displacement m = ${_force!.toStringAsFixed(2)} N',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
