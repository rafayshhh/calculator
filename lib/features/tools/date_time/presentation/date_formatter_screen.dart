import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../domain/date_time_engine.dart';

class DateFormatterScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DateFormatterScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DateFormatterScreen> createState() => _DateFormatterScreenState();
}

class _DateFormatterScreenState extends ConsumerState<DateFormatterScreen> {
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
    final iso = _date.toIso8601String().split('T').first;
    final us = '\${_date.month.toString().padLeft(2, '0')}/\${_date.day.toString().padLeft(2, '0')}/\${_date.year}';
    final eu = '\${_date.day.toString().padLeft(2, '0')}/\${_date.month.toString().padLeft(2, '0')}/\${_date.year}';
    final weekday = DateTimeEngine.getWeekdayName(_date.weekday);

    return ToolPageScaffold(
      toolId: 'date_formatter',
      title: 'Date Formatter',
      description: 'Convert and inspect international date strings and standards.',
      icon: Icons.format_paint_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() => _date = DateTime.now()),
      inputs: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
          title: const Text('Selected Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(iso, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          trailing: const Icon(Icons.edit_calendar_rounded),
          onTap: _selectDate,
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'ISO 8601 Standard',
          value: iso,
          secondaryLabel: 'Day of Week',
          secondaryValue: weekday,
          formula: 'Standard YYYY-MM-DD',
          substitution: iso,
          onShare: () {},
        ),
        const SizedBox(height: KSpacing.md),
        KStatRow(label: 'US Format (MM/DD/YYYY)', value: us),
        const SizedBox(height: KSpacing.xs),
        KStatRow(label: 'European Format (DD/MM/YYYY)', value: eu),
        const SizedBox(height: KSpacing.xs),
        KStatRow(label: 'Unix Epoch Seconds', value: '\${_date.millisecondsSinceEpoch ~/ 1000}'),
      ],
    );
  }
}
