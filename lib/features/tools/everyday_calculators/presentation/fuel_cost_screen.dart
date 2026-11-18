import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_error_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/fuel_cost_provider.dart';

class FuelCostScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;

  const FuelCostScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<FuelCostScreen> createState() => _FuelCostScreenState();
}

class _FuelCostScreenState extends ConsumerState<FuelCostScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(fuelCostProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fuelCostProvider);
    final notifier = ref.read(fuelCostProvider.notifier);

    return ToolPageScaffold(
      toolId: 'fuel_cost',
      title: 'Fuel Cost Calculator',
      description: 'Compute trip fuel consumption, required volume, and total travel cost',
      icon: Icons.directions_car_outlined,
      onBack: () {
        notifier.reset();
        context.pop();
      },
      onRefresh: notifier.reset,
      inputs: [
        PremiumNumericField(
          label: 'Trip Distance',
          value: state.distance,
          onChanged: notifier.setDistance,
          suffix: 'km / mi',
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PremiumNumericField(
                label: 'Fuel Consumption Rate',
                value: state.efficiency,
                onChanged: notifier.setEfficiency,
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              flex: 1,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('L/100km')),
                  ButtonSegment(value: false, label: Text('MPG')),
                ],
                selected: {state.isVolumePerDistance},
                onSelectionChanged: (_) => notifier.toggleEfficiencyType(),
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Fuel Price per Unit',
          value: state.fuelPrice,
          onChanged: notifier.setFuelPrice,
          prefix: '\$',
          suffix: '/ L or gal',
        ),
      ],
      results: [
        if (state.hasError && state.errorMessage.isNotEmpty)
          KErrorCard(
            title: 'Calculation Error',
            message: state.errorMessage,
            onRetry: notifier.reset,
          )
        else if (state.totalCost.isNotEmpty) ...[
          ResultDisplayCard(
            label: 'Total Trip Cost',
            value: '\$${state.totalCost}',
            secondaryLabel: 'Fuel Required',
            secondaryValue: '${state.fuelNeeded} Units',
          ),
          const SizedBox(height: KSpacing.md),
          KFormulaCard(
            title: 'Trip Cost Equation',
            formula: state.isVolumePerDistance
                ? 'Cost = (Distance × (L/100km / 100)) × Price'
                : 'Cost = (Distance / MPG) × Price',
            substitution:
                '(${state.distance} dist @ ${state.efficiency} efficiency) × \$${state.fuelPrice}',
            notes: 'Fuel Needed: ${state.fuelNeeded} Units',
          ),
        ],
      ],
    );
  }
}
