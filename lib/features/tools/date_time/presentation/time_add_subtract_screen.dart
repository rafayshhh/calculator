import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';

class TimeAddSubtractScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TimeAddSubtractScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TimeAddSubtractScreen> createState() => _TimeAddSubtractScreenState();
}

class _TimeAddSubtractScreenState extends ConsumerState<TimeAddSubtractScreen> {
  TimeOfDay _initialTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isAdd = true;
  String _hours = '2';
  String _minutes = '30';

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _initialTime);
    if (picked != null) setState(() => _initialTime = picked);
  }

  String _formatTod(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final h = int.tryParse(_hours) ?? 0;
    final m = int.tryParse(_minutes) ?? 0;
    final totalDelta = (h * 60 + m) * (_isAdd ? 1 : -1);

    int totalMin = (_initialTime.hour * 60 + _initialTime.minute + totalDelta) % (24 * 60);
    if (totalMin < 0) totalMin += 24 * 60;
    final outTime = TimeOfDay(hour: totalMin ~/ 60, minute: totalMin % 60);

    return ToolPageScaffold(
      toolId: 'time_add_subtract',
      title: 'Time Add / Subtract',
      description: 'Add or subtract hours and minutes from any clock time.',
      icon: Icons.more_time_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() {
        _initialTime = const TimeOfDay(hour: 12, minute: 0);
        _isAdd = true;
        _hours = '2';
        _minutes = '30';
      }),
      inputs: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
          title: const Text('Base Clock Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(_formatTod(_initialTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          trailing: const Icon(Icons.access_time_rounded),
          onTap: _selectTime,
        ),
        const SizedBox(height: KSpacing.md),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('+ Add Time')),
            ButtonSegment(value: false, label: Text('- Subtract Time')),
          ],
          selected: {_isAdd},
          onSelectionChanged: (s) => setState(() => _isAdd = s.first),
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Hours',
                suffix: 'hrs',
                value: _hours,
                onChanged: (v) => setState(() => _hours = v),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Minutes',
                suffix: 'mins',
                value: _minutes,
                onChanged: (v) => setState(() => _minutes = v),
              ),
            ),
          ],
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'Computed Clock Time',
          value: _formatTod(outTime),
          secondaryLabel: 'Delta',
          secondaryValue: '${_isAdd ? "+" : "-"}\$h h \$m m',
          formula: 'Time_out = Time_in ± ΔTime',
          substitution: '${_formatTod(_initialTime)} ${_isAdd ? "+" : "-"} \$h h \$m m = ${_formatTod(outTime)}',
          onShare: () {},
        ),
      ],
    );
  }
}
