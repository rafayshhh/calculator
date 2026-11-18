import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';

class TimeDifferenceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TimeDifferenceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TimeDifferenceScreen> createState() => _TimeDifferenceScreenState();
}

class _TimeDifferenceScreenState extends ConsumerState<TimeDifferenceScreen> {
  TimeOfDay _t1 = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _t2 = const TimeOfDay(hour: 17, minute: 30);

  Future<void> _selectTime(bool isFirst) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFirst ? _t1 : _t2,
    );
    if (picked != null) {
      setState(() {
        if (isFirst) {
          _t1 = picked;
        } else {
          _t2 = picked;
        }
      });
    }
  }

  String _formatTod(TimeOfDay t) => '\${t.hour.toString().padLeft(2, '0')}:\${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final min1 = _t1.hour * 60 + _t1.minute;
    final min2 = _t2.hour * 60 + _t2.minute;
    int diffMin = min2 - min1;
    if (diffMin < 0) diffMin += 24 * 60; // Cross midnight
    final hours = diffMin ~/ 60;
    final minutes = diffMin % 60;

    return ToolPageScaffold(
      toolId: 'time_difference',
      title: 'Time Difference',
      description: 'Calculate elapsed duration between two clock times across hours and minutes.',
      icon: Icons.timelapse_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() {
        _t1 = const TimeOfDay(hour: 9, minute: 0);
        _t2 = const TimeOfDay(hour: 17, minute: 30);
      }),
      inputs: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
                title: const Text('Start Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_formatTod(_t1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: const Icon(Icons.access_time_rounded),
                onTap: () => _selectTime(true),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
                title: const Text('End Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_formatTod(_t2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: const Icon(Icons.access_time_filled_rounded),
                onTap: () => _selectTime(false),
              ),
            ),
          ],
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'Elapsed Time',
          value: '\$hours hrs, \$minutes mins',
          secondaryLabel: 'Decimal Hours',
          secondaryValue: '\${(diffMin / 60.0).toStringAsFixed(2)} hrs',
          formula: 'Duration = Time₂ - Time₁',
          substitution: '\${_formatTod(_t1)} to \${_formatTod(_t2)} = \$hours h \$minutes m',
          onShare: () {},
        ),
        const SizedBox(height: KSpacing.md),
        KStatRow(label: 'Total Minutes', value: '\$diffMin minutes'),
      ],
    );
  }
}
