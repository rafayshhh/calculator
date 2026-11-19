import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/physics_engine.dart';

class SeriesParallelResistanceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SeriesParallelResistanceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SeriesParallelResistanceScreen> createState() => _SeriesParallelResistanceScreenState();
}

class _SeriesParallelResistanceScreenState extends ConsumerState<SeriesParallelResistanceScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(text: '100'),
    TextEditingController(text: '220'),
    TextEditingController(text: '470'),
  ];

  double? _seriesReq;
  double? _parallelReq;
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
          _seriesReq = null;
          _parallelReq = null;
          _error = 'All resistors must have positive values';
        });
        return;
      }
      values.add(v);
    }

    try {
      final s = PhysicsEngine.calculateSeriesResistance(values);
      final p = PhysicsEngine.calculateParallelResistance(values);
      setState(() {
        _error = null;
        _seriesReq = s;
        _parallelReq = p;
      });

      final stateJson = jsonEncode({'values': values});
      ref.read(historyProvider.notifier).add(
        'Resistors: Series=${s.toStringAsFixed(1)}Ω, Parallel=${p.toStringAsFixed(1)}Ω',
        '${s.toStringAsFixed(1)} Ω',
        toolRoute: '/tools/physics/series_parallel_resistance',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _seriesReq = null;
        _parallelReq = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _addResistor() {
    setState(() {
      _controllers.add(TextEditingController(text: '100'));
    });
    _calculate();
  }

  void _removeResistor(int index) {
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
      toolId: 'series_parallel_resistance',
      title: 'Series & Parallel Resistors',
      description: 'Compute equivalent resistance of series and parallel resistor networks.',
      icon: Icons.alt_route_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        setState(() {
          _controllers.clear();
          _controllers.addAll([
            TextEditingController(text: '100'),
            TextEditingController(text: '220'),
            TextEditingController(text: '470'),
          ]);
        });
        _calculate();
      },
      inputs: [
        const KFormulaCard(
          formula: 'R_series = Σ Rᵢ  |  1/R_parallel = Σ (1/Rᵢ)',
          description: 'Equivalent network resistance combinations.',
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
                      labelText: 'Resistor R${idx + 1}',
                      suffixText: 'Ω',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                if (_controllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeResistor(idx),
                  ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Resistor'),
            onPressed: _addResistor,
          ),
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_seriesReq != null && _parallelReq != null) ...[
          ResultDisplayCard(
            label: 'Series Equivalent (R_series)',
            value: '${_seriesReq!.toStringAsFixed(2)} Ω',
            secondaryLabel: 'Parallel Equivalent (R_parallel)',
            secondaryValue: '${_parallelReq!.toStringAsFixed(2)} Ω',
            formula: 'R_series = Σ Rᵢ | 1/R_parallel = Σ (1/Rᵢ)',
            substitution: 'Series: ${_seriesReq!.toStringAsFixed(2)} Ω | Parallel: ${_parallelReq!.toStringAsFixed(2)} Ω',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
