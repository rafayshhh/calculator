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

class TipSplitScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TipSplitScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TipSplitScreen> createState() => _TipSplitScreenState();
}

class _TipSplitScreenState extends ConsumerState<TipSplitScreen> {
  String _bill = '85.50';
  String _tipPercent = '18.0';
  String _people = '3';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final b = double.tryParse(_bill);
    final t = double.tryParse(_tipPercent);
    final p = int.tryParse(_people);
    if (b == null || t == null || p == null || b < 0 || p <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative bill and at least 1 person';
      });
      return;
    }

    try {
      final res = FinanceEngine.calculateTipAndSplit(billAmount: b, tipPercent: t, numberOfPeople: p);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'bill': _bill, 'tipPercent': _tipPercent, 'people': _people});
      ref.read(historyProvider.notifier).add(
        'Tip Split: \$$_bill, $_tipPercent% tip / $_people people',
        '\$${(res['totalPerPerson'] as double).toStringAsFixed(2)}/person',
        toolRoute: '/tools/finance/tip_split',
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
      _bill = '85.50';
      _tipPercent = '18.0';
      _people = '3';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'tip_split',
      title: 'Tip & Bill Splitter',
      description: 'Calculate gratuity amounts and divide dining bills evenly across party members.',
      icon: Icons.receipt_long_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Total Bill Amount',
          prefix: '\$',
          value: _bill,
          onChanged: (v) {
            _bill = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Tip Percentage',
          suffix: '%',
          value: _tipPercent,
          onChanged: (v) {
            _tipPercent = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Number of People',
          suffix: 'guests',
          value: _people,
          onChanged: (v) {
            _people = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Total Due Per Person',
            value: '\$${(_result!['totalPerPerson'] as double).toStringAsFixed(2)}',
            secondaryLabel: 'Total Bill with Tip',
            secondaryValue: '\$${(_result!['totalBill'] as double).toStringAsFixed(2)}',
            formula: 'Total = Bill × (1 + Tip%) / People',
            substitution: '\$$_bill + $_tipPercent% tip / $_people people = \$${(_result!['totalPerPerson'] as double).toStringAsFixed(2)} each',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
