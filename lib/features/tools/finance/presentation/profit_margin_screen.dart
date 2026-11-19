import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/finance_engine.dart';

class ProfitMarginScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ProfitMarginScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ProfitMarginScreen> createState() => _ProfitMarginScreenState();
}

class _ProfitMarginScreenState extends ConsumerState<ProfitMarginScreen> {
  String _cost = '60.0';
  String _revenue = '100.0';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final c = double.tryParse(_cost);
    final r = double.tryParse(_revenue);
    if (c == null || r == null || c < 0 || r <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid positive cost and revenue values';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateMarginMarkup(cost: c, revenue: r);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'cost': _cost, 'revenue': _revenue});
      ref.read(historyProvider.notifier).add(
        'Margin: Cost \$$_cost, Rev \$$_revenue',
        '${(res['grossMarginPercent'] as double).toStringAsFixed(2)}%',
        toolRoute: '/tools/finance/profit_margin',
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
      _cost = '60.0';
      _revenue = '100.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'profit_margin',
      title: 'Profit Margin & Markup',
      description: 'Compute gross profit margin percentage and sales markup.',
      icon: Icons.pie_chart_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Cost of Goods Sold (COGS)',
          prefix: '\$',
          value: _cost,
          onChanged: (v) {
            _cost = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Gross Sales Revenue',
          prefix: '\$',
          value: _revenue,
          onChanged: (v) {
            _revenue = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Gross Profit Margin',
            value: '${(_result!['grossMarginPercent'] as double).toStringAsFixed(2)}%',
            secondaryLabel: 'Markup on Cost',
            secondaryValue: '${(_result!['markupPercent'] as double).toStringAsFixed(2)}%',
            formula: 'Margin = (Revenue - Cost) / Revenue',
            substitution: 'Profit: \$${(_result!['grossProfit'] as double).toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
