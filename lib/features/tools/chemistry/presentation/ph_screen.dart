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

class PhScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PhScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PhScreen> createState() => _PhScreenState();
}

class _PhScreenState extends ConsumerState<PhScreen> {
  String _hConcentration = '0.001';

  double? _ph;
  double? _poh;
  String? _status;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _hConcentration = data['hConcentration']?.toString() ?? '0.001';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final h = double.tryParse(_hConcentration);
    if (h == null || h <= 0) {
      setState(() {
        _ph = null;
        _poh = null;
        _status = null;
        _error = 'Please enter a positive [H⁺] concentration';
      });
      return;
    }

    try {
      final phVal = ChemistryEngine.calculatePhFromH(h);
      final pohVal = ChemistryEngine.calculatePohFromPh(phVal);

      String statusStr;
      if (phVal < 7.0 - 1e-4) {
        statusStr = 'Acidic (pH < 7)';
      } else if (phVal > 7.0 + 1e-4) {
        statusStr = 'Basic (pH > 7)';
      } else {
        statusStr = 'Neutral (pH = 7)';
      }

      setState(() {
        _error = null;
        _ph = phVal;
        _poh = pohVal;
        _status = statusStr;
      });

      final stateJson = jsonEncode({'hConcentration': _hConcentration});

      ref.read(historyProvider.notifier).add(
        'pH: [H⁺] = $_hConcentration M',
        phVal.toStringAsFixed(2),
        toolRoute: '/tools/chemistry/ph',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _ph = null;
        _poh = null;
        _status = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _hConcentration = '0.001';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'ph',
      title: 'pH Calculator',
      description: 'Compute pH, pOH, and hydronium concentration in aqueous equilibrium.',
      icon: Icons.water_drop_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'pH = -log₁₀[H⁺]  |  pH + pOH = 14',
          description: 'Aqueous hydronium ion concentration and equilibrium acidity.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Hydronium Concentration [H⁺]',
          suffix: 'mol/L',
          value: _hConcentration,
          onChanged: (v) {
            _hConcentration = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_ph != null) ...[
          ResultDisplayCard(
            label: 'Solution pH',
            value: _ph!.toStringAsFixed(2),
            secondaryLabel: 'Hydroxide Potential (pOH)',
            secondaryValue: _poh!.toStringAsFixed(2),
            formula: 'pH = -log₁₀($_hConcentration)',
            substitution: 'pH = ${_ph!.toStringAsFixed(2)} | pOH = ${_poh!.toStringAsFixed(2)}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(
            label: 'Hydroxide Potential (pOH)',
            value: _poh!.toStringAsFixed(2),
          ),
          const SizedBox(height: KSpacing.sm),
          KStatRow(
            label: 'Acidity Classification',
            value: _status ?? '',
          ),
        ],
      ],
    );
  }
}
