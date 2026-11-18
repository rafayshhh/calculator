import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';

class SalaryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const SalaryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends ConsumerState<SalaryScreen> {
  String _hourlyRate = '35.0';
  String _hoursPerWeek = '40.0';
  String _weeksPerYear = '52.0';

  @override
  Widget build(BuildContext context) {
    final hr = double.tryParse(_hourlyRate) ?? 0.0;
    final hw = double.tryParse(_hoursPerWeek) ?? 40.0;
    final wy = double.tryParse(_weeksPerYear) ?? 52.0;

    final weekly = hr * hw;
    final annual = weekly * wy;
    final monthly = annual / 12.0;
    final biweekly = weekly * 2.0;

    return ToolPageScaffold(
      toolId: 'salary',
      title: 'Salary & Wage Converter',
      description: 'Convert between hourly wage, weekly paycheck, monthly income, and annual salary.',
      icon: Icons.account_balance_wallet_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() {
        _hourlyRate = '35.0';
        _hoursPerWeek = '40.0';
        _weeksPerYear = '52.0';
      }),
      inputs: [
        PremiumNumericField(
          label: 'Hourly Wage',
          prefix: '\$',
          value: _hourlyRate,
          onChanged: (v) => setState(() => _hourlyRate = v),
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Hours Per Week',
          suffix: 'hrs',
          value: _hoursPerWeek,
          onChanged: (v) => setState(() => _hoursPerWeek = v),
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Work Weeks Per Year',
          suffix: 'weeks',
          value: _weeksPerYear,
          onChanged: (v) => setState(() => _weeksPerYear = v),
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'Annual Salary',
          value: '\$${annual.toStringAsFixed(2)}',
          secondaryLabel: 'Monthly Gross Pay',
          secondaryValue: '\$${monthly.toStringAsFixed(2)}',
          formula: 'Annual = Hourly × Hours/Wk × Wks/Yr',
          substitution: '\$$hr/hr × $hw h/wk = \$${annual.toStringAsFixed(2)}/yr',
          onShare: () {},
        ),
        const SizedBox(height: KSpacing.md),
        KStatRow(label: 'Weekly Paycheck', value: '\$${weekly.toStringAsFixed(2)}'),
        const SizedBox(height: KSpacing.xs),
        KStatRow(label: 'Bi-Weekly Paycheck', value: '\$${biweekly.toStringAsFixed(2)}'),
      ],
    );
  }
}
