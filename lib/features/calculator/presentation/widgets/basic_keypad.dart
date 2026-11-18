import 'package:flutter/material.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_calculator_button.dart';
import '../../providers/calculator_provider.dart';

class BasicKeypad extends StatelessWidget {
  final CalculatorState state;
  final CalculatorNotifier notifier;

  const BasicKeypad({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KCalculatorButton(
                      label: 'AC',
                      isAction: true,
                      onTap: () => notifier.clear(),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '( )',
                      isAction: true,
                      onTap: () {
                        final expr = state.expression;
                        final openCount = '('.allMatches(expr).length;
                        final closeCount = ')'.allMatches(expr).length;
                        if (openCount > closeCount &&
                            !expr.endsWith('(') &&
                            !expr.endsWith('+') &&
                            !expr.endsWith('-') &&
                            !expr.endsWith('*') &&
                            !expr.endsWith('*') &&
                            !expr.endsWith('/') &&
                            !expr.endsWith('/')) {
                          notifier.append(')');
                        } else {
                          notifier.append('(');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '%',
                      isAction: true,
                      onTap: () => notifier.append('%'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '÷',
                      isOperator: true,
                      onTap: () => notifier.append('÷'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KSpacing.xs),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KCalculatorButton(
                      label: '7',
                      onTap: () => notifier.append('7'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '8',
                      onTap: () => notifier.append('8'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '9',
                      onTap: () => notifier.append('9'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '×',
                      isOperator: true,
                      onTap: () => notifier.append('×'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KSpacing.xs),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KCalculatorButton(
                      label: '4',
                      onTap: () => notifier.append('4'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '5',
                      onTap: () => notifier.append('5'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '6',
                      onTap: () => notifier.append('6'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '-',
                      isOperator: true,
                      onTap: () => notifier.append('-'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KSpacing.xs),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KCalculatorButton(
                      label: '1',
                      onTap: () => notifier.append('1'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '2',
                      onTap: () => notifier.append('2'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '3',
                      onTap: () => notifier.append('3'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '+',
                      isOperator: true,
                      onTap: () => notifier.append('+'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KSpacing.xs),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KCalculatorButton(
                      label: '±',
                      onTap: () {
                        if (state.expression.startsWith('-')) {
                          notifier.setExpression(state.expression.substring(1));
                        } else if (state.expression != '0') {
                          notifier.setExpression('-${state.expression}');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '0',
                      onTap: () => notifier.append('0'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '.',
                      onTap: () => notifier.append('.'),
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Expanded(
                    child: KCalculatorButton(
                      label: '=',
                      isEqual: true,
                      onTap: () => notifier.calculate(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
