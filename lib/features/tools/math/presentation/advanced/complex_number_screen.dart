import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/advanced_math_engine.dart';

class ComplexNumberScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ComplexNumberScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ComplexNumberScreen> createState() => _ComplexNumberScreenState();
}

class _ComplexNumberScreenState extends ConsumerState<ComplexNumberScreen> {
  String _r1 = '3.0';
  String _i1 = '4.0';
  String _r2 = '1.0';
  String _i2 = '-2.0';
  String _op = '+';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final r1 = double.tryParse(_r1);
    final i1 = double.tryParse(_i1);
    final r2 = double.tryParse(_r2);
    final i2 = double.tryParse(_i2);
    if (r1 == null || i1 == null || r2 == null || i2 == null) {
      setState(() {
        _result = null;
        _error = 'Please enter valid real and imaginary parts';
      });
      return;
    }

    try {
      final res = AdvancedMathEngine.calculateComplex(r1: r1, i1: i1, r2: r2, i2: i2, op: _op);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'r1': _r1, 'i1': _i1, 'r2': _r2, 'i2': _i2, 'op': _op});
      ref.read(historyProvider.notifier).add(
        'Complex: ($r1 + ${i1}i) $_op ($r2 + ${i2}i)',
        res['formatted'] as String,
        toolRoute: '/tools/math/advanced/complex_number',
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
      _r1 = '3.0';
      _i1 = '4.0';
      _r2 = '1.0';
      _i2 = '-2.0';
      _op = '+';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'complex_number',
      title: 'Complex Numbers',
      description: 'Compute complex arithmetic, magnitude (modulus), and phase argument.',
      icon: Icons.grain_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text('First Complex Number (z₁)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: KSpacing.xs),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'Real (Re₁)', value: _r1, onChanged: (v) { _r1 = v; _calculate(); })),
            const SizedBox(width: KSpacing.md),
            Expanded(child: PremiumNumericField(label: 'Imag (Im₁)', suffix: 'i', value: _i1, onChanged: (v) { _i1 = v; _calculate(); })),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Center(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '+', label: Text('+')),
              ButtonSegment(value: '-', label: Text('-')),
              ButtonSegment(value: '*', label: Text('×')),
              ButtonSegment(value: '/', label: Text('÷')),
            ],
            selected: {_op},
            onSelectionChanged: (s) {
              setState(() => _op = s.first);
              _calculate();
            },
          ),
        ),
        const SizedBox(height: KSpacing.md),
        const Text('Second Complex Number (z₂)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: KSpacing.xs),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'Real (Re₂)', value: _r2, onChanged: (v) { _r2 = v; _calculate(); })),
            const SizedBox(width: KSpacing.md),
            Expanded(child: PremiumNumericField(label: 'Imag (Im₂)', suffix: 'i', value: _i2, onChanged: (v) { _i2 = v; _calculate(); })),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Resulting Complex Number (z)',
            value: _result!['formatted'] as String,
            secondaryLabel: 'Modulus |z|',
            secondaryValue: (_result!['magnitude'] as double).toStringAsFixed(4),
            formula: 'z = a + bi',
            substitution: 'Phase Argument θ = ${(_result!['argumentDegrees'] as double).toStringAsFixed(2)}°',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
