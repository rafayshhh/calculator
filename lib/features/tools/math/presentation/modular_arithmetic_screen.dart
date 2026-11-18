import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class ModularArithmeticScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ModularArithmeticScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ModularArithmeticScreen> createState() => _ModularArithmeticScreenState();
}

class _ModularArithmeticScreenState extends ConsumerState<ModularArithmeticScreen> {
  String _a = '17';
  String _b = '5';
  String _m = '26';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '17';
        _b = map['b']?.toString() ?? '5';
        _m = map['m']?.toString() ?? '26';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '17';
      _b = '5';
      _m = '26';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b, 'm': _m});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/modular_arithmetic',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a = int.tryParse(_a) ?? 1;
    final b = int.tryParse(_b) ?? 1;
    final m = int.tryParse(_m) ?? 2;
    final res = NumberTheoryEngine.modularArithmetic(a, b, m);
    final addM = res['addMod'] ?? 0;
    final mulM = res['mulMod'] ?? 0;
    final expM = res['expMod'] ?? 0;
    final invStr = res['inverseString'] as String? ?? 'N/A';

    return ToolPageScaffold(
      title: 'Modular Arithmetic & Inverses',
      description: 'Computes (a ± b) mod m, (a * b) mod m, a^b mod m, and inverse a⁻¹ mod m',
      formula: 'a · x ≡ 1 (mod m)  via Extended Euclidean Algorithm',
      onReset: _reset,
      onSave: () => _logHistory('$a · $b mod $m', '$mulM, inv=$invStr'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '(a · b) mod m = $mulM',
          details: 'a + b mod m: $addM\na * b mod m: $mulM\na^b mod m: $expM\nModular Inverse of a (mod m): $invStr',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Operand a',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Operand b',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Modulus m',
            initialValue: _m,
            onChanged: (val) => setState(() => _m = val),
          ),
      ],
    );
  }
}
