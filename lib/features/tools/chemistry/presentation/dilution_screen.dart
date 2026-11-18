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

class DilutionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DilutionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DilutionScreen> createState() => _DilutionScreenState();
}

class _DilutionScreenState extends ConsumerState<DilutionScreen> {
  String _m1 = '2.0';
  String _m2 = '0.5';
  String _v2 = '100';

  double? _v1Result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _m1 = data['m1']?.toString() ?? '2.0';
        _m2 = data['m2']?.toString() ?? '0.5';
        _v2 = data['v2']?.toString() ?? '100';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final m1 = double.tryParse(_m1);
    final m2 = double.tryParse(_m2);
    final v2 = double.tryParse(_v2);

    if (m1 == null || m2 == null || v2 == null) {
      setState(() {
        _v1Result = null;
        _error = 'Please enter valid numeric concentrations and volume';
      });
      return;
    }

    try {
      final res = ChemistryEngine.calculateDilutionV1(m1, m2, v2);
      setState(() {
        _error = null;
        _v1Result = res;
      });

      final stateJson = jsonEncode({'m1': _m1, 'm2': _m2, 'v2': _v2});
      ref.read(historyProvider.notifier).add(
        'Dilution: $_m1 M -> $_m2 M',
        '${_formatNum(res)} mL',
        toolRoute: '/tools/chemistry/dilution',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _v1Result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _m1 = '2.0';
      _m2 = '0.5';
      _v2 = '100';
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
      toolId: 'dilution',
      title: 'Dilution Calculator',
      description: 'Compute required stock volume for desired dilution using M₁V₁ = M₂V₂.',
      icon: Icons.science_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'M₁V₁ = M₂V₂  ➔  V₁ = (M₂ × V₂) / M₁',
          description: 'Dilution equation relating initial and target molarities and volumes.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Initial Stock Concentration (M₁)',
          suffix: 'M',
          value: _m1,
          onChanged: (v) {
            _m1 = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Desired Target Concentration (M₂)',
          suffix: 'M',
          value: _m2,
          onChanged: (v) {
            _m2 = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Desired Target Volume (V₂)',
          suffix: 'mL',
          value: _v2,
          onChanged: (v) {
            _v2 = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_v1Result != null) ...[
          ResultDisplayCard(
            label: 'Required Stock Volume (V₁)',
            value: '${_formatNum(_v1Result!)} mL',
            secondaryLabel: 'Solvent to Add',
            secondaryValue: '${_formatNum(double.parse(_v2) - _v1Result!)} mL',
            formula: 'V₁ = (M₂ × V₂) / M₁',
            substitution: 'V₁ = ($_m2 × $_v2) / $_m1 = ${_formatNum(_v1Result!)} mL',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(
            label: 'Total Final Volume',
            value: '$_v2 mL',
          ),
        ],
      ],
    );
  }
}
