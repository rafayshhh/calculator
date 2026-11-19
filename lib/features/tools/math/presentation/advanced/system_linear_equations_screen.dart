import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/linear_algebra_engine.dart';

class SystemLinearEquationsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SystemLinearEquationsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SystemLinearEquationsScreen> createState() => _SystemLinearEquationsScreenState();
}

class _SystemLinearEquationsScreenState extends ConsumerState<SystemLinearEquationsScreen> {
  String _a1 = '2.0';
  String _b1 = '3.0';
  String _c1 = '13.0';
  String _a2 = '1.0';
  String _b2 = '-1.0';
  String _c2 = '-1.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a1 = map['a1']?.toString() ?? '2.0';
        _b1 = map['b1']?.toString() ?? '3.0';
        _c1 = map['c1']?.toString() ?? '13.0';
        _a2 = map['a2']?.toString() ?? '1.0';
        _b2 = map['b2']?.toString() ?? '-1.0';
        _c2 = map['c2']?.toString() ?? '-1.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a1 = '2.0';
      _b1 = '3.0';
      _c1 = '13.0';
      _a2 = '1.0';
      _b2 = '-1.0';
      _c2 = '-1.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'a1': _a1, 'b1': _b1, 'c1': _c1, 'a2': _a2, 'b2': _b2, 'c2': _c2});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/advanced/system_linear_equations',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final a1 = double.tryParse(_a1) ?? 0.0;
    final b1 = double.tryParse(_b1) ?? 0.0;
    final c1 = double.tryParse(_c1) ?? 0.0;
    final a2 = double.tryParse(_a2) ?? 0.0;
    final b2 = double.tryParse(_b2) ?? 0.0;
    final c2 = double.tryParse(_c2) ?? 0.0;
    final res = LinearAlgebraEngine.solveLinear2x2(a1, b1, c1, a2, b2, c2);
    final solStr = res['solutionString'] as String? ?? res['status'] as String;

    return ToolPageScaffold(
      title: 'Linear Systems Solver (2x2)',
      description: 'Solves simultaneous equations a₁x + b₁y = c₁, a₂x + b₂y = c₂',
      formula: "x = Dx / D,  y = Dy / D  (Cramer's Rule)",
      onReset: _reset,
      onSave: () => _logHistory('System 2x2: [$a1, $b1=$c1], [$a2, $b2=$c2]', '$solStr'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$solStr',
          details: 'Status: ${res['status']}\nD = ${res['D'] ?? 'N/A'}\nDx = ${res['Dx'] ?? 'N/A'}\nDy = ${res['Dy'] ?? 'N/A'}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'a₁',
            initialValue: _a1,
            onChanged: (val) => setState(() => _a1 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'b₁',
            initialValue: _b1,
            onChanged: (val) => setState(() => _b1 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'c₁',
            initialValue: _c1,
            onChanged: (val) => setState(() => _c1 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'a₂',
            initialValue: _a2,
            onChanged: (val) => setState(() => _a2 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'b₂',
            initialValue: _b2,
            onChanged: (val) => setState(() => _b2 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'c₂',
            initialValue: _c2,
            onChanged: (val) => setState(() => _c2 = val),
          ),
      ],
    );
  }
}
