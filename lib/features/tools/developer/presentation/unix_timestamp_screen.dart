import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../domain/developer_engine.dart';

class UnixTimestampScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const UnixTimestampScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<UnixTimestampScreen> createState() => _UnixTimestampScreenState();
}

class _UnixTimestampScreenState extends ConsumerState<UnixTimestampScreen> {
  final TextEditingController _secController = TextEditingController();
  DateTime _dateTime = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _secController.text = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
    _convertFromSec();
  }

  @override
  void dispose() {
    _secController.dispose();
    super.dispose();
  }

  void _convertFromSec() {
    final sec = int.tryParse(_secController.text.trim());
    if (sec != null) {
      setState(() {
        _dateTime = DeveloperEngine.timestampToDateTime(sec);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'unix_timestamp',
      title: 'Unix Timestamp Converter',
      description: 'Convert between Unix epoch integer seconds/milliseconds and human date strings.',
      icon: Icons.access_time_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _secController.text = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
        _convertFromSec();
      },
      inputs: [
        TextField(
          controller: _secController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Unix Timestamp (Seconds)',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _convertFromSec(),
        ),
      ],
      results: [
        ResultDisplayCard(
          label: 'UTC Human Date/Time',
          value: _dateTime.toIso8601String().replaceAll('T', ' ').split('.').first,
          secondaryLabel: 'Local Time',
          secondaryValue: _dateTime.toLocal().toIso8601String().replaceAll('T', ' ').split('.').first,
          formula: 'Epoch = Seconds since 1970-01-01 00:00:00 UTC',
          substitution: '${_secController.text} = ${_dateTime.toIso8601String()}',
          onShare: () {},
        ),
        const SizedBox(height: KSpacing.md),
        KStatRow(label: 'Milliseconds (ms)', value: '${_dateTime.millisecondsSinceEpoch}'),
      ],
    );
  }
}
