import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/savings_provider.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SavingsScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(savingsProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsProvider);
    final notifier = ref.read(savingsProvider.notifier);

    return FinancialToolScaffold(
      title: 'Savings Calculator',
      description: 'Plan and project your savings.',
      icon: Icons.savings,
      onBack: () {
        notifier.reset();
        context.pop();
      },
      onRefresh: notifier.reset,
      inputs: [
        PremiumNumericField(
          label: 'Initial Deposit',
          value: state.initialDeposit,
          onChanged: (val) => notifier.updateInput('initialDeposit', val),
          suffix: '',
        ),
        PremiumNumericField(
          label: 'Monthly Contribution',
          value: state.contribution,
          onChanged: (val) => notifier.updateInput('contribution', val),
          suffix: '',
        ),
        PremiumNumericField(
          label: 'Annual Rate',
          value: state.rate,
          onChanged: (val) => notifier.updateInput('rate', val),
          suffix: '%',
        ),
        PremiumNumericField(
          label: 'Years',
          value: state.years,
          onChanged: (val) => notifier.updateInput('years', val),
          suffix: '',
        ),
      ],
      results: [
        if (state.hasError && state.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        if (state.finalAmount.isNotEmpty)
          ResultDisplayCard(
            label: 'Final Balance',
            value: state.finalAmount,
            isError: false,
          ),
        if (state.totalPrincipal.isNotEmpty)
          ResultDisplayCard(
            label: 'Total Contributions',
            value: state.totalPrincipal,
            isError: false,
          ),
        if (state.interestEarned.isNotEmpty)
          ResultDisplayCard(
            label: 'Interest Earned',
            value: state.interestEarned,
            isError: false,
          ),
      ],
    );
  }
}
