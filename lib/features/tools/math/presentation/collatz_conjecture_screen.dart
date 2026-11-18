import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/number_theory_engine.dart';

class CollatzConjectureScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CollatzConjectureScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CollatzConjectureScreen> createState() => _CollatzConjectureScreenState();
}

class _CollatzConjectureScreenState extends ConsumerState<CollatzConjectureScreen> {
  String _n = '27';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _n = map['n']?.toString() ?? '27';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _n = '27';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'n': _n});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/collatz_conjecture',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final n = int.tryParse(_n) ?? 1;
    final res = NumberTheoryEngine.collatzSequence(n);
    final stopTime = res['stoppingTime'] as int? ?? 0;
    final peak = res['peakValue'] as int? ?? 0;
    final seq = res['sequence'] as List<int>? ?? [];
    final preview = seq.take(8).join(' -> ') + (seq.length > 8 ? ' ... -> 1' : '');

    return ToolPageScaffold(
      title: 'Collatz Conjecture (3n + 1)',
      description: 'Simulates hailstone sequence trajectory, stopping time, and peak altitude',
      formula: 'f(n) = n/2 (even)  or  3n+1 (odd)',
      onReset: _reset,
      onSave: () => _logHistory('Collatz($n)', 'Steps: $stopTime, Peak: $peak'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Stopping Time: $stopTime steps',
          details: 'Peak Value: $peak\nTotal Steps: $stopTime\nTrajectory Preview:\n$preview',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Starting Integer n',
            initialValue: _n,
            onChanged: (val) => setState(() => _n = val),
          ),
      ],
    );
  }
}
