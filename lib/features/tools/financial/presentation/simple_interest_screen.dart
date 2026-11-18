import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/simple_interest_provider.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';

class SimpleInterestScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SimpleInterestScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SimpleInterestScreen> createState() =>
      _SimpleInterestScreenState();
}

class _SimpleInterestScreenState extends ConsumerState<SimpleInterestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(simpleInterestProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simpleInterestProvider);
    final notifier = ref.read(simpleInterestProvider.notifier);

    return FinancialToolScaffold(
      title: 'Simple Interest',
      description: 'Calculate basic simple interest.',
      icon: Icons.percent,
      onBack: () {
        notifier.reset();
        context.pop();
      },
      onRefresh: notifier.reset,
      inputs: [
        PremiumNumericField(
          label: 'Principal',
          value: state.principal,
          onChanged: (val) => notifier.updateInput('principal', val),
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
            label: 'Final Amount',
            value: state.finalAmount,
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
