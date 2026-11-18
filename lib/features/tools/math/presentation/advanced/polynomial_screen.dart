import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/advanced_math_engine.dart';

class PolynomialScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PolynomialScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PolynomialScreen> createState() => _PolynomialScreenState();
}

class _PolynomialScreenState extends ConsumerState<PolynomialScreen> {
  String _a0 = '2', _a1 = '3', _a2 = '4'; // P(x) = 2 + 3x + 4x^2
  String _evalX = '2';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _a0 = map['a0']?.toString() ?? '2';
        _a1 = map['a1']?.toString() ?? '3';
        _a2 = map['a2']?.toString() ?? '4';
        _evalX = map['evalX']?.toString() ?? '2';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _a0 = '2';
      _a1 = '3';
      _a2 = '4';
      _evalX = '2';
    });
  }

  void _logHistory(Map<String, dynamic> res) {
    try {
      final stateJson = jsonEncode({
        'a0': _a0,
        'a1': _a1,
        'a2': _a2,
        'evalX': _evalX,
      });
      ref
          .read(historyProvider.notifier)
          .add(
            'Polynomial at x=$_evalX',
            'P($_evalX) = ${(res['value'] as double).toStringAsFixed(2)}',
            toolRoute: '/tools/math/advanced/polynomial',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result;
    String? errorMessage;

    try {
      final c0 = double.parse(_a0);
      final c1 = double.parse(_a1);
      final c2 = double.parse(_a2);
      final xVal = double.parse(_evalX);

      result = AdvancedMathEngine.evaluatePolynomial(
        coefficients: [c0, c1, c2],
        x: xVal,
      );
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    return ToolPageScaffold(
      toolId: 'polynomial',
      title: 'Polynomial Calculator',
      description: 'Evaluate polynomials P(x) = a₀ + a₁x + a₂x² + ... and analytical derivatives P\'(x).',
      icon: Icons.ssid_chart_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text(
          'Polynomial Coefficients P(x) = a₀ + a₁x + a₂x²:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Constant a₀',
                value: _a0,
                onChanged: (v) => setState(() => _a0 = v),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: PremiumNumericField(
                label: 'Linear a₁',
                value: _a1,
                onChanged: (v) => setState(() => _a1 = v),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: PremiumNumericField(
                label: 'Quadratic a₂',
                value: _a2,
                onChanged: (v) => setState(() => _a2 = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Evaluation Point (x)',
          value: _evalX,
          onChanged: (val) => setState(() => _evalX = val),
        ),
      ],
      results: [
        if (errorMessage != null)
          ResultDisplayCard(
            label: 'Polynomial Error',
            value: errorMessage,
            isError: true,
          )
        else if (result != null) ...[
          ResultDisplayCard(
            label: 'Polynomial Value P($_evalX)',
            value: (result['value'] as double)
                .toStringAsFixed(4)
                .replaceAll(RegExp(r'\.?0+$'), ''),
            secondaryLabel: 'Derivative at x=$_evalX (P\'(x))',
            secondaryValue: (result['derivativeAtX'] as double)
                .toStringAsFixed(4)
                .replaceAll(RegExp(r'\.?0+$'), ''),
            formula: result['formula'],
            substitution: result['substitution'],
            onReset: _reset,
            onShare: () => _logHistory(result!),
          ),
        ],
      ],
    );
  }
}
