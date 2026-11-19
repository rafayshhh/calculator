import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';

class SeriesSummationScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SeriesSummationScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SeriesSummationScreen> createState() => _SeriesSummationScreenState();
}

class _SeriesSummationScreenState extends ConsumerState<SeriesSummationScreen> {
  String _startK = '1';
  String _endN = '100';
  int _power = 1; // k^1, k^2, k^3
  double? _sum;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final k = int.tryParse(_startK) ?? 1;
    final n = int.tryParse(_endN) ?? 100;
    if (k > n || n > 1000000) return;

    double s = 0.0;
    for (int i = k; i <= n; i++) {
      if (_power == 1) s += i;
      else if (_power == 2) s += (i * i);
      else s += (i * i * i);
    }

    setState(() => _sum = s);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'series_summation',
      title: 'Series Summation (Σ)',
      description: 'Compute finite series power sums Σ k^p over custom integer intervals.',
      icon: Icons.functions_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() {
        _startK = '1';
        _endN = '100';
        _power = 1;
        _calculate();
      }),
      inputs: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('Σ k')),
            ButtonSegment(value: 2, label: Text('Σ k²')),
            ButtonSegment(value: 3, label: Text('Σ k³')),
          ],
          selected: {_power},
          onSelectionChanged: (s) {
            setState(() => _power = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(child: PremiumNumericField(label: 'Lower Bound (k)', value: _startK, onChanged: (v) { _startK = v; _calculate(); })),
            const SizedBox(width: KSpacing.md),
            Expanded(child: PremiumNumericField(label: 'Upper Bound (n)', value: _endN, onChanged: (v) { _endN = v; _calculate(); })),
          ],
        ),
      ],
      results: [
        if (_sum != null)
          ResultDisplayCard(
            label: 'Series Sum (Σ)',
            value: '${_sum!.toInt()}',
            secondaryLabel: 'Terms Count',
            secondaryValue: '${(int.tryParse(_endN) ?? 0) - (int.tryParse(_startK) ?? 0) + 1}',
            formula: 'Σ_{k=$_startK}^{$_endN} k^$_power',
            substitution: 'Total Sum = ${_sum!.toInt()}',
            onShare: () {},
          ),
      ],
    );
  }
}
