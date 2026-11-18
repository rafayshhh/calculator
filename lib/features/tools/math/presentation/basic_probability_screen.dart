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

class BasicProbabilityScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const BasicProbabilityScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<BasicProbabilityScreen> createState() =>
      _BasicProbabilityScreenState();
}

class _BasicProbabilityScreenState
    extends ConsumerState<BasicProbabilityScreen> {
  String _favorable = '3';
  String _total = '12';

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _favorable = data['favorable'] ?? '3';
        _total = data['total'] ?? '12';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final fav = double.tryParse(_favorable);
    final tot = double.tryParse(_total);

    if (fav == null || tot == null) {
      setState(() {
        _results = null;
        _error = 'Please enter valid numbers';
      });
      return;
    }

    try {
      final res = StatisticsEngine.calculateProbability(fav, tot);
      setState(() {
        _results = res;
        _error = null;
      });

      final stateJson = jsonEncode({'favorable': _favorable, 'total': _total});
      final probStr = (res['probability'] as double).toStringAsFixed(4);
      final pctStr = (res['percentage'] as double).toStringAsFixed(2);
      ref
          .read(historyProvider.notifier)
          .add(
            'Probability: $_favorable / $_total',
            'P(A) = $probStr ($pctStr%)',
            toolRoute: '/tools/statistics/probability',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _results = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _favorable = '3';
      _total = '12';
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
    final textSecondaryColor = isDark
        ? KColors.textSecondaryDark
        : KColors.textSecondaryLight;

    final probFormatted = _results?['probability'] != null
        ? (_results!['probability'] as double)
              .toStringAsFixed(4)
              .replaceAll(RegExp(r'\.?0+$'), '')
        : '0';
    final pctFormatted = _results?['percentage'] != null
        ? '${(_results!['percentage'] as double).toStringAsFixed(2)}%'
        : '0%';
    final compFormatted = _results?['complement'] != null
        ? (_results!['complement'] as double)
              .toStringAsFixed(4)
              .replaceAll(RegExp(r'\.?0+$'), '')
        : '0';

    return FinancialToolScaffold(
      title: 'Basic Probability',
      description: 'Calculate likelihood of events, complements, and odds',
      icon: Icons.casino_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Favorable Outcomes (n(A))',
          value: _favorable,
          onChanged: (val) {
            _favorable = val;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Total Possible Outcomes (n(S))',
          value: _total,
          onChanged: (val) {
            _total = val;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(label: 'Error', value: _error!, isError: true)
        else if (_results != null) ...[
          ResultDisplayCard(
            label: 'Event Probability P(A)',
            value: '$probFormatted ($pctFormatted)',
            secondaryLabel: 'Complement P(A\')',
            secondaryValue: compFormatted,
            bottomContent: Padding(
              padding: const EdgeInsets.only(top: KSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Odds in Favor:',
                    style: TextStyle(color: textSecondaryColor, fontSize: 14),
                  ),
                  Text(
                    '${_results!['oddsInFavor']}',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Probability Rule',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'P(A) = Favorable / Total  |  P(A\') = 1 - P(A)',
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
