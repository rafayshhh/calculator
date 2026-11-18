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

class PrimeCheckerScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PrimeCheckerScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PrimeCheckerScreen> createState() => _PrimeCheckerScreenState();
}

class _PrimeCheckerScreenState extends ConsumerState<PrimeCheckerScreen> {
  String _num = '60';

  bool? _isPrime;
  List<int>? _factors;
  String? _exponentialForm;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _num = data['num'] ?? '60';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final n = int.tryParse(_num);

    if (n == null) {
      setState(() {
        _isPrime = null;
        _factors = null;
        _exponentialForm = null;
        _error = 'Please enter a valid integer';
      });
      return;
    }

    if (n > 1000000000) {
      setState(() {
        _isPrime = null;
        _factors = null;
        _exponentialForm = null;
        _error = 'Number too large (maximum 1,000,000,000)';
      });
      return;
    }

    try {
      final isP = MathAdvancedEngine.isPrime(n);
      final factorsList = MathAdvancedEngine.primeFactors(n);
      final expForm = MathAdvancedEngine.formatExponentialFactorization(
        factorsList,
      );

      setState(() {
        _isPrime = isP;
        _factors = factorsList;
        _exponentialForm = expForm;
        _error = null;
      });

      final stateJson = jsonEncode({'num': _num});
      ref
          .read(historyProvider.notifier)
          .add(
            'Prime & Factors of $_num',
            isP ? 'Prime Number' : 'Composite ($expForm)',
            toolRoute: '/tools/math/prime',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _isPrime = null;
        _factors = null;
        _exponentialForm = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _num = '60';
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
      title: 'Prime & Factorization',
      description: 'Check primality and find prime factorization',
      icon: Icons.filter_1_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Integer n',
          value: _num,
          onChanged: (val) {
            _num = val;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(label: 'Error', value: _error!, isError: true)
        else if (_isPrime != null) ...[
          ResultDisplayCard(
            label: 'Primality',
            value: _isPrime! ? 'Prime' : 'Composite',
            secondaryLabel: 'Exponential Form',
            secondaryValue: _exponentialForm ?? 'None',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prime Factor Breakdown',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _factors != null && _factors!.isNotEmpty
                      ? _factors!.join(' × ')
                      : 'No prime factors (n ≤ 1)',
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
