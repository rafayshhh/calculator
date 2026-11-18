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

class ConcentrationScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ConcentrationScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ConcentrationScreen> createState() => _ConcentrationScreenState();
}

class _ConcentrationScreenState extends ConsumerState<ConcentrationScreen> {
  String _soluteMass = '15.0';
  String _totalMass = '100.0';

  double? _massPercent;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _soluteMass = data['soluteMass']?.toString() ?? '15.0';
        _totalMass = data['totalMass']?.toString() ?? '100.0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final solute = double.tryParse(_soluteMass);
    final total = double.tryParse(_totalMass);

    if (solute == null || total == null) {
      setState(() {
        _massPercent = null;
        _error = 'Please enter valid mass values';
      });
      return;
    }

    try {
      final res = ChemistryEngine.calculateMassPercentage(solute, total);
      setState(() {
        _error = null;
        _massPercent = res;
      });

      final stateJson = jsonEncode({
        'soluteMass': _soluteMass,
        'totalMass': _totalMass,
      });

      ref.read(historyProvider.notifier).add(
        'Concentration: $_soluteMass g / $_totalMass g',
        '${_formatNum(res)}%',
        toolRoute: '/tools/chemistry/concentration',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _massPercent = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _soluteMass = '15.0';
      _totalMass = '100.0';
    });
    _calculate();
  }

  String _formatNum(double n) {
    if (n.truncateToDouble() == n) return n.toInt().toString();
    return n.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'concentration',
      title: 'Concentration Calculator',
      description: 'Compute mass concentration percentage (% w/w) and ppm solutions.',
      icon: Icons.opacity_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'Mass % = (Mass_solute / Mass_total) × 100%',
          description: 'Ratio of dissolved solute mass to total solution mass.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Solute Mass',
          suffix: 'g',
          value: _soluteMass,
          onChanged: (v) {
            _soluteMass = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Total Solution Mass',
          suffix: 'g',
          value: _totalMass,
          onChanged: (v) {
            _totalMass = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_massPercent != null) ...[
          ResultDisplayCard(
            label: 'Mass Percentage (% w/w)',
            value: '${_formatNum(_massPercent!)}%',
            secondaryLabel: 'Parts Per Million (ppm)',
            secondaryValue: '${_formatNum(_massPercent! * 10000)} ppm',
            formula: 'Mass % = (m_solute / m_total) × 100',
            substitution: 'Mass % = ($_soluteMass / $_totalMass) × 100 = ${_formatNum(_massPercent!)}%',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(
            label: 'Solvent Mass',
            value: '${_formatNum(double.parse(_totalMass) - double.parse(_soluteMass))} g',
          ),
        ],
      ],
    );
  }
}
