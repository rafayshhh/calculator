import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/k_stat_row.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/advanced_math_engine.dart';

class SequenceCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SequenceCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SequenceCalculatorScreen> createState() => _SequenceCalculatorScreenState();
}

class _SequenceCalculatorScreenState extends ConsumerState<SequenceCalculatorScreen> {
  bool _isGeometric = false;
  String _firstTerm = '2.0';
  String _diffRatio = '3.0';
  String _termN = '10';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a1 = double.tryParse(_firstTerm);
    final d = double.tryParse(_diffRatio);
    final n = int.tryParse(_termN);
    if (a1 == null || d == null || n == null || n <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter valid numbers and positive integer n';
      });
      return;
    }

    try {
      final res = AdvancedMathEngine.calculateSequence(a1: a1, diffOrRatio: d, n: n, isGeometric: _isGeometric);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'isGeometric': _isGeometric, 'a1': _firstTerm, 'd': _diffRatio, 'n': _termN});
      ref.read(historyProvider.notifier).add(
        'Sequence: ${_isGeometric ? "Geometric" : "Arithmetic"} a₁=$_firstTerm, n=$_termN',
        'a_n=${(res['nthTerm'] as double).toStringAsFixed(2)}',
        toolRoute: '/tools/math/advanced/sequence',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _isGeometric = false;
      _firstTerm = '2.0';
      _diffRatio = '3.0';
      _termN = '10';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'sequence_calculator',
      title: 'Sequence & Progressions',
      description: 'Compute nth term and series sum for arithmetic and geometric progressions.',
      icon: Icons.auto_stories_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Arithmetic (AP)')),
            ButtonSegment(value: true, label: Text('Geometric (GP)')),
          ],
          selected: {_isGeometric},
          onSelectionChanged: (s) {
            setState(() => _isGeometric = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'First Term (a₁)',
          value: _firstTerm,
          onChanged: (v) {
            _firstTerm = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: _isGeometric ? 'Common Ratio (r)' : 'Common Difference (d)',
          value: _diffRatio,
          onChanged: (v) {
            _diffRatio = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Term Index (n)',
          value: _termN,
          onChanged: (v) {
            _termN = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Nth Term (a_n)',
            value: (_result!['nthTerm'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Sum of n Terms (S_n)',
            secondaryValue: (_result!['sum'] as double).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: _isGeometric ? 'a_n = a₁ × r^(n-1)' : 'a_n = a₁ + (n-1)d',
            substitution: 'S_n = ${(_result!['sum'] as double).toStringAsFixed(4)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
