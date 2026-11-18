import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/math_utilities_engine.dart';

class QuadraticSolverScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const QuadraticSolverScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<QuadraticSolverScreen> createState() => _QuadraticSolverScreenState();
}

class _QuadraticSolverScreenState extends ConsumerState<QuadraticSolverScreen> {
  String _valA = '1.0';
  String _valB = '-5.0';
  String _valC = '6.0';
  Map<String, dynamic>? _result;
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
    if (a == null || b == null || c == null || a == 0) {
      setState(() {
        _result = null;
        _error = 'Coefficient a cannot be 0 in a quadratic equation';
      });
      return;
    }

    try {
      final res = MathUtilitiesEngine.solveQuadratic(a, b, c);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'a': _valA, 'b': _valB, 'c': _valC});
      ref.read(historyProvider.notifier).add(
        'Quadratic: ${_valA}x² + ${_valB}x + $_valC = 0',
        res['hasRealRoots'] == true ? 'x₁=${res['root1']}, x₂=${res['root2']}' : 'Complex Roots',
        toolRoute: '/tools/math/quadratic',
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
      _valA = '1.0';
      _valB = '-5.0';
      _valC = '6.0';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'quadratic',
      title: 'Quadratic Equation Solver',
      description: 'Solve quadratic equations ax² + bx + c = 0, discriminant Δ, and parabola vertex.',
      icon: Icons.ssid_chart_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Coefficient (a)',
                value: _valA,
                onChanged: (v) {
                  _valA = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Coefficient (b)',
                value: _valB,
                onChanged: (v) {
                  _valB = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Constant (c)',
                value: _valC,
                onChanged: (v) {
                  _valC = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: _result!['hasRealRoots'] == true ? 'Real Roots (x₁, x₂)' : 'Root Status',
            value: _result!['hasRealRoots'] == true
                ? 'x₁ = ${_result!['root1']}, x₂ = ${_result!['root2']}'
                : 'No Real Roots (Complex Conjugate)',
            secondaryLabel: 'Discriminant (Δ)',
            secondaryValue: '${_result!['discriminant']}',
            formula: 'x = (-b ± √(b² - 4ac)) / (2a)',
            substitution: 'Vertex: (${_result!['vertexX']}, ${_result!['vertexY']})',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Parabola Vertex', value: '(${_result!['vertexX']}, ${_result!['vertexY']})'),
        ],
      ],
    );
  }
}
