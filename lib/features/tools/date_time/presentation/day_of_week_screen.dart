import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../domain/date_time_engine.dart';

class DayOfWeekScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DayOfWeekScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DayOfWeekScreen> createState() => _DayOfWeekScreenState();
}

class _DayOfWeekScreenState extends ConsumerState<DayOfWeekScreen> {
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['date'] != null) _date = DateTime.parse(data['date']);
      } catch (_) {}
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekdayName = DateTimeEngine.getWeekdayName(_date.weekday);
    final isLeap = DateTimeEngine.isLeapYear(_date.year);
    final dayOfYear = _date.difference(DateTime(_date.year, 1, 1)).inDays + 1;

    return ToolPageScaffold(
      toolId: 'day_of_week',
      title: 'Day of the Week',
      description: 'Identify the exact day of the week and yearly metrics for any calendar date.',
      icon: Icons.calendar_view_day_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() => _date = DateTime.now()),
      inputs: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
          title: const Text('Target Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          trailing: const Icon(Icons.edit_calendar_rounded),
          onTap: _selectDate,
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'Day of the Week',
          value: weekdayName,
          secondaryLabel: 'Weekday Index',
          secondaryValue: 'Day ${_date.weekday} of 7',
          formula: 'Zeller / Gregorian Algorithmic Day',
          substitution: weekdayName,
          onShare: () {},
        ),
        const SizedBox(height: KSpacing.md),
        KStatRow(label: 'Day of the Year', value: 'Day $dayOfYear of ${isLeap ? 366 : 365}'),
        const SizedBox(height: KSpacing.xs),
        KStatRow(label: 'Leap Year', value: isLeap ? 'Yes (366 days)' : 'No (365 days)'),
      ],
    );
  }
}
