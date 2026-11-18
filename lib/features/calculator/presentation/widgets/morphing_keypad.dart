import 'package:flutter/material.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../providers/calculator_provider.dart';
import 'basic_keypad.dart';
import 'scientific_keypad.dart';

class MorphingKeypad extends StatelessWidget {
  final CalculatorState state;
  final CalculatorNotifier notifier;

  const MorphingKeypad({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isScientific) {
      return Column(
        children: [
          Expanded(
            flex: 3,
            child: ScientificKeypad(
              state: state,
              notifier: notifier,
            ),
          ),
          const SizedBox(height: KSpacing.xs),
          Expanded(
            flex: 5,
            child: BasicKeypad(
              state: state,
              notifier: notifier,
            ),
          ),
        ],
      );
    }

    return BasicKeypad(
      state: state,
      notifier: notifier,
    );
  }
}
