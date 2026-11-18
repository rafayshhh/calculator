import 'package:flutter/material.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_calculator_button.dart';

class EquationKeypad extends StatelessWidget {
  final ValueChanged<String> onAppend;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onSolve;

  const EquationKeypad({
    super.key,
    required this.onAppend,
    required this.onDelete,
    required this.onClear,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Variable and equals
        Row(
          children: [
            Expanded(child: KCalculatorButton(label: 'x', isSecondary: true, onTap: () => onAppend('x'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '=', isSecondary: true, onTap: () => onAppend('='))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '^', isSecondary: true, onTap: () => onAppend('^'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: 'AC', isAction: true, onTap: onClear)),
          ],
        ),
        const SizedBox(height: KSpacing.xs),
        // Row 2: 7, 8, 9, ÷
        Row(
          children: [
            Expanded(child: KCalculatorButton(label: '7', onTap: () => onAppend('7'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '8', onTap: () => onAppend('8'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '9', onTap: () => onAppend('9'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '÷', isOperator: true, onTap: () => onAppend('/'))),
          ],
        ),
        const SizedBox(height: KSpacing.xs),
        // Row 3: 4, 5, 6, ×
        Row(
          children: [
            Expanded(child: KCalculatorButton(label: '4', onTap: () => onAppend('4'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '5', onTap: () => onAppend('5'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '6', onTap: () => onAppend('6'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '×', isOperator: true, onTap: () => onAppend('*'))),
          ],
        ),
        const SizedBox(height: KSpacing.xs),
        // Row 4: 1, 2, 3, -
        Row(
          children: [
            Expanded(child: KCalculatorButton(label: '1', onTap: () => onAppend('1'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '2', onTap: () => onAppend('2'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '3', onTap: () => onAppend('3'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '-', isOperator: true, onTap: () => onAppend('-'))),
          ],
        ),
        const SizedBox(height: KSpacing.xs),
        // Row 5: 0, ., DEL, SOLVE
        Row(
          children: [
            Expanded(child: KCalculatorButton(label: '0', onTap: () => onAppend('0'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '.', onTap: () => onAppend('.'))),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '⌫', isAction: true, onTap: onDelete)),
            const SizedBox(width: KSpacing.xs),
            Expanded(child: KCalculatorButton(label: '+', isOperator: true, onTap: () => onAppend('+'))),
          ],
        ),
      ],
    );
  }
}
