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

class CurrencyScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CurrencyScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  String _amount = '100.0';
  String _rate = '1.08'; // EUR to USD or vice versa
  String _sourceCur = 'EUR';
  String _targetCur = 'USD';
  double? _converted;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = double.tryParse(_amount);
    final r = double.tryParse(_rate);
    if (a == null || r == null || a < 0 || r <= 0) {
      setState(() {
        _converted = null;
        _error = 'Please enter valid non-negative amount and positive exchange rate';
      });
      return;
    }

    try {
      final res = FinanceEngine.convertCurrency(amount: a, exchangeRate: r);
      setState(() {
        _error = null;
        _converted = res['convertedAmount'] as double;
      });

      final stateJson = jsonEncode({'amount': _amount, 'rate': _rate, 'src': _sourceCur, 'target': _targetCur});
      ref.read(historyProvider.notifier).add(
        'Currency: $_amount $_sourceCur -> $_targetCur',
        '${_converted!.toStringAsFixed(2)} $_targetCur',
        toolRoute: '/tools/finance/currency',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _converted = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _amount = '100.0';
      _rate = '1.08';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'currency',
      title: 'Currency Converter',
      description: 'Convert between currencies using customized or live exchange rates.',
      icon: Icons.currency_exchange_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Amount to Convert',
          value: _amount,
          onChanged: (v) {
            _amount = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Exchange Rate',
          suffix: 'Rate',
          value: _rate,
          onChanged: (v) {
            _rate = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_converted != null) ...[
          ResultDisplayCard(
            label: 'Converted Amount',
            value: '${_converted!.toStringAsFixed(2)} $_targetCur',
            secondaryLabel: 'Base Value',
            secondaryValue: '$_amount $_sourceCur',
            formula: 'Target = Base × ExchangeRate',
            substitution: '$_amount × $_rate = ${_converted!.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
