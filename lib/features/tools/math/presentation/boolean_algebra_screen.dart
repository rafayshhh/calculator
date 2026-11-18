import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';


class BooleanAlgebraScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const BooleanAlgebraScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<BooleanAlgebraScreen> createState() => _BooleanAlgebraScreenState();
}

class _BooleanAlgebraScreenState extends ConsumerState<BooleanAlgebraScreen> {
  String _a = '1';
  String _b = '0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a = map['a']?.toString() ?? '1';
        _b = map['b']?.toString() ?? '0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a = '1';
      _b = '0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a': _a, 'b': _b});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/boolean_algebra',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final inA = (int.tryParse(_a) ?? 0) != 0;
    final inB = (int.tryParse(_b) ?? 0) != 0;
    final andRes = inA && inB;
    final orRes = inA || inB;
    final xorRes = inA ^ inB;
    final nandRes = !andRes;
    final norRes = !orRes;
    final notA = !inA;

    return ToolPageScaffold(
      title: 'Boolean Algebra & Logic Gates',
      description: 'Computes truth table outputs for AND, OR, XOR, NAND, NOR, and XNOR',
      formula: 'A ∧ B,  A ∨ B,  A ⊕ B,  ¬(A ∧ B)',
      onReset: _reset,
      onSave: () => _logHistory('Boolean A=$inA, B=$inB', 'AND=${andRes ? 1 : 0}, OR=${orRes ? 1 : 0}, XOR=${xorRes ? 1 : 0}'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'A ∧ B = ${andRes ? 1 : 0}, A ∨ B = ${orRes ? 1 : 0}',
          details: 'A: ${inA ? 1 : 0}, B: ${inB ? 1 : 0}\nAND: ${andRes ? 1 : 0}\nOR: ${orRes ? 1 : 0}\nXOR: ${xorRes ? 1 : 0}\nNAND: ${nandRes ? 1 : 0}\nNOR: ${norRes ? 1 : 0}\nNOT A: ${notA ? 1 : 0}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Boolean Input A (0 or 1)',
            initialValue: _a,
            onChanged: (val) => setState(() => _a = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Boolean Input B (0 or 1)',
            initialValue: _b,
            onChanged: (val) => setState(() => _b = val),
          ),
      ],
    );
  }
}
