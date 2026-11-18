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
import '../domain/statistics_engine.dart';

class PermutationsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const PermutationsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<PermutationsScreen> createState() => _PermutationsScreenState();
}

class _PermutationsScreenState extends ConsumerState<PermutationsScreen> {
  String _valN = '8';
  String _valR = '3';
  int? _permutations;
  int? _combinations;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final n = int.tryParse(_valN);
    final r = int.tryParse(_valR);
    if (n == null || r == null || n < 0 || r < 0 || r > n) {
      setState(() {
        _permutations = null;
        _combinations = null;
        _error = 'Values must satisfy 0 ≤ r ≤ n';
      });
      return;
    }

    try {
      final p = StatisticsEngine.permutations(n, r);
      final c = StatisticsEngine.combinations(n, r);
      setState(() {
        _error = null;
        _permutations = p;
        _combinations = c;
      });

      final stateJson = jsonEncode({'n': _valN, 'r': _valR});
      ref.read(historyProvider.notifier).add(
        'Permutations: n=$_valN, r=$_valR',
        'nPr=$p, nCr=$c',
        toolRoute: '/tools/math/permutations',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _permutations = null;
        _combinations = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _valN = '8';
      _valR = '3';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'permutations',
      title: 'Permutations & Combinations',
      description: 'Compute permutations nPr and combinations nCr of finite sets.',
      icon: Icons.shuffle_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Total Items (n)',
                value: _valN,
                onChanged: (v) {
                  _valN = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Sample Size (r)',
                value: _valR,
                onChanged: (v) {
                  _valR = v;
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
        else if (_permutations != null && _combinations != null) ...[
          ResultDisplayCard(
            label: 'Permutations (nPr)',
            value: '$_permutations Possibilities',
            secondaryLabel: 'Combinations (nCr)',
            secondaryValue: '$_combinations Possibilities',
            formula: 'nPr = n! / (n - r)! | nCr = n! / [r!(n - r)!]',
            substitution: 'P($_valN, $_valR) = $_permutations | C($_valN, $_valR) = $_combinations',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
