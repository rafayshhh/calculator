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

class AgeCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const AgeCalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends ConsumerState<AgeCalculatorScreen> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  DateTime _asOfDate = DateTime.now();

  AgeResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        if (data['birthDate'] != null) _birthDate = DateTime.parse(data['birthDate']);
        if (data['asOfDate'] != null) _asOfDate = DateTime.parse(data['asOfDate']);
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final res = DateTimeEngine.calculateAge(birthDate: _birthDate, asOfDate: _asOfDate);
    setState(() {
      _result = res;
    });

    final stateJson = jsonEncode({
      'birthDate': _birthDate.toIso8601String(),
      'asOfDate': _asOfDate.toIso8601String(),
    });

    ref.read(historyProvider.notifier).add(
      'Age: ${_result!.years} years, ${_result!.months} months',
      '${_result!.years} Years',
      toolRoute: '/tools/date_time/age',
      toolStateJson: stateJson,
    );
  }

  Future<void> _selectDate(bool isBirth) async {
    final initial = isBirth ? _birthDate : _asOfDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isBirth) {
          _birthDate = picked;
        } else {
          _asOfDate = picked;
        }
      });
      _calculate();
    }
  }

  String _format(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'age',
      title: 'Age Calculator',
      description: 'Calculate precise biological age in years, months, days, and total hours.',
      icon: Icons.cake_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        setState(() {
          _birthDate = DateTime(2000, 1, 1);
          _asOfDate = DateTime.now();
        });
        _calculate();
      },
      inputs: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
                title: const Text('Date of Birth', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_format(_birthDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.calendar_today_rounded, size: 18),
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white24)),
                title: const Text('Age as of Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_format(_asOfDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.event_rounded, size: 18),
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_result != null) ...[
          ResultDisplayCard(
            label: 'Current Age',
            value: "${_result!.years} Years",
            secondaryLabel: 'Exact Breakdown',
            secondaryValue: '${_result!.months} months, ${_result!.days} days',
            formula: 'Age = AsOfDate - BirthDate',
            substitution: '${_result!.years}y ${_result!.months}m ${_result!.days}d',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Total Days Lived', value: '${_result!.totalDays} days'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Total Weeks Lived', value: '${_result!.totalWeeks} weeks'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Days to Next Birthday', value: '${_result!.nextBirthdayDays} days'),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Day Born', value: _result!.dayOfWeekBorn),
        ],
      ],
    );
  }
}
