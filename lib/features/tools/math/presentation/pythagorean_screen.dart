import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/math_utilities_engine.dart';

class PythagoreanScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PythagoreanScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PythagoreanScreen> createState() => _PythagoreanScreenState();
}

class _PythagoreanScreenState extends ConsumerState<PythagoreanScreen> {
  int _targetIndex = 2; // 0: solve a, 1: solve b, 2: solve c (hypotenuse)
  String _valA = '3.0';
  String _valB = '4.0';
  String _valC = '5.0';
  double? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = double.tryParse(_valA);
    final b = double.tryParse(_valB);
    final c = double.tryParse(_valC);

    try {
      double r;
      if (_targetIndex == 2) {
        if (a == null || b == null || a <= 0 || b <= 0) throw ArgumentError('Legs a and b must be positive');
        r = MathUtilitiesEngine.solvePythagorean(a: a, b: b);
      } else if (_targetIndex == 0) {
        if (b == null || c == null || b <= 0 || c <= b) throw ArgumentError('Hypotenuse c must exceed leg b');
        r = MathUtilitiesEngine.solvePythagorean(b: b, c: c);
      } else {
        if (a == null || c == null || a <= 0 || c <= a) throw ArgumentError('Hypotenuse c must exceed leg a');
        r = MathUtilitiesEngine.solvePythagorean(a: a, c: c);
      }

      setState(() {
        _error = null;
        _result = r;
      });

      final stateJson = jsonEncode({'targetIndex': _targetIndex, 'a': _valA, 'b': _valB, 'c': _valC});
      ref.read(historyProvider.notifier).add(
        'Pythagorean: ${_targetIndex == 2 ? "Hypotenuse c" : _targetIndex == 0 ? "Leg a" : "Leg b"}',
        r.toStringAsFixed(2),
        toolRoute: '/tools/math/pythagorean',
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
      _targetIndex = 2;
      _valA = '3.0';
      _valB = '4.0';
      _valC = '5.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final targetLabel = _targetIndex == 2 ? 'Hypotenuse (c)' : _targetIndex == 0 ? 'Leg (a)' : 'Leg (b)';

    return ToolPageScaffold(
      toolId: 'pythagorean',
      title: 'Pythagorean Theorem',
      description: 'Solve missing sides of right triangles using a² + b² = c².',
      icon: Icons.change_history_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Solve a')),
            ButtonSegment(value: 1, label: Text('Solve b')),
            ButtonSegment(value: 2, label: Text('Solve c')),
          ],
          selected: {_targetIndex},
          onSelectionChanged: (s) {
            setState(() => _targetIndex = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_targetIndex != 0)
          PremiumNumericField(
            label: 'Leg (a)',
            value: _valA,
            onChanged: (v) {
              _valA = v;
              _calculate();
            },
          ),
        if (_targetIndex != 1) ...[
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Leg (b)',
            value: _valB,
            onChanged: (v) {
              _valB = v;
              _calculate();
            },
          ),
        ],
        if (_targetIndex != 2) ...[
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Hypotenuse (c)',
            value: _valC,
            onChanged: (v) {
              _valC = v;
              _calculate();
            },
          ),
        ],
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: targetLabel,
            value: _result!.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: 'a² + b² = c²',
            substitution: '$targetLabel = ${_result!.toStringAsFixed(4)}',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
