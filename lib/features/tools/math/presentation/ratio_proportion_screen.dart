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
import '../domain/math_advanced_engine.dart';

class RatioProportionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const RatioProportionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<RatioProportionScreen> createState() =>
      _RatioProportionScreenState();
}

class _RatioProportionScreenState extends ConsumerState<RatioProportionScreen> {
  String _a = '2';
  String _b = '3';
  String _c = '8';
  String _d = ''; // Solving for d by default

  double? _resultD;
  String? _simplifiedRatio;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = data['a'] ?? '2';
        _b = data['b'] ?? '3';
        _c = data['c'] ?? '8';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final aVal = double.tryParse(_a);
    final bVal = double.tryParse(_b);
    final cVal = double.tryParse(_c);

    if (aVal == null || bVal == null || cVal == null) {
      setState(() {
        _resultD = null;
        _simplifiedRatio = null;
        _error = 'Please enter valid numbers for a, b, and c';
      });
      return;
    }

    try {
      final res = MathAdvancedEngine.solveProportion(a: aVal, b: bVal, c: cVal);

      // Simplify ratio a : b if they are integers
      String? simp;
      if (aVal == aVal.roundToDouble() && bVal == bVal.roundToDouble()) {
        final gcdVal = MathAdvancedEngine.gcd(aVal.toInt(), bVal.toInt());
        if (gcdVal > 0) {
          simp = '${aVal.toInt() ~/ gcdVal} : ${bVal.toInt() ~/ gcdVal}';
        }
      }

      setState(() {
        _resultD = res;
        _d = res.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
        _simplifiedRatio = simp;
        _error = null;
      });

      final stateJson = jsonEncode({'a': _a, 'b': _b, 'c': _c});
      ref
          .read(historyProvider.notifier)
          .add(
            'Proportion: $_a : $_b = $_c : x',
            'x = $_d',
            toolRoute: '/tools/math/ratio',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _resultD = null;
        _simplifiedRatio = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _a = '2';
      _b = '3';
      _c = '8';
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

    return FinancialToolScaffold(
      title: 'Ratio & Proportion',
      description: 'Solve proportions a : b = c : d and simplify ratios',
      icon: Icons.compare_arrows_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Ratio a',
                value: _a,
                onChanged: (val) {
                  _a = val;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Ratio b',
                value: _b,
                onChanged: (val) {
                  _b = val;
                  _calculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Value c',
                value: _c,
                onChanged: (val) {
                  _c = val;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solved x (d)',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: KSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KSpacing.md,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? KColors.surfaceElevatedDark
                          : KColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? KColors.glassBorderDark
                            : KColors.glassBorderLight,
                      ),
                    ),
                    child: Text(
                      _d.isEmpty ? '?' : _d,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(label: 'Error', value: _error!, isError: true)
        else if (_resultD != null) ...[
          ResultDisplayCard(
            label: 'Missing Variable (x)',
            value: 'x = $_d',
            secondaryLabel: 'Simplified Ratio (a:b)',
            secondaryValue: _simplifiedRatio ?? '$_a : $_b',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cross Multiplication Formula',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x = (b × c) / a  →  ($_b × $_c) / $_a = $_d',
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
