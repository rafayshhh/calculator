import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/engineering_engine.dart';

class CapacitorsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CapacitorsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CapacitorsScreen> createState() => _CapacitorsScreenState();
}

class _CapacitorsScreenState extends ConsumerState<CapacitorsScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(text: '10.0'),
    TextEditingController(text: '22.0'),
    TextEditingController(text: '47.0'),
  ];

  double? _seriesC;
  double? _parallelC;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final list = (data['values'] as List?)?.map((e) => e.toString()).toList();
        if (list != null && list.isNotEmpty) {
          _controllers.clear();
          for (final val in list) {
            _controllers.add(TextEditingController(text: val));
          }
        }
      } catch (_) {}
    }
    _calculate();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final values = <double>[];
    for (final c in _controllers) {
      final v = double.tryParse(c.text.trim());
      if (v == null || v <= 0) {
        setState(() {
          _seriesC = null;
          _parallelC = null;
          _error = 'All capacitors must have positive values';
        });
        return;
      }
      values.add(v);
    }

    try {
      final s = EngineeringEngine.calculateSeriesCapacitance(values);
      final p = EngineeringEngine.calculateParallelCapacitance(values);
      setState(() {
        _error = null;
        _seriesC = s;
        _parallelC = p;
      });

      final stateJson = jsonEncode({'values': values});
      ref.read(historyProvider.notifier).add(
        'Capacitors: Series=${s.toStringAsFixed(2)}µF, Parallel=${p.toStringAsFixed(2)}µF',
        '${s.toStringAsFixed(2)} µF',
        toolRoute: '/tools/engineering/capacitors',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _seriesC = null;
        _parallelC = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _addCapacitor() {
    setState(() {
      _controllers.add(TextEditingController(text: '10.0'));
    });
    _calculate();
  }

  void _removeCapacitor(int index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers.removeAt(index).dispose();
      });
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'capacitors',
      title: 'Capacitor Networks',
      description: 'Compute equivalent capacitance in series (1/C) and parallel (ΣC) circuits.',
      icon: Icons.battery_charging_full_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        setState(() {
          _controllers.clear();
          _controllers.addAll([
            TextEditingController(text: '10.0'),
            TextEditingController(text: '22.0'),
            TextEditingController(text: '47.0'),
          ]);
        });
        _calculate();
      },
      inputs: [
        const KFormulaCard(
          formula: '1/C_series = Σ (1/Cᵢ)  |  C_parallel = Σ Cᵢ',
          description: 'Capacitor network combination formulas.',
        ),
        const SizedBox(height: KSpacing.md),
        ..._controllers.asMap().entries.map((entry) {
          final idx = entry.key;
          final ctrl = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: KSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Capacitor C\${idx + 1}',
                      suffixText: 'µF',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                if (_controllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeCapacitor(idx),
                  ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Capacitor'),
            onPressed: _addCapacitor,
          ),
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_seriesC != null && _parallelC != null) ...[
          ResultDisplayCard(
            label: 'Series Equivalent (C_series)',
            value: '${_seriesC!.toStringAsFixed(2)} µF',
            secondaryLabel: 'Parallel Equivalent (C_parallel)',
            secondaryValue: '${_parallelC!.toStringAsFixed(2)} µF',
            formula: '1/C_series = Σ(1/Cᵢ) | C_parallel = ΣCᵢ',
            substitution: 'Series: ${_seriesC!.toStringAsFixed(2)} µF | Parallel: ${_parallelC!.toStringAsFixed(2)} µF',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
