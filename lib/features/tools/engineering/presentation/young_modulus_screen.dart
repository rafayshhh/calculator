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

class YoungModulusScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const YoungModulusScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<YoungModulusScreen> createState() => _YoungModulusScreenState();
}

class _YoungModulusScreenState extends ConsumerState<YoungModulusScreen> {
  String _stress = '200000000.0';
  String _strain = '0.001';
  double? _modulus;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _stress = data['stress']?.toString() ?? '200000000.0';
        _strain = data['strain']?.toString() ?? '0.001';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final s = double.tryParse(_stress);
    final e = double.tryParse(_strain);
    if (s == null || e == null || e <= 0) {
      setState(() {
        _modulus = null;
        _error = 'Please enter valid stress and positive strain';
      });
      return;
    }

    try {
      final y = EngineeringEngine.calculateYoungsModulus(s, e);
      setState(() {
        _error = null;
        _modulus = y;
      });

      final stateJson = jsonEncode({'stress': _stress, 'strain': _strain});
      ref.read(historyProvider.notifier).add(
        "Young's Modulus: $_stress Pa / $_strain",
        '${(y / 1e9).toStringAsFixed(2)} GPa',
        toolRoute: '/tools/engineering/young_modulus',
        toolStateJson: stateJson,
      );
    } catch (err) {
      setState(() {
        _modulus = null;
        _error = err.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _stress = '200000000.0';
      _strain = '0.001';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final gpa = _modulus != null ? _modulus! / 1e9 : 0.0;

    return ToolPageScaffold(
      toolId: 'young_modulus',
      title: "Young's Modulus Calculator",
      description: 'Compute material elastic modulus (E = σ / ε) in GigaPascals.',
      icon: Icons.architecture_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'E = σ / ε',
          description: "Young's modulus equals tensile stress divided by extensional strain.",
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Tensile Stress (σ)',
          suffix: 'Pa',
          value: _stress,
          onChanged: (v) {
            _stress = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Tensile Strain (ε)',
          suffix: 'dimensionless',
          value: _strain,
          onChanged: (v) {
            _strain = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_modulus != null) ...[
          ResultDisplayCard(
            label: "Young's Modulus (E)",
            value: '${gpa.toStringAsFixed(2)} GPa',
            secondaryLabel: 'MegaPascals (MPa)',
            secondaryValue: '${(_modulus! / 1e6).toStringAsFixed(1)} MPa',
            formula: 'E = σ / ε',
            substitution: 'E = $_stress Pa / $_strain = ${gpa.toStringAsFixed(2)} GPa',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
