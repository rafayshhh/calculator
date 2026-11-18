import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CountdownScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen> {
  DateTime _targetDate = DateTime.now().add(const Duration(days: 100));

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['targetDate'] != null) _targetDate = DateTime.parse(data['targetDate']);
      } catch (_) {}
    }
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = _targetDate.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    return ToolPageScaffold(
      toolId: 'countdown',
      title: 'Event Countdown',
      description: 'Compute precise remaining time until target events or deadlines.',
      icon: Icons.hourglass_bottom_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() => _targetDate = DateTime.now().add(const Duration(days: 100))),
      inputs: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
          title: const Text('Target Event Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text('\${_targetDate.year}-\${_targetDate.month.toString().padLeft(2, '0')}-\${_targetDate.day.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          trailing: const Icon(Icons.event_repeat_rounded),
          onTap: _selectTargetDate,
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'Time Remaining',
          value: '\$days Days',
          secondaryLabel: 'Hours & Minutes',
          secondaryValue: '\$hours hrs, \$minutes mins',
          formula: 'Remaining = TargetDate - Now',
          substitution: '\$days days, \$hours hours remaining',
          onShare: () {},
        ),
        const SizedBox(height: KSpacing.md),
        KStatRow(label: 'Total Hours Remaining', value: '\${diff.inHours} hours'),
        const SizedBox(height: KSpacing.xs),
        KStatRow(label: 'Total Minutes Remaining', value: '\${diff.inMinutes} minutes'),
      ],
    );
  }
}
