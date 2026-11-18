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

class ResistanceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ResistanceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ResistanceScreen> createState() => _ResistanceScreenState();
}

class _ResistanceScreenState extends ConsumerState<ResistanceScreen> {
  String _voltage = '12.0';
  String _current = '0.5';
  double? _resistance;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _voltage = data['voltage']?.toString() ?? '12.0';
        _current = data['current']?.toString() ?? '0.5';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final v = double.tryParse(_voltage);
    final i = double.tryParse(_current);
    if (v == null || i == null) {
      setState(() {
        _resistance = null;
        _error = 'Please enter valid voltage and current';
      });
      return;
    }

    try {
      final r = PhysicsEngine.calculateResistance(v, i);
      setState(() {
        _error = null;
        _resistance = r;
      });

      final stateJson = jsonEncode({'voltage': _voltage, 'current': _current});
      ref.read(historyProvider.notifier).add(
        'Resistance: $_voltage V / $_current A',
        '${r.toStringAsFixed(2)} Ω',
        toolRoute: '/tools/physics/resistance',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _resistance = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _voltage = '12.0';
      _current = '0.5';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'resistance',
      title: 'Resistance Calculator',
      description: 'Compute electrical resistance from potential drop and current.',
      icon: Icons.grain_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'R = V / I',
          description: 'Resistance equals voltage divided by current.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Voltage Drop (V)',
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
        else if (_resistance != null) ...[
          ResultDisplayCard(
            label: 'Resistance (R)',
            value: '${_resistance!.toStringAsFixed(2)} Ω',
            secondaryLabel: 'kiloOhms (kΩ)',
            secondaryValue: '${(_resistance! / 1000.0).toStringAsFixed(3)} kΩ',
            formula: 'R = V / I',
            substitution: 'R = $_voltage V / $_current A = ${_resistance!.toStringAsFixed(2)} Ω',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
