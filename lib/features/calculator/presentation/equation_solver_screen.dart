import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_spacing.dart';
import '../../../core/widgets/tool_page_scaffold.dart';
import '../../../core/widgets/premium_numeric_field.dart';
import '../../../core/widgets/result_display_card.dart';
import '../../history/providers/history_provider.dart';
import '../domain/equation_solver_engine.dart';
import 'widgets/equation_keypad.dart';

class EquationSolverScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const EquationSolverScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<EquationSolverScreen> createState() =>
      _EquationSolverScreenState();
}

class _EquationSolverScreenState extends ConsumerState<EquationSolverScreen> {
  String _equation = '2x + 5 = 15';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _equation = map['equation']?.toString() ?? '2x + 5 = 15';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _equation = '2x + 5 = 15';
    });
  }

  void _logHistory(EquationSolution sol) {
    try {
      final stateJson = jsonEncode({'equation': _equation});

      ref
          .read(historyProvider.notifier)
          .add(
            _equation,
            sol.solutions.join(', '),
            toolRoute: '/calculator/equation',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    EquationSolution? solution;
    String? errorMessage;

    try {
      if (_equation.trim().isNotEmpty) {
        solution = EquationSolverEngine.solve(_equation);
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    final quickPresets = [
      '2x + 5 = 15',
      'x^2 - 5x + 6 = 0',
      '3(x + 2) = 18',
      'x^2 + 4 = 0',
      '2x^2 + 3x - 5 = 0',
    ];

    return ToolPageScaffold(
      toolId: 'equation_solver',
      title: 'Equation Solver',
      description: 'Solve linear, quadratic, polynomial, and single-variable equations with step-by-step resolution.',
      icon: Icons.functions_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Equation in x (e.g. 2x + 5 = 15)',
          value: _equation,
          onChanged: (val) => setState(() => _equation = val),
          keyboardType: TextInputType.none,
        ),
        const SizedBox(height: KSpacing.md),
        const Text(
          'Quick Presets:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickPresets.map((preset) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(
                    preset,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  onPressed: () => setState(() => _equation = preset),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: KSpacing.lg),
        EquationKeypad(
          onAppend: (char) => setState(() => _equation += char),
          onDelete: () {
            setState(() {
              if (_equation.isNotEmpty) {
                _equation = _equation.substring(0, _equation.length - 1);
              }
            });
          },
          onClear: _reset,
          onSolve: () {
            // Trigger UI update to solve (already reactive, but this handles manual clicks)
            setState(() {});
          },
        ),
      ],
      results: [
        if (errorMessage != null)
          ResultDisplayCard(
            label: 'Solving Error',
            value: errorMessage,
            isError: true,
          )
        else if (solution != null) ...[
          ResultDisplayCard(
            label: solution.type,
            value: solution.solutions.join('\n'),
            secondaryLabel: 'Equation',
            secondaryValue: solution.equation,
            formula: 'f(x) = 0',
            substitution: solution.steps.join('\n'),
            details: solution.verification,
            onReset: _reset,
            onShare: () => _logHistory(solution!),
          ),
        ],
      ],
    );
  }
}
