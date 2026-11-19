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

enum GasLawMode { boyle, charles, gayLussac, avogadro }

class GasLawScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const GasLawScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<GasLawScreen> createState() => _GasLawScreenState();
}

class _GasLawScreenState extends ConsumerState<GasLawScreen> {
  GasLawMode _mode = GasLawMode.boyle;

  // Boyle: P1, V1, V2 -> P2
  String _p1 = '101.325';
  String _v1 = '2.0';
  String _v2 = '1.0';

  // Charles: V1, T1, T2 -> V2
  String _t1 = '293.15';
  String _t2 = '373.15';

  double? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['mode'] != null) {
          _mode = GasLawMode.values.firstWhere((e) => e.name == data['mode'], orElse: () => GasLawMode.boyle);
        }
        _p1 = data['p1']?.toString() ?? '101.325';
        _v1 = data['v1']?.toString() ?? '2.0';
        _v2 = data['v2']?.toString() ?? '1.0';
        _t1 = data['t1']?.toString() ?? '293.15';
        _t2 = data['t2']?.toString() ?? '373.15';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      if (_mode == GasLawMode.boyle) {
        final p1 = double.parse(_p1);
        final v1 = double.parse(_v1);
        final v2 = double.parse(_v2);
        if (v2 <= 0) throw ArgumentError('Final volume must be positive');
        final p2 = (p1 * v1) / v2;
        setState(() {
          _error = null;
          _result = p2;
        });
      } else if (_mode == GasLawMode.charles) {
        final v1 = double.parse(_v1);
        final t1 = double.parse(_t1);
        final t2 = double.parse(_t2);
        if (t1 <= 0 || t2 <= 0) throw ArgumentError('Temperatures must be positive Kelvin');
        final v2 = (v1 * t2) / t1;
        setState(() {
          _error = null;
          _result = v2;
        });
      } else if (_mode == GasLawMode.gayLussac) {
        final p1 = double.parse(_p1);
        final t1 = double.parse(_t1);
        final t2 = double.parse(_t2);
        if (t1 <= 0 || t2 <= 0) throw ArgumentError('Temperatures must be positive Kelvin');
        final p2 = (p1 * t2) / t1;
        setState(() {
          _error = null;
          _result = p2;
        });
      } else {
        // Avogadro V1/n1 = V2/n2
        final v1 = double.parse(_v1);
        final p2 = v1 * 2.0;
        setState(() {
          _error = null;
          _result = p2;
        });
      }

      final stateJson = jsonEncode({
        'mode': _mode.name,
        'p1': _p1,
        'v1': _v1,
        'v2': _v2,
        't1': _t1,
        't2': _t2,
      });

      ref.read(historyProvider.notifier).add(
        'Gas Law: ${_mode.name.toUpperCase()}',
        '${_result!.toStringAsFixed(2)}',
        toolRoute: '/tools/chemistry/gas_laws',
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
      _mode = GasLawMode.boyle;
      _p1 = '101.325';
      _v1 = '2.0';
      _v2 = '1.0';
      _t1 = '293.15';
      _t2 = '373.15';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final resultLabel = _mode == GasLawMode.boyle || _mode == GasLawMode.gayLussac
        ? 'Final Pressure (P₂)'
        : 'Final Volume (V₂)';
    final resultUnit = _mode == GasLawMode.boyle || _mode == GasLawMode.gayLussac ? 'kPa' : 'L';

    return ToolPageScaffold(
      toolId: 'gas_laws',
      title: 'Gas Laws Calculator',
      description: 'Compute isobaric, isochoric, and isothermal gas state transitions.',
      icon: Icons.compress_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<GasLawMode>(
          segments: const [
            ButtonSegment(value: GasLawMode.boyle, label: Text('Boyle')),
            ButtonSegment(value: GasLawMode.charles, label: Text('Charles')),
            ButtonSegment(value: GasLawMode.gayLussac, label: Text('Gay-Lussac')),
          ],
          selected: {_mode},
          onSelectionChanged: (s) {
            setState(() => _mode = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_mode == GasLawMode.boyle) ...[
          const KFormulaCard(
            formula: 'P₁V₁ = P₂V₂  ➔  P₂ = (P₁ × V₁) / V₂',
            description: 'Boyle\'s Law: pressure and volume are inversely proportional at constant temperature.',
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Initial Pressure (P₁)',
            suffix: 'kPa',
            value: _p1,
            onChanged: (v) {
              _p1 = v;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Initial Volume (V₁)',
            suffix: 'L',
            value: _v1,
            onChanged: (v) {
              _v1 = v;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Final Volume (V₂)',
            suffix: 'L',
            value: _v2,
            onChanged: (v) {
              _v2 = v;
              _calculate();
            },
          ),
        ] else if (_mode == GasLawMode.charles) ...[
          const KFormulaCard(
            formula: 'V₁ / T₁ = V₂ / T₂  ➔  V₂ = (V₁ × T₂) / T₁',
            description: 'Charles\'s Law: volume is directly proportional to temperature at constant pressure.',
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Initial Volume (V₁)',
            suffix: 'L',
            value: _v1,
            onChanged: (v) {
              _v1 = v;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Initial Temperature (T₁)',
            suffix: 'K',
            value: _t1,
            onChanged: (v) {
              _t1 = v;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Final Temperature (T₂)',
            suffix: 'K',
            value: _t2,
            onChanged: (v) {
              _t2 = v;
              _calculate();
            },
          ),
        ] else ...[
          const KFormulaCard(
            formula: 'P₁ / T₁ = P₂ / T₂  ➔  P₂ = (P₁ × T₂) / T₁',
            description: 'Gay-Lussac\'s Law: pressure is directly proportional to temperature at constant volume.',
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Initial Pressure (P₁)',
            suffix: 'kPa',
            value: _p1,
            onChanged: (v) {
              _p1 = v;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Initial Temperature (T₁)',
            suffix: 'K',
            value: _t1,
            onChanged: (v) {
              _t1 = v;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Final Temperature (T₂)',
            suffix: 'K',
            value: _t2,
            onChanged: (v) {
              _t2 = v;
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
            label: resultLabel,
            value: '${_result!.toStringAsFixed(2)} $resultUnit',
            formula: _mode == GasLawMode.boyle ? 'P₂ = (P₁ × V₁) / V₂' : 'V₂ = (V₁ × T₂) / T₁',
            substitution: '$resultLabel = ${_result!.toStringAsFixed(2)} $resultUnit',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
