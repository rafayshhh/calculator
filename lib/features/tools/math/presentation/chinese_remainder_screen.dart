import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class ChineseRemainderScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ChineseRemainderScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ChineseRemainderScreen> createState() => _ChineseRemainderScreenState();
}

class _ChineseRemainderScreenState extends ConsumerState<ChineseRemainderScreen> {
  String _r1 = '2';
  String _m1 = '3';
  String _r2 = '3';
  String _m2 = '5';
  String _r3 = '2';
  String _m3 = '7';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _r1 = map['r1']?.toString() ?? '2';
        _m1 = map['m1']?.toString() ?? '3';
        _r2 = map['r2']?.toString() ?? '3';
        _m2 = map['m2']?.toString() ?? '5';
        _r3 = map['r3']?.toString() ?? '2';
        _m3 = map['m3']?.toString() ?? '7';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _r1 = '2';
      _m1 = '3';
      _r2 = '3';
      _m2 = '5';
      _r3 = '2';
      _m3 = '7';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'r1': _r1, 'm1': _m1, 'r2': _r2, 'm2': _m2, 'r3': _r3, 'm3': _m3});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/chinese_remainder',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final r1 = int.tryParse(_r1) ?? 0;
    final m1 = int.tryParse(_m1) ?? 1;
    final r2 = int.tryParse(_r2) ?? 0;
    final m2 = int.tryParse(_m2) ?? 1;
    final r3 = int.tryParse(_r3) ?? 0;
    final m3 = int.tryParse(_m3) ?? 1;
    final res = NumberTheoryEngine.chineseRemainderTheorem([r1, r2, r3], [m1, m2, m3]);
    final solStr = res['solutionString'] as String? ?? res['error'] as String;

    return ToolPageScaffold(
      title: 'Chinese Remainder Theorem (CRT)',
      description: 'Solves system of simultaneous congruences x ≡ r_i (mod m_i)',
      formula: 'x ≡ ∑ r_i M_i y_i (mod M),  where M = ∏ m_i',
      onReset: _reset,
      onSave: () => _logHistory('CRT: [r1=$r1 mod $m1, r2=$r2 mod $m2, r3=$r3 mod $m3]', '$solStr'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$solStr',
          details: 'Result:\n$solStr\nTotal Modulo M: ${res['modulo'] ?? 'N/A'}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Remainder r₁',
            initialValue: _r1,
            onChanged: (val) => setState(() => _r1 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Modulus m₁',
            initialValue: _m1,
            onChanged: (val) => setState(() => _m1 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Remainder r₂',
            initialValue: _r2,
            onChanged: (val) => setState(() => _r2 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Modulus m₂',
            initialValue: _m2,
            onChanged: (val) => setState(() => _m2 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Remainder r₃',
            initialValue: _r3,
            onChanged: (val) => setState(() => _r3 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Modulus m₃',
            initialValue: _m3,
            onChanged: (val) => setState(() => _m3 = val),
          ),
      ],
    );
  }
}
