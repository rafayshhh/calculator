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

class GcdLcmScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const GcdLcmScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<GcdLcmScreen> createState() => _GcdLcmScreenState();
}

class _GcdLcmScreenState extends ConsumerState<GcdLcmScreen> {
  String _valA = '48';
  String _valB = '180';
  int? _gcd;
  int? _lcm;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = int.tryParse(_valA);
    final b = int.tryParse(_valB);
    if (a == null || b == null || a <= 0 || b <= 0) {
      setState(() {
        _gcd = null;
        _lcm = null;
        _error = 'Please enter positive integers for A and B';
      });
      return;
    }

    try {
      final g = MathUtilitiesEngine.gcd(a, b);
      final l = MathUtilitiesEngine.lcm(a, b);
      setState(() {
        _error = null;
        _gcd = g;
        _lcm = l;
      });

      final stateJson = jsonEncode({'valA': _valA, 'valB': _valB});
      ref.read(historyProvider.notifier).add(
        'GCD/LCM: $_valA and $_valB',
        'GCD=$g, LCM=$l',
        toolRoute: '/tools/math/gcd_lcm',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _gcd = null;
        _lcm = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _valA = '48';
      _valB = '180';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'gcd_lcm',
      title: 'GCD & LCM Calculator',
      description: 'Compute Greatest Common Divisor and Least Common Multiple of integers.',
      icon: Icons.device_hub_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Integer A',
                value: _valA,
                onChanged: (v) {
                  _valA = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Integer B',
                value: _valB,
                onChanged: (v) {
                  _valB = v;
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
        else if (_gcd != null && _lcm != null) ...[
          ResultDisplayCard(
            label: 'Greatest Common Divisor (GCD)',
            value: '$_gcd',
            secondaryLabel: 'Least Common Multiple (LCM)',
            secondaryValue: '$_lcm',
            formula: 'Euclidean Algorithm | LCM = (|a × b|) / GCD',
            substitution: 'GCD($_valA, $_valB) = $_gcd | LCM($_valA, $_valB) = $_lcm',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
