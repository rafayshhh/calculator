import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/date_time_engine.dart';

class DateAddSubtractScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DateAddSubtractScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DateAddSubtractScreen> createState() =>
      _DateAddSubtractScreenState();
}

class _DateAddSubtractScreenState extends ConsumerState<DateAddSubtractScreen> {
  DateTime _initialDate = DateTime.now();
  String _operation = 'add'; // 'add' or 'subtract'
  String _years = '0';
  String _months = '1';
  String _weeks = '0';
  String _days = '0';

  DateAddSubtractResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['initialDate'] != null) {
          _initialDate = DateTime.parse(data['initialDate']);
        }
        _operation = data['operation'] ?? 'add';
        _years = data['years'] ?? '0';
        _months = data['months'] ?? '1';
        _weeks = data['weeks'] ?? '0';
        _days = data['days'] ?? '0';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      final y = int.tryParse(_years) ?? 0;
      final m = int.tryParse(_months) ?? 0;
      final w = int.tryParse(_weeks) ?? 0;
      final d = int.tryParse(_days) ?? 0;

      if (y < 0 || m < 0 || w < 0 || d < 0) {
        setState(() {
          _result = null;
          _error = 'Values must be non-negative integers';
        });
        return;
      }

      final res = DateTimeEngine.calculateDateAddSubtract(
        initialDate: _initialDate,
        operation: _operation,
        years: y,
        months: m,
        weeks: w,
        days: d,
      );

      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({
        'initialDate': _initialDate.toIso8601String(),
        'operation': _operation,
        'years': _years,
        'months': _months,
        'weeks': _weeks,
        'days': _days,
      });

      final initStr = _formatDate(_initialDate);
      final resStr = _formatDate(res.resultDate);
      final opSymbol = _operation == 'add' ? '+' : '-';

      ref
          .read(historyProvider.notifier)
          .add(
            'Date Math: $initStr $opSymbol ($y y, $m m, $w w, $d d)',
            '$resStr (${res.dayOfWeek})',
            toolRoute: '/tools/date_time/date_add_subtract',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e
            .toString()
            .replaceAll('ArgumentError: ', '')
            .replaceAll('Invalid argument(s): ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _initialDate = DateTime.now();
      _operation = 'add';
      _years = '0';
      _months = '1';
      _weeks = '0';
      _days = '0';
    });
    _calculate();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _initialDate = picked;
      });
      _calculate();
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimaryColor = isDark
        ? KColors.textPrimaryDark
        : KColors.textPrimaryLight;
    final textSecondaryColor = isDark
        ? KColors.textSecondaryDark
        : KColors.textSecondaryLight;

    return FinancialToolScaffold(
      toolId: 'date_add_subtract',
      title: 'Add / Subtract Date',
      description: 'Add or subtract years, months, weeks, and days with calendar-accurate month clamping',
      icon: Icons.edit_calendar_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: KGlassCard(
                  padding: const EdgeInsets.all(KSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starting Date',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_initialDate),
                        style: TextStyle(
                          color: textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _initialDate = DateTime.now());
                _calculate();
              },
              icon: const Icon(Icons.today_outlined, size: 16),
              label: const Text('Today'),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'add', label: Text('Add (+)')),
            ButtonSegment(value: 'subtract', label: Text('Subtract (-)')),
          ],
          selected: {_operation},
          onSelectionChanged: (set) {
            setState(() => _operation = set.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Years',
                value: _years,
                onChanged: (val) {
                  _years = val;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Months',
                value: _months,
                onChanged: (val) {
                  _months = val;
                  _calculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.sm),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Weeks',
                value: _weeks,
                onChanged: (val) {
                  _weeks = val;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Days',
                value: _days,
                onChanged: (val) {
                  _days = val;
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(
            label: 'Calculation Error',
            value: _error!,
            isError: true,
          )
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Resulting Date',
            value: _formatDate(_result!.resultDate),
            secondaryLabel: 'Day of Week',
            secondaryValue: _result!.dayOfWeek,
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calculation Details & Calendar Policy',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                _buildRow('Original Date:', _formatDate(_result!.originalDate)),
                _buildRow('Operation:', _result!.operation.toUpperCase()),
                _buildRow(
                  'Applied Duration:',
                  '${_result!.years}y ${_result!.months}m ${_result!.weeks}w ${_result!.days}d',
                ),
                _buildRow(
                  'Leap Year Target:',
                  _result!.isLeapYear ? 'Yes (366 days)' : 'No (365 days)',
                ),
                const SizedBox(height: 6),
                Text(
                  'Month-End Policy: Calendar days exceeding the target month end (e.g. Jan 31 + 1 month) are automatically clamped to the month boundary (Feb 28/29).',
                  style: TextStyle(color: textSecondaryColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRow(String label, String val) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? KColors.textSecondaryDark
                    : KColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            val,
            style: TextStyle(
              color: isDark
                  ? KColors.textPrimaryDark
                  : KColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
