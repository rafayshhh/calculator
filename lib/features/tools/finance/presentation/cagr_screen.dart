import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/finance_engine.dart';

class CagrScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CagrScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CagrScreen> createState() => _CagrScreenState();
}

class _CagrScreenState extends ConsumerState<CagrScreen> {
  String _beginningValue = '10000';
  String _endingValue = '19500';
  String _years = '3';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _beginningValue = map['beginningValue']?.toString() ?? '10000';
        _endingValue = map['endingValue']?.toString() ?? '19500';
        _years = map['years']?.toString() ?? '3';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _beginningValue = '10000';
      _endingValue = '19500';
      _years = '3';
    });
  }

  void _logHistory(Map<String, dynamic> res) {
    try {
      final stateJson = jsonEncode({
        'beginningValue': _beginningValue,
        'endingValue': _endingValue,
        'years': _years,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'CAGR: \$$_beginningValue → \$$_endingValue over $_years yrs',
            '${(res['cagrPercent'] as double).toStringAsFixed(2)}% CAGR',
            toolRoute: '/tools/finance/cagr',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result;
    String? errorMessage;

    try {
      final bv = double.tryParse(_beginningValue);
      final ev = double.tryParse(_endingValue);
      final y = double.tryParse(_years);

      if (bv != null && ev != null && y != null) {
        result = FinanceEngine.calculateCagr(
          beginningValue: bv,
          endingValue: ev,
          years: y,
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    return ToolPageScaffold(
      toolId: 'cagr',
      title: 'CAGR Calculator',
      description: 'Compute Compound Annual Growth Rate of investments across multi-year horizons.',
      icon: Icons.auto_graph_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Initial / Beginning Value',
          prefix: '\$',
          value: _beginningValue,
          onChanged: (val) => setState(() => _beginningValue = val),
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Ending / Target Value',
          prefix: '\$',
          value: _endingValue,
          onChanged: (val) => setState(() => _endingValue = val),
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Time Horizon',
          suffix: 'years',
          value: _years,
          onChanged: (val) => setState(() => _years = val),
        ),
      ],
      results: [
        if (errorMessage != null)
          ResultDisplayCard(
            label: 'Calculation Error',
            value: errorMessage,
            isError: true,
          )
        else if (result != null) ...[
          ResultDisplayCard(
            label: 'Annualized Growth Rate (CAGR)',
            value: '${(result['cagrPercent'] as double).toStringAsFixed(2)}%',
            secondaryLabel: 'Absolute Total Growth',
            secondaryValue:
                '${(result['totalGrowthPercent'] as double).toStringAsFixed(2)}%',
            formula: result['formula'],
            substitution: result['substitution'],
            details:
                'An investment of \$$_beginningValue growing to \$$_endingValue over $_years years achieves an effective compounded growth of ${(result['cagrPercent'] as double).toStringAsFixed(2)}% per year.',
            onReset: _reset,
            onShare: () => _logHistory(result!),
          ),
        ],
      ],
    );
  }
}
