import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';

class TimeZoneConverterScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TimeZoneConverterScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TimeZoneConverterScreen> createState() => _TimeZoneConverterScreenState();
}

class _TimeZoneConverterScreenState extends ConsumerState<TimeZoneConverterScreen> {
  DateTime _utcTime = DateTime.now().toUtc();
  int _targetOffset = 5; // PKT (UTC+5)

  final Map<String, int> _zones = {
    'UTC / GMT': 0,
    'EST (UTC-5)': -5,
    'CST (UTC-6)': -6,
    'PST (UTC-8)': -8,
    'CET (UTC+1)': 1,
    'PKT (UTC+5)': 5,
    'IST (UTC+5:30)': 5,
    'JST (UTC+9)': 9,
    'AEST (UTC+10)': 10,
  };

  String _format(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final converted = _utcTime.add(Duration(hours: _targetOffset));

    return ToolPageScaffold(
      toolId: 'time_zone',
      title: 'Time Zone Converter',
      description: 'Convert date and clock times between international timezone offsets.',
      icon: Icons.public_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() => _utcTime = DateTime.now().toUtc()),
      inputs: [
        DropdownButtonFormField<int>(
          initialValue: _targetOffset,
          decoration: const InputDecoration(labelText: 'Target Time Zone', border: OutlineInputBorder()),
          items: _zones.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _targetOffset = v);
          },
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'Target Zone Time',
          value: _format(converted),
          secondaryLabel: 'UTC Standard Time',
          secondaryValue: _format(_utcTime),
          formula: 'T_target = UTC + Offset',
          substitution: 'Offset: UTC${_targetOffset >= 0 ? "+" : ""}$_targetOffset:00',
          onShare: () {},
        ),
      ],
    );
  }
}
