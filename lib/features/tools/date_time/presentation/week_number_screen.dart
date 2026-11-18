import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../domain/date_time_engine.dart';

class WeekNumberScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const WeekNumberScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<WeekNumberScreen> createState() => _WeekNumberScreenState();
}

class _WeekNumberScreenState extends ConsumerState<WeekNumberScreen> {
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
    final weekNum = DateTimeEngine.getWeekNumber(_date);

    return ToolPageScaffold(
      toolId: 'week_number',
      title: 'Week Number',
      description: 'Compute ISO 8601 calendar week number for any date.',
      icon: Icons.view_week_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() => _date = DateTime.now()),
      inputs: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
          title: const Text('Calendar Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text('\${_date.year}-\${_date.month.toString().padLeft(2, '0')}-\${_date.day.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          trailing: const Icon(Icons.edit_calendar_rounded),
          onTap: _selectDate,
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'ISO Week Number',
          value: 'Week \$weekNum',
          secondaryLabel: 'Calendar Year',
          secondaryValue: '\${_date.year}',
          formula: 'ISO 8601 Week Standard',
          substitution: 'Week \$weekNum of \${_date.year}',
          onShare: () {},
        ),
      ],
    );
  }
}
