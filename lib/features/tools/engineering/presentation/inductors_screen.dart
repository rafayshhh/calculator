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

class InductorsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const InductorsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<InductorsScreen> createState() => _InductorsScreenState();
}

class _InductorsScreenState extends ConsumerState<InductorsScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(text: '10.0'),
    TextEditingController(text: '20.0'),
    TextEditingController(text: '30.0'),
  ];

  double? _seriesL;
  double? _parallelL;
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
          _seriesL = null;
          _parallelL = null;
          _error = 'All inductors must have positive values';
        });
        return;
      }
      values.add(v);
    }

    try {
      final s = EngineeringEngine.calculateSeriesInductance(values);
      final p = EngineeringEngine.calculateParallelInductance(values);
      setState(() {
        _error = null;
        _seriesL = s;
        _parallelL = p;
      });

      final stateJson = jsonEncode({'values': values});
      ref.read(historyProvider.notifier).add(
        'Inductors: Series=${s.toStringAsFixed(2)}mH, Parallel=${p.toStringAsFixed(2)}mH',
        '${s.toStringAsFixed(2)} mH',
        toolRoute: '/tools/engineering/inductors',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _seriesL = null;
        _parallelL = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _addInductor() {
    setState(() {
      _controllers.add(TextEditingController(text: '10.0'));
    });
    _calculate();
  }

  void _removeInductor(int index) {
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
      toolId: 'inductors',
      title: 'Inductor Networks',
      description: 'Compute equivalent inductance in series (ΣL) and parallel (1/L) circuits.',
      icon: Icons.repeat_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        setState(() {
          _controllers.clear();
          _controllers.addAll([
            TextEditingController(text: '10.0'),
            TextEditingController(text: '20.0'),
            TextEditingController(text: '30.0'),
          ]);
        });
        _calculate();
      },
      inputs: [
        const KFormulaCard(
          formula: 'L_series = Σ Lᵢ  |  1/L_parallel = Σ (1/Lᵢ)',
          description: 'Inductor network combination formulas.',
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
                      labelText: 'Inductor L\${idx + 1}',
                      suffixText: 'mH',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                if (_controllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeInductor(idx),
                  ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Inductor'),
            onPressed: _addInductor,
          ),
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_seriesL != null && _parallelL != null) ...[
          ResultDisplayCard(
            label: 'Series Equivalent (L_series)',
            value: '${_seriesL!.toStringAsFixed(2)} mH',
            secondaryLabel: 'Parallel Equivalent (L_parallel)',
            secondaryValue: '${_parallelL!.toStringAsFixed(2)} mH',
            formula: 'L_series = Σ Lᵢ | 1/L_parallel = Σ (1/Lᵢ)',
            substitution: 'Series: ${_seriesL!.toStringAsFixed(2)} mH | Parallel: ${_parallelL!.toStringAsFixed(2)} mH',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
