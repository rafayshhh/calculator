import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';

class NumericalMethodsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const NumericalMethodsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<NumericalMethodsScreen> createState() => _NumericalMethodsScreenState();
}

class _NumericalMethodsScreenState extends ConsumerState<NumericalMethodsScreen> {
  // Newton-Raphson to solve x² - N = 0 (finding sqrt(N))
  String _targetN = '25.0';
  String _initialGuess = '5.0';
  double? _root;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final n = double.tryParse(_targetN) ?? 25.0;
    double x = double.tryParse(_initialGuess) ?? 1.0;

    // Newton-Raphson iterations: x_{k+1} = 0.5 * (x_k + N / x_k)
    for (int i = 0; i < 20; i++) {
      if (x != 0) x = 0.5 * (x + n / x);
    }

    setState(() => _root = x);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'numerical_methods',
      title: 'Numerical Methods',
      description: 'Iterative root approximation via Newton-Raphson numerical algorithm.',
      icon: Icons.sync_problem_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() {
        _targetN = '25.0';
        _initialGuess = '5.0';
        _calculate();
      }),
      inputs: [
        PremiumNumericField(
          label: 'Target Value (N) for x² - N = 0',
          value: _targetN,
          onChanged: (v) {
            _targetN = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Initial Guess (x₀)',
          value: _initialGuess,
          onChanged: (v) {
            _initialGuess = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_root != null)
          ResultDisplayCard(
            label: 'Approximated Root (x*)',
            value: _root!.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Iteration Scheme',
            secondaryValue: 'Newton-Raphson',
            formula: "x_{k+1} = x_k - f(x_k) / f'(x_k)",
            substitution: 'Converged in 20 iterations to ${_root!.toStringAsFixed(6)}',
            onShare: () {},
          ),
      ],
    );
  }
}
