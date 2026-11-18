import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class EulerTotientScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const EulerTotientScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<EulerTotientScreen> createState() => _EulerTotientScreenState();
}

class _EulerTotientScreenState extends ConsumerState<EulerTotientScreen> {
  String _n = '36';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _n = map['n']?.toString() ?? '36';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _n = '36';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'n': _n});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/euler_totient',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final n = int.tryParse(_n) ?? 1;
    final res = NumberTheoryEngine.eulerTotient(n);
    final phi = res['totient'] as int? ?? 1;
    final frac = res['coprimesFraction'] as double? ?? 1.0;

    return ToolPageScaffold(
      title: "Euler's Totient Function φ(n)",
      description: 'Counts positive integers up to n that are relatively prime to n',
      formula: 'φ(n) = n · ∏_{p | n} (1 - 1/p)',
      onReset: _reset,
      onSave: () => _logHistory('φ($n)', '$phi'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'φ($n) = $phi',
          details: 'Totient Count: $phi\nFraction Coprime: ${(frac * 100).toStringAsFixed(1)}%\nPrime Divisors: ${res['distinctPrimes'] ?? []}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Positive Integer n',
            initialValue: _n,
            onChanged: (val) => setState(() => _n = val),
          ),
      ],
    );
  }
}
