import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/date_time_engine.dart';

class DateDifferenceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DateDifferenceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DateDifferenceScreen> createState() => _DateDifferenceScreenState();
}

class _DateDifferenceScreenState extends ConsumerState<DateDifferenceScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  DateDifferenceResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['startDate'] != null) _startDate = DateTime.parse(data['startDate']);
        if (data['endDate'] != null) _endDate = DateTime.parse(data['endDate']);
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final res = DateTimeEngine.calculateDifference(start: _startDate, end: _endDate);
    setState(() {
      _result = res;
    });

    final stateJson = jsonEncode({
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
    });

    ref.read(historyProvider.notifier).add(
      'Date Difference: \${res.formattedSummary}',
      '\${res.totalDays} Days',
      toolRoute: '/tools/date_time/date_difference',
      toolStateJson: stateJson,
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  String _format(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'date_difference',
      title: 'Date Difference Calculator',
      description: 'Compute exact elapsed calendar time and total days between two dates.',
      icon: Icons.date_range_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        setState(() {
          _startDate = DateTime.now().subtract(const Duration(days: 30));
          _endDate = DateTime.now();
        });
        _calculate();
      },
      inputs: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
                title: const Text('Start Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_format(_startDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.event_available_rounded, size: 18),
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
                title: const Text('End Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_format(_endDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.event_busy_rounded, size: 18),
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_result != null) ...[
          ResultDisplayCard(
            label: 'Elapsed Time',
            value: _result!.formattedSummary,
            secondaryLabel: 'Total Days',
            secondaryValue: '\${_result!.totalDays} days',
            formula: 'Difference = EndDate - StartDate',
            substitution: '\${_format(_startDate)} to \${_format(_endDate)} = \${_result!.totalDays} days',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Total Weeks', value: '\${_result!.totalWeeks} weeks'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Total Hours', value: '\${_result!.totalHours} hours'),
        ],
      ],
    );
  }
}
