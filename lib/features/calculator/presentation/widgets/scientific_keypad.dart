import 'package:flutter/material.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_calculator_button.dart';
import '../../domain/math_engine.dart';
import '../../providers/calculator_provider.dart';

class ScientificKeypad extends StatelessWidget {
  final CalculatorState state;
  final CalculatorNotifier notifier;

  const ScientificKeypad({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scientific Function Rows
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: KCalculatorButton(
                  label: state.angleMode == AngleMode.degrees
                      ? 'DEG'
                      : (state.angleMode == AngleMode.radians ? 'RAD' : 'GRAD'),
                  isSecondary: true,
                  fontSize: 12,
                  onTap: () => notifier.toggleAngleMode(),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'sin',
                  isSecondary: true,
                  onTap: () => notifier.append('sin('),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'cos',
                  isSecondary: true,
                  onTap: () => notifier.append('cos('),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'tan',
                  isSecondary: true,
                  onTap: () => notifier.append('tan('),
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
                  label: 'ln',
                  isSecondary: true,
                  onTap: () => notifier.append('ln('),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'log',
                  isSecondary: true,
                  onTap: () => notifier.append('log('),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: '√',
                  isSecondary: true,
                  onTap: () => notifier.append('sqrt('),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: '^',
                  isSecondary: true,
                  onTap: () => notifier.append('^'),
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
                  label: 'π',
                  isSecondary: true,
                  onTap: () => notifier.append('pi'),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'e',
                  isSecondary: true,
                  onTap: () => notifier.append('e'),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'x!',
                  isSecondary: true,
                  onTap: () => notifier.append('!'),
                ),
              ),
              const SizedBox(width: KSpacing.xs),
              Expanded(
                child: KCalculatorButton(
                  label: 'abs',
                  isSecondary: true,
                  fontSize: 12,
                  onTap: () => notifier.append('abs('),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
