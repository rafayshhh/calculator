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

class PercentageScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PercentageScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends ConsumerState<PercentageScreen> {
  String _mode = 'percentOf'; // 'percentOf', 'isWhatPercent', 'percentageChange', 'percentageDifference', 'reversePercent'
  String _val1 = '25';
  String _val2 = '200';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _mode = map['mode']?.toString() ?? 'percentOf';
        _val1 = map['val1']?.toString() ?? '25';
        _val2 = map['val2']?.toString() ?? '200';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _mode = 'percentOf';
      _val1 = '25';
      _val2 = '200';
    });
  }

  void _logHistory(Map<String, dynamic> res) {
    try {
      final stateJson = jsonEncode({
        'mode': _mode,
        'val1': _val1,
        'val2': _val2,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Percentage (${res['mode']}): $_val1, $_val2',
            (res['result'] as double).toStringAsFixed(2),
            toolRoute: '/tools/finance/percentage',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  String get _label1 {
    switch (_mode) {
      case 'percentOf':
        return 'Percentage (X)';
      case 'isWhatPercent':
        return 'Value (X)';
      case 'percentageChange':
        return 'Initial Value (X)';
      case 'percentageDifference':
        return 'Value 1 (X)';
      case 'reversePercent':
        return 'Percentage Change (X)';
      default:
        return 'Value 1';
    }
  }

  String get _label2 {
    switch (_mode) {
      case 'percentOf':
        return 'Total Value (Y)';
      case 'isWhatPercent':
        return 'Total Value (Y)';
      case 'percentageChange':
        return 'Final Value (Y)';
      case 'percentageDifference':
        return 'Value 2 (Y)';
      case 'reversePercent':
        return 'Final Value (Y)';
      default:
        return 'Value 2';
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result;
    String? errorMessage;

    try {
      final v1 = double.tryParse(_val1);
      final v2 = double.tryParse(_val2);

      if (v1 != null && v2 != null) {
        result = FinanceEngine.calculatePercentage(
          mode: _mode,
          val1: v1,
          val2: v2,
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    final modeChips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('X% of Y'),
            selected: _mode == 'percentOf',
            onSelected: (_) => setState(() => _mode = 'percentOf'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('X is what % of Y'),
            selected: _mode == 'isWhatPercent',
            onSelected: (_) => setState(() => _mode = 'isWhatPercent'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('% Change (X → Y)'),
            selected: _mode == 'percentageChange',
            onSelected: (_) => setState(() => _mode = 'percentageChange'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('% Difference'),
            selected: _mode == 'percentageDifference',
            onSelected: (_) => setState(() => _mode = 'percentageDifference'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Reverse %'),
            selected: _mode == 'reversePercent',
            onSelected: (_) => setState(() => _mode = 'reversePercent'),
          ),
        ],
      ),
    );

    return ToolPageScaffold(
      toolId: 'percentage',
      title: 'Percentage Calculator',
      description: 'Compute percent of values, rate changes, differences, and reverse percentages.',
      icon: Icons.percent_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text(
          'Calculation Mode:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        modeChips,
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: _label1,
          value: _val1,
          onChanged: (val) => setState(() => _val1 = val),
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: _label2,
          value: _val2,
          onChanged: (val) => setState(() => _val2 = val),
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
            label: 'Calculated Result',
            value:
                _mode == 'isWhatPercent' ||
                    _mode == 'percentageChange' ||
                    _mode == 'percentageDifference'
                ? '${(result['result'] as double).toStringAsFixed(2)}%'
                : (result['result'] as double).toStringAsFixed(2),
            secondaryLabel: 'Summary',
            secondaryValue: result['summary'],
            formula: result['formula'],
            substitution: result['substitution'],
            onReset: _reset,
            onShare: () => _logHistory(result!),
          ),
        ],
      ],
    );
  }
}
