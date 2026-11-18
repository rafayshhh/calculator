import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class DiophantineEquationScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DiophantineEquationScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DiophantineEquationScreen> createState() => _DiophantineEquationScreenState();
}

class _DiophantineEquationScreenState extends ConsumerState<DiophantineEquationScreen> {
  String _a = '15';
  String _b = '21';
  String _c = '6';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '15';
        _b = map['b']?.toString() ?? '21';
        _c = map['c']?.toString() ?? '6';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '15';
      _b = '21';
      _c = '6';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b, 'c': _c});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/diophantine_equation',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = int.tryParse(_a) ?? 1;
    final b = int.tryParse(_b) ?? 1;
    final c = int.tryParse(_c) ?? 1;
    final res = NumberTheoryEngine.solveDiophantine(a, b, c);
    final hasSol = res['hasSolution'] as bool? ?? false;
    final gcd = res['gcd'] as int? ?? 1;
    final genStr = hasSol ? res['generalSolution'] as String : res['error'] as String;

    return ToolPageScaffold(
      title: 'Linear Diophantine Equation',
      description: 'Finds integer solutions (x, y) to ax + by = c using Euclidean algorithm',
      formula: 'ax + by = c  has solutions iff gcd(a, b) | c',
      onReset: _reset,
      onSave: () => _logHistory('$a x + $b y = $c', 'Diophantine result'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'gcd(a, b) = $gcd',
          details: 'Has Solution: $hasSol\ngcd($a, $b) = $gcd\nSolution:\n$genStr',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Coefficient a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Coefficient b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Constant c',
            initialValue: _c,
            onChanged: (val) => setState(() => _c = val),
          ),
      ],
    );
  }
}
