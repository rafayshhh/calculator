import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/financial_engine.dart';

class VatScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const VatScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<VatScreen> createState() => _VatScreenState();
}

class _VatScreenState extends ConsumerState<VatScreen> {
  String _amount = '100.0';
  String _rate = '20.0';
  bool _isInclusive = false;
  Map<String, double>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = double.tryParse(_amount);
    final r = double.tryParse(_rate);
    if (a == null || r == null || a < 0 || r < 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative numbers';
      });
      return;
    }

    try {
      final res = FinancialEngine.calculateTax(amount: a, taxRatePercent: r, isInclusive: _isInclusive);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'amount': _amount, 'rate': _rate, 'isInclusive': _isInclusive});
      ref.read(historyProvider.notifier).add(
        'VAT: \$$_amount @ $_rate% ${_isInclusive ? "inclusive" : "exclusive"}',
        '\$${res['total']!.toStringAsFixed(2)}',
        toolRoute: '/tools/financial/vat',
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
      _amount = '100.0';
      _rate = '20.0';
      _isInclusive = false;
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'financial_vat',
      title: 'Value Added Tax (VAT)',
      description: 'Compute inclusive and exclusive Value Added Tax.',
      icon: Icons.local_activity_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Add VAT (Exclusive)')),
            ButtonSegment(value: true, label: Text('Extract VAT (Inclusive)')),
          ],
          selected: {_isInclusive},
          onSelectionChanged: (s) {
            setState(() => _isInclusive = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: _isInclusive ? 'Gross Amount (with VAT)' : 'Net Amount (excluding VAT)',
          prefix: '\$',
          value: _amount,
          onChanged: (v) {
            _amount = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'VAT Rate',
          suffix: '%',
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
        else if (_result != null) ...[
          ResultDisplayCard(
            label: _isInclusive ? 'Net Amount (Excl. VAT)' : 'Gross Amount (Incl. VAT)',
            value: '\$${_result!['total']!.toStringAsFixed(2)}',
            secondaryLabel: 'VAT Element',
            secondaryValue: '\$${_result!['taxAmount']!.toStringAsFixed(2)}',
            formula: _isInclusive ? 'Net = Gross / (1 + Rate)' : 'Gross = Net × (1 + Rate)',
            substitution: 'Total = \$${_result!['total']!.toStringAsFixed(2)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
