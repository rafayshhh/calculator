import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/math_utilities_engine.dart';

class FractionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const FractionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<FractionScreen> createState() => _FractionScreenState();
}

class _FractionScreenState extends ConsumerState<FractionScreen> {
  String _num = '42';
  String _denom = '56';
  FractionResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final n = int.tryParse(_num);
    final d = int.tryParse(_denom);
    if (n == null || d == null || d == 0) {
      setState(() {
        _result = null;
        _error = 'Please enter integer numerator and non-zero denominator';
      });
      return;
    }

    try {
      final res = MathUtilitiesEngine.simplifyFraction(n, d);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'num': _num, 'denom': _denom});
      ref.read(historyProvider.notifier).add(
        'Fraction: $_num / $_denom',
        '${res.numerator}/${res.denominator}',
        toolRoute: '/tools/math/fraction',
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
      _num = '42';
      _denom = '56';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'fraction',
      title: 'Fraction Simplifier',
      description: 'Reduce fractions to lowest terms and convert to mixed numerals and decimals.',
      icon: Icons.call_split_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Numerator',
                value: _num,
                onChanged: (v) {
                  _num = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Denominator',
                value: _denom,
                onChanged: (v) {
                  _denom = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Simplified Fraction',
            value: '${_result!.numerator} / ${_result!.denominator}',
            secondaryLabel: 'Decimal Value',
            secondaryValue: _result!.decimalValue.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: 'Reduced by GCD',
            substitution: '$_num / $_denom = ${_result!.numerator} / ${_result!.denominator}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Proper Fraction', value: _result!.isProper ? 'Yes' : 'No (Improper)'),
          if (_result!.wholeNumber != null) ...[
            const SizedBox(height: KSpacing.xs),
            KStatRow(label: 'Mixed Number Representation', value: '${_result!.wholeNumber} ${_result!.numerator % _result!.denominator}/${_result!.denominator}'),
          ],
        ],
      ],
    );
  }
}
