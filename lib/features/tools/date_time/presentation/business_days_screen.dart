import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/date_time_engine.dart';

class BusinessDaysScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const BusinessDaysScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<BusinessDaysScreen> createState() => _BusinessDaysScreenState();
}

class _BusinessDaysScreenState extends ConsumerState<BusinessDaysScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  Set<int> _weekendDays = {DateTime.saturday, DateTime.sunday};
  final List<DateTime> _holidays = [];

  BusinessDaysResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['startDate'] != null) {
          _startDate = DateTime.parse(data['startDate']);
        }
        if (data['endDate'] != null) _endDate = DateTime.parse(data['endDate']);
        if (data['weekendDays'] != null) {
          _weekendDays = (data['weekendDays'] as List)
              .map((e) => e as int)
              .toSet();
        }
        if (data['holidays'] != null) {
          _holidays.clear();
          for (final h in data['holidays'] as List) {
            _holidays.add(DateTime.parse(h));
          }
        }
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      final res = DateTimeEngine.calculateBusinessDays(
        start: _startDate,
        end: _endDate,
        weekendDays: _weekendDays,
        holidays: _holidays,
      );

      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'weekendDays': _weekendDays.toList(),
        'holidays': _holidays.map((h) => h.toIso8601String()).toList(),
      });

      final sStr = _formatDate(_startDate);
      final eStr = _formatDate(_endDate);

      ref
          .read(historyProvider.notifier)
          .add(
            'Business Days: $sStr → $eStr',
            '${res.businessDays} business days (${res.totalCalendarDays} calendar days)',
            toolRoute: '/tools/date_time/business_days',
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
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 14));
      _weekendDays = {DateTime.saturday, DateTime.sunday};
      _holidays.clear();
    });
    _calculate();
  }

  Future<void> _pickDate(bool isStart) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _calculate();
    }
  }

  Future<void> _addHoliday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        final dateOnly = DateTime(picked.year, picked.month, picked.day);
        if (!_holidays.any(
          (h) =>
              h.year == dateOnly.year &&
              h.month == dateOnly.month &&
              h.day == dateOnly.day,
        )) {
          _holidays.add(dateOnly);
          _holidays.sort((a, b) => a.compareTo(b));
        }
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
      toolId: 'business_days',
      title: 'Business Days Calculator',
      description: 'Compute working days between dates with custom weekend models and excluded holidays',
      icon: Icons.work_history_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(true),
                borderRadius: BorderRadius.circular(16),
                child: KGlassCard(
                  padding: const EdgeInsets.all(KSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_startDate),
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
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(false),
                borderRadius: BorderRadius.circular(16),
                child: KGlassCard(
                  padding: const EdgeInsets.all(KSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_endDate),
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
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Text(
          'Weekend Days Configuration',
          style: TextStyle(
            color: primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: KSpacing.xs),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildWeekendChip('Mon', DateTime.monday),
            _buildWeekendChip('Tue', DateTime.tuesday),
            _buildWeekendChip('Wed', DateTime.wednesday),
            _buildWeekendChip('Thu', DateTime.thursday),
            _buildWeekendChip('Fri', DateTime.friday),
            _buildWeekendChip('Sat', DateTime.saturday),
            _buildWeekendChip('Sun', DateTime.sunday),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'Excluded Holidays (${_holidays.length})',
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addHoliday,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Holiday'),
            ),
          ],
        ),
        if (_holidays.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _holidays.map((h) {
              return Chip(
                label: Text(
                  _formatDate(h),
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () {
                  setState(() {
                    _holidays.remove(h);
                  });
                  _calculate();
                },
              );
            }).toList(),
          ),
        ],
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(label: 'Error', value: _error!, isError: true)
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Business Days',
            value: '${_result!.businessDays} Days',
            secondaryLabel: 'Calendar Days',
            secondaryValue: '${_result!.totalCalendarDays} Total Days',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Days Breakdown',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                _buildRow(
                  'Weekend Days Excluded:',
                  '${_result!.weekendDays} days',
                ),
                _buildRow(
                  'Holidays Excluded:',
                  '${_result!.holidaysExcluded} days (no double-counting)',
                ),
                if (_result!.firstBusinessDay != null)
                  _buildRow(
                    'First Business Day:',
                    _formatDate(_result!.firstBusinessDay!),
                  ),
                if (_result!.lastBusinessDay != null)
                  _buildRow(
                    'Last Business Day:',
                    _formatDate(_result!.lastBusinessDay!),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekendChip(String label, int dayInt) {
    final isSelected = _weekendDays.contains(dayInt);
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _weekendDays.add(dayInt);
          } else {
            _weekendDays.remove(dayInt);
          }
        });
        _calculate();
      },
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
