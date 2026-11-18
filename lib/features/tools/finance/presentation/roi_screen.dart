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
import '../domain/finance_engine.dart';

class RoiScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RoiScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RoiScreen> createState() => _RoiScreenState();
}

class _RoiScreenState extends ConsumerState<RoiScreen> {
  String _invested = '5000.0';
  String _returned = '7500.0';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final inv = double.tryParse(_invested);
    final ret = double.tryParse(_returned);
    if (inv == null || ret == null || inv <= 0) {
      setState(() {
        _result = null;
        _error = 'Initial investment amount must be greater than zero';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateRoi(initialInvestment: inv, finalValue: ret);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'invested': _invested, 'returned': _returned});
      ref.read(historyProvider.notifier).add(
        'ROI: Invest \$$_invested -> Return \$$_returned',
        '${(res['roiPercent'] as double).toStringAsFixed(2)}%',
        toolRoute: '/tools/finance/roi',
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
      _invested = '5000.0';
      _returned = '7500.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'roi',
      title: 'Return on Investment (ROI)',
      description: 'Compute overall capital gain percentage and net profitability from invested assets.',
      icon: Icons.trending_up_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Total Capital Invested',
          prefix: '\$',
          value: _invested,
          onChanged: (v) {
            _invested = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Final Returned Value',
          prefix: '\$',
          value: _returned,
          onChanged: (v) {
            _returned = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Return on Investment',
            value: '${(_result!['roiPercent'] as double).toStringAsFixed(2)}%',
            secondaryLabel: 'Net Profit',
            secondaryValue: '\$${(_result!['netProfit'] as double).toStringAsFixed(2)}',
            formula: 'ROI = (Gain - Cost) / Cost × 100%',
            substitution: '(\$$_returned - \$$_invested) / \$$_invested = ${(_result!['roiPercent'] as double).toStringAsFixed(2)}%',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
