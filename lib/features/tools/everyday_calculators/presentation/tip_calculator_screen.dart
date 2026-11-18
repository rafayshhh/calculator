import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/tip_provider.dart';

class TipCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;

  const TipCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TipCalculatorScreen> createState() =>
      _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends ConsumerState<TipCalculatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(tipProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tipProvider);
    final notifier = ref.read(tipProvider.notifier);

    return ToolPageScaffold(
      toolId: 'tip',
      title: 'Tip Calculator',
      description:
          'Calculate gratuity and split dining checks evenly per person',
      icon: Icons.receipt_long_outlined,
      onBack: () {
        notifier.reset();
        context.pop();
      },
      onRefresh: notifier.reset,
      inputs: [
        PremiumNumericField(
          label: 'Bill Amount',
          prefix: '\$',
          value: state.billAmount,
          onChanged: notifier.setBillAmount,
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Tip Percentage',
          suffix: '%',
          value: state.tipPercentage,
          onChanged: notifier.setTipPercentage,
        ),
        const SizedBox(height: KSpacing.sm),
        _buildTipPresets(notifier),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Number of Guests',
          suffix: 'people',
          value: state.people,
          onChanged: notifier.setPeople,
        ),
      ],
      results: [
        if (state.result != null || state.hasError) ...[
          ResultDisplayCard(
            label: 'Total Per Person',
            value: state.hasError
                ? 'Error'
                : '\$${state.result!.totalPerPerson.toStringAsFixed(2)}',
            secondaryLabel: state.hasError ? null : 'Total Tip',
            secondaryValue: state.hasError
                ? null
                : '\$${state.result!.tipAmount.toStringAsFixed(2)}',
            isError: state.hasError,
            bottomContent: state.hasError || state.result == null
                ? null
                : Column(
                    children: [
                      const SizedBox(height: KSpacing.sm),
                      KStatRow(
                        label: 'Total Combined Bill',
                        value:
                            '\$${state.result!.totalBill.toStringAsFixed(2)}',
                        isHighlighted: true,
                      ),
                      KStatRow(
                        label: 'Tip Per Person',
                        value:
                            '\$${state.result!.tipPerPerson.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
          ),
          if (state.result != null && !state.hasError) ...[
            const SizedBox(height: KSpacing.md),
            KFormulaCard(
              title: 'Tip & Split Breakdown',
              formula: 'Total = (Bill + (Bill × Tip%)) / People',
              substitution:
                  '(\$${state.billAmount} + \$${state.result!.tipAmount.toStringAsFixed(2)}) / ${state.people} = \$${state.result!.totalPerPerson.toStringAsFixed(2)}',
              notes:
                  'Tip Rate = ${state.tipPercentage}% · Split among ${state.people} people',
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTipPresets(TipNotifier notifier) {
    final presets = ['10', '15', '18', '20', '25'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.map((percent) {
          return Padding(
            padding: const EdgeInsets.only(right: KSpacing.xs),
            child: ActionChip(
              label: Text('$percent%'),
              onPressed: () => notifier.setTipPercentage(percent),
            ),
          );
        }).toList(),
      ),
    );
  }
}
