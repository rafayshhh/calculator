import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/statistics_engine.dart';

class CombinationsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CombinationsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CombinationsScreen> createState() => _CombinationsScreenState();
}

class _CombinationsScreenState extends ConsumerState<CombinationsScreen> {
  String _n = '10';
  String _r = '4';

  int? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _n = data['n'] ?? '10';
        _r = data['r'] ?? '4';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final nVal = int.tryParse(_n);
    final rVal = int.tryParse(_r);

    if (nVal == null || rVal == null) {
      setState(() {
        _result = null;
        _error = 'Please enter valid non-negative integers';
      });
      return;
    }

    try {
      final res = StatisticsEngine.combinations(nVal, rVal);
      setState(() {
        _result = res;
        _error = null;
      });

      final stateJson = jsonEncode({'n': _n, 'r': _r});
      ref
          .read(historyProvider.notifier)
          .add(
            'Combinations: C($_n, $_r)',
            '$_n C $_r = $res',
            toolRoute: '/tools/statistics/combinations',
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
      _n = '10';
      _r = '4';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimaryColor = isDark
        ? KColors.textPrimaryDark
        : KColors.textPrimaryLight;

    final formattedResult = _result != null ? '$_result' : '0';

    return FinancialToolScaffold(
      title: 'Combinations (nCr)',
      description: 'Unordered subsets of r elements chosen from n items',
      icon: Icons.grain_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Total Items (n)',
          value: _n,
          onChanged: (val) {
            _n = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Items Chosen (r)',
          value: _r,
          onChanged: (val) {
            _r = val;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(label: 'Error', value: _error!, isError: true)
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Total Combinations (${_n}C$_r)',
            value: formattedResult,
            secondaryLabel: 'Order Sensitivity',
            secondaryValue: 'Order Does Not Matter',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Combination Formula',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'nCr = n! / (r! × (n - r)!)  →  $_n! / ($_r! × (${(int.tryParse(_n) ?? 0) - (int.tryParse(_r) ?? 0)}! ) = $formattedResult',
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
