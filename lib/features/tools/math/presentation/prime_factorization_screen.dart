import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class PrimeFactorizationScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PrimeFactorizationScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PrimeFactorizationScreen> createState() => _PrimeFactorizationScreenState();
}

class _PrimeFactorizationScreenState extends ConsumerState<PrimeFactorizationScreen> {
  String _n = '360';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _n = map['n']?.toString() ?? '360';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _n = '360';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'n': _n});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/prime_factorization',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final n = int.tryParse(_n) ?? 1;
    final res = NumberTheoryEngine.primeFactorization(n);
    final canon = res['canonicalString'] as String;
    final isP = res['isPrime'] as bool;
    final distinct = res['distinctPrimesCount'] as int;
    final total = res['totalPrimeFactors'] as int;

    return ToolPageScaffold(
      title: 'Prime Factorization & Multiplicity',
      description: 'Decomposes positive integers into canonical prime factors',
      formula: 'n = p₁^a₁ × p₂^a₂ × ... × p_k^a_k',
      onReset: _reset,
      onSave: () => _logHistory('Factorization of $n', '$canon'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$n = $canon',
          details: 'Prime Status: ${isP ? 'Prime' : 'Composite'}\nDistinct Primes: $distinct\nTotal Prime Factors: $total',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Integer n',
            initialValue: _n,
            onChanged: (val) => setState(() => _n = val),
          ),
      ],
    );
  }
}
