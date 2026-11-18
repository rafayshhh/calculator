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
import '../domain/finance_engine.dart';

class BreakEvenScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const BreakEvenScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<BreakEvenScreen> createState() => _BreakEvenScreenState();
}

class _BreakEvenScreenState extends ConsumerState<BreakEvenScreen> {
  String _fixedCosts = '5000.0';
  String _pricePerUnit = '50.0';
  String _costPerUnit = '20.0';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final fc = double.tryParse(_fixedCosts);
    final p = double.tryParse(_pricePerUnit);
    final vc = double.tryParse(_costPerUnit);
    if (fc == null || p == null || vc == null || p <= vc) {
      setState(() {
        _result = null;
        _error = 'Price per unit must exceed variable cost per unit';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateBreakEven(fixedCosts: fc, pricePerUnit: p, variableCostPerUnit: vc);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'fixedCosts': _fixedCosts, 'pricePerUnit': _pricePerUnit, 'costPerUnit': _costPerUnit});
      ref.read(historyProvider.notifier).add(
        'Break-Even: ${_result!['breakEvenUnits']} units',
        '\$${_result!['breakEvenRevenue']}',
        toolRoute: '/tools/finance/break_even',
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
      _fixedCosts = '5000.0';
      _pricePerUnit = '50.0';
      _costPerUnit = '20.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'break_even',
      title: 'Break-Even Analysis',
      description: 'Compute unit sales threshold and revenue required to recover operational costs.',
      icon: Icons.balance_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'Break-Even Units = Fixed Costs / (Price - Variable Cost)',
          description: 'Sales volume where total revenues match total fixed and variable costs.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Total Fixed Costs',
          prefix: '\$',
          value: _fixedCosts,
          onChanged: (v) {
            _fixedCosts = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Sale Price Per Unit',
          prefix: '\$',
          value: _pricePerUnit,
          onChanged: (v) {
            _pricePerUnit = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Variable Cost Per Unit',
          prefix: '\$',
          value: _costPerUnit,
          onChanged: (v) {
            _costPerUnit = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Break-Even Units',
            value: '${_result!['breakEvenUnits']} Units',
            secondaryLabel: 'Required Revenue',
            secondaryValue: '\$${_result!['breakEvenRevenue']}',
            formula: 'Units = Fixed / Contribution Margin',
            substitution: '$_fixedCosts / ($_pricePerUnit - $_costPerUnit) = ${_result!['breakEvenUnits']} units',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Unit Contribution Margin', value: '\$${_result!['contributionMarginPerUnit']}'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Contribution Margin Ratio', value: '${_result!['contributionMarginRatioPercent']}%'),
        ],
      ],
    );
  }
}
