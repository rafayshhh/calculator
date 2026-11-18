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

class OhmsLawScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const OhmsLawScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends ConsumerState<OhmsLawScreen> {
  int _modeIndex = 0; // 0: V, 1: I, 2: R
  String _v = '12.0';
  String _i = '2.0';
  String _r = '6.0';
  double? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _modeIndex = data['modeIndex'] ?? 0;
        _v = data['v']?.toString() ?? '12.0';
        _i = data['i']?.toString() ?? '2.0';
        _r = data['r']?.toString() ?? '6.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      if (_modeIndex == 0) {
        final i = double.parse(_i);
        final r = double.parse(_r);
        final v = PhysicsEngine.calculateVoltage(i, r);
        setState(() {
          _error = null;
          _result = v;
        });
      } else if (_modeIndex == 1) {
        final v = double.parse(_v);
        final r = double.parse(_r);
        final i = PhysicsEngine.calculateCurrent(v, r);
        setState(() {
          _error = null;
          _result = i;
        });
      } else {
        final v = double.parse(_v);
        final i = double.parse(_i);
        final r = PhysicsEngine.calculateResistance(v, i);
        setState(() {
          _error = null;
          _result = r;
        });
      }

      final stateJson = jsonEncode({'modeIndex': _modeIndex, 'v': _v, 'i': _i, 'r': _r});
      ref.read(historyProvider.notifier).add(
        "Ohm's Law: ${_modeIndex == 0 ? "Voltage" : _modeIndex == 1 ? "Current" : "Resistance"}",
        _result!.toStringAsFixed(2),
        toolRoute: '/tools/physics/ohms_law',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _modeIndex = 0;
      _v = '12.0';
      _i = '2.0';
      _r = '6.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final label = _modeIndex == 0 ? 'Voltage (V)' : _modeIndex == 1 ? 'Current (I)' : 'Resistance (R)';
    final unit = _modeIndex == 0 ? 'V' : _modeIndex == 1 ? 'A' : 'Ω';

    return ToolPageScaffold(
      toolId: 'ohms_law',
      title: "Ohm's Law Calculator",
      description: 'Solve voltage, current, and resistance in DC electrical circuits.',
      icon: Icons.electric_bolt_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Solve V')),
            ButtonSegment(value: 1, label: Text('Solve I')),
            ButtonSegment(value: 2, label: Text('Solve R')),
          ],
          selected: {_modeIndex},
          onSelectionChanged: (s) {
            setState(() => _modeIndex = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_modeIndex != 0)
          PremiumNumericField(
            label: 'Voltage (V)',
            suffix: 'V',
            value: _v,
            onChanged: (val) {
              _v = val;
              _calculate();
            },
          ),
        if (_modeIndex != 1) ...[
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Current (I)',
            suffix: 'A',
            value: _i,
            onChanged: (val) {
              _i = val;
              _calculate();
            },
          ),
        ],
        if (_modeIndex != 2) ...[
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Resistance (R)',
            suffix: 'Ω',
            value: _r,
            onChanged: (val) {
              _r = val;
              _calculate();
            },
          ),
        ],
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: label,
            value: '${_result!.toStringAsFixed(2)} $unit',
            formula: 'V = I × R',
            substitution: '$label = ${_result!.toStringAsFixed(2)} $unit',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
