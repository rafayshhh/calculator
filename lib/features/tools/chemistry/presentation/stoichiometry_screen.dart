import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/chemistry_engine.dart';

class StoichiometryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const StoichiometryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<StoichiometryScreen> createState() => _StoichiometryScreenState();
}

class _StoichiometryScreenState extends ConsumerState<StoichiometryScreen> {
  String _reactantFormula = 'H2';
  String _productFormula = 'H2O';
  String _reactantMoles = '2.0';
  String _reactantCoeff = '2';
  String _productCoeff = '2';

  double? _yieldMoles;
  double? _yieldGrams;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _reactantFormula = data['reactantFormula']?.toString() ?? 'H2';
        _productFormula = data['productFormula']?.toString() ?? 'H2O';
        _reactantMoles = data['reactantMoles']?.toString() ?? '2.0';
        _reactantCoeff = data['reactantCoeff']?.toString() ?? '2';
        _productCoeff = data['productCoeff']?.toString() ?? '2';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final moles = double.tryParse(_reactantMoles);
    final cIn = double.tryParse(_reactantCoeff);
    final cOut = double.tryParse(_productCoeff);

    if (moles == null || cIn == null || cOut == null || cIn <= 0 || cOut <= 0) {
      setState(() {
        _yieldMoles = null;
        _yieldGrams = null;
        _error = 'Please enter valid positive stoichiometry coefficients';
      });
      return;
    }

    try {
      final productMolarMass = ChemistryEngine.calculateMolarMass(_productFormula).totalMolarMass;
      final outMoles = moles * (cOut / cIn);
      final grams = outMoles * productMolarMass;

      setState(() {
        _error = null;
        _yieldMoles = outMoles;
        _yieldGrams = grams;
      });

      final stateJson = jsonEncode({
        'reactantFormula': _reactantFormula,
        'productFormula': _productFormula,
        'reactantMoles': _reactantMoles,
        'reactantCoeff': _reactantCoeff,
        'productCoeff': _productCoeff,
      });

      ref.read(historyProvider.notifier).add(
        'Stoichiometry: $_reactantMoles mol $_reactantFormula -> $_productFormula',
        '${grams.toStringAsFixed(2)} g',
        toolRoute: '/tools/chemistry/stoichiometry',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _yieldMoles = null;
        _yieldGrams = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _reactantFormula = 'H2';
      _productFormula = 'H2O';
      _reactantMoles = '2.0';
      _reactantCoeff = '2';
      _productCoeff = '2';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'stoichiometry',
      title: 'Stoichiometry Calculator',
      description: 'Compute theoretical molar yield and mass products from balanced reaction coefficients.',
      icon: Icons.bubble_chart_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'a A  ➔  b B  ⟹  n_B = n_A × (b / a)',
          description: 'Mole ratio determination from balanced reaction coefficients.',
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: _reactantFormula,
                decoration: const InputDecoration(labelText: 'Reactant (A)', border: OutlineInputBorder()),
                onChanged: (v) {
                  _reactantFormula = v.trim();
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Coeff a',
                value: _reactantCoeff,
                onChanged: (v) {
                  _reactantCoeff = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Reactant Moles (n_A)',
          suffix: 'mol',
          value: _reactantMoles,
          onChanged: (v) {
            _reactantMoles = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: _productFormula,
                decoration: const InputDecoration(labelText: 'Product (B)', border: OutlineInputBorder()),
                onChanged: (v) {
                  _productFormula = v.trim();
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Coeff b',
                value: _productCoeff,
                onChanged: (v) {
                  _productCoeff = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_yieldGrams != null) ...[
          ResultDisplayCard(
            label: 'Yield of $_productFormula',
            value: '${_yieldGrams!.toStringAsFixed(2)} g',
            secondaryLabel: 'Theoretical Moles',
            secondaryValue: '${_yieldMoles!.toStringAsFixed(2)} mol',
            formula: 'n_B = n_A × (b/a)',
            substitution: 'n_$_productFormula = $_reactantMoles mol × ($_productCoeff/$_reactantCoeff) = ${_yieldMoles!.toStringAsFixed(2)} mol',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(
            label: 'Product Formula Mass',
            value: '${ChemistryEngine.calculateMolarMass(_productFormula).totalMolarMass.toStringAsFixed(3)} g/mol',
          ),
        ],
      ],
    );
  }
}
