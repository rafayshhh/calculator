import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/date_time_engine.dart';

enum TimestampInputMode { unixSeconds, unixMilliseconds, dateTime, iso8601 }

class TimestampConverterScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TimestampConverterScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TimestampConverterScreen> createState() =>
      _TimestampConverterScreenState();
}

class _TimestampConverterScreenState
    extends ConsumerState<TimestampConverterScreen> {
  TimestampInputMode _mode = TimestampInputMode.unixSeconds;
  String _inputSeconds = '1750000000';
  String _inputMillis = '1750000000000';
  DateTime _selectedDate = DateTime.now();
  String _isoString = DateTime.now().toUtc().toIso8601String();

  late final TextEditingController _isoStringController;

  TimestampResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final modeStr = data['mode'] ?? 'unixSeconds';
        _mode = TimestampInputMode.values.firstWhere(
          (e) => e.name == modeStr,
          orElse: () => TimestampInputMode.unixSeconds,
        );
        _inputSeconds = data['inputSeconds'] ?? '1750000000';
        _inputMillis = data['inputMillis'] ?? '1750000000000';
        if (data['selectedDate'] != null) {
          _selectedDate = DateTime.parse(data['selectedDate']);
        }
        _isoString =
            data['isoString'] ?? DateTime.now().toUtc().toIso8601String();
      } catch (_) {}
    }
    _isoStringController = TextEditingController(text: _isoString);
    _calculate();
  }

  @override
  void didUpdateWidget(covariant TimestampConverterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isoString != _isoStringController.text) {
      _isoStringController.text = _isoString;
    }
  }

  @override
  void dispose() {
    _isoStringController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      TimestampResult res;
      switch (_mode) {
        case TimestampInputMode.unixSeconds:
          final sec = int.tryParse(_inputSeconds.trim());
          if (sec == null) {
            setState(() {
              _result = null;
              _error = 'Please enter a valid integer second timestamp';
            });
            return;
          }
          res = DateTimeEngine.convertTimestamp(unixSeconds: sec);
          break;
        case TimestampInputMode.unixMilliseconds:
          final ms = int.tryParse(_inputMillis.trim());
          if (ms == null) {
            setState(() {
              _result = null;
              _error = 'Please enter a valid integer millisecond timestamp';
            });
            return;
          }
          res = DateTimeEngine.convertTimestamp(unixMilliseconds: ms);
          break;
        case TimestampInputMode.dateTime:
          res = DateTimeEngine.convertTimestamp(dateTime: _selectedDate);
          break;
        case TimestampInputMode.iso8601:
          if (_isoString.trim().isEmpty) {
            setState(() {
              _result = null;
              _error = 'Please enter an ISO 8601 string';
            });
            return;
          }
          res = DateTimeEngine.convertTimestamp(isoString: _isoString.trim());
          break;
      }

      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({
        'mode': _mode.name,
        'inputSeconds': _inputSeconds,
        'inputMillis': _inputMillis,
        'selectedDate': _selectedDate.toIso8601String(),
        'isoString': _isoString,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Timestamp: ${res.unixSeconds} s',
            '${res.iso8601Utc} (Local: ${res.formattedLocal})',
            toolRoute: '/tools/date_time/timestamp',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e
            .toString()
            .replaceAll('ArgumentError: ', '')
            .replaceAll('Invalid argument(s): ', '');
      });
    }
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _mode = TimestampInputMode.unixSeconds;
      _inputSeconds = (now.millisecondsSinceEpoch ~/ 1000).toString();
      _inputMillis = now.millisecondsSinceEpoch.toString();
      _selectedDate = now;
      _isoString = now.toUtc().toIso8601String();
      if (_isoStringController.text != _isoString) {
        _isoStringController.text = _isoString;
      }
    });
    _calculate();
  }

  void _setNow() {
    final now = DateTime.now();
    setState(() {
      _inputSeconds = (now.millisecondsSinceEpoch ~/ 1000).toString();
      _inputMillis = now.millisecondsSinceEpoch.toString();
      _selectedDate = now;
      _isoString = now.toUtc().toIso8601String();
      if (_isoStringController.text != _isoString) {
        _isoStringController.text = _isoString;
      }
    });
    _calculate();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        _calculate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimaryColor = isDark
        ? KColors.textPrimaryDark
        : KColors.textPrimaryLight;
    final textSecondaryColor = isDark
        ? KColors.textSecondaryDark
        : KColors.textSecondaryLight;

    if (_isoStringController.text != _isoString) {
      _isoStringController.text = _isoString;
    }

    return FinancialToolScaffold(
      toolId: 'timestamp',
      title: 'Timestamp Converter',
      description: 'Bidirectional converter between Unix seconds, milliseconds, UTC, Local DateTime, and ISO 8601',
      icon: Icons.schedule_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<TimestampInputMode>(
            segments: const [
              ButtonSegment(
                value: TimestampInputMode.unixSeconds,
                label: Text('Seconds (s)'),
              ),
              ButtonSegment(
                value: TimestampInputMode.unixMilliseconds,
                label: Text('Millis (ms)'),
              ),
              ButtonSegment(
                value: TimestampInputMode.dateTime,
                label: Text('Date Picker'),
              ),
              ButtonSegment(
                value: TimestampInputMode.iso8601,
                label: Text('ISO 8601'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (set) {
              setState(() => _mode = set.first);
              _calculate();
            },
          ),
        ),
        const SizedBox(height: KSpacing.md),
        if (_mode == TimestampInputMode.unixSeconds) ...[
          Row(
            children: [
              Expanded(
                child: PremiumNumericField(
                  label: 'Unix Timestamp (Seconds)',
                  value: _inputSeconds,
                  onChanged: (val) {
                    _inputSeconds = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              ElevatedButton.icon(
                onPressed: _setNow,
                icon: const Icon(Icons.access_time, size: 16),
                label: const Text('Now'),
              ),
            ],
          ),
        ] else if (_mode == TimestampInputMode.unixMilliseconds) ...[
          Row(
            children: [
              Expanded(
                child: PremiumNumericField(
                  label: 'Unix Timestamp (Milliseconds)',
                  value: _inputMillis,
                  onChanged: (val) {
                    _inputMillis = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              ElevatedButton.icon(
                onPressed: _setNow,
                icon: const Icon(Icons.access_time, size: 16),
                label: const Text('Now'),
              ),
            ],
          ),
        ] else if (_mode == TimestampInputMode.dateTime) ...[
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(16),
                  child: KGlassCard(
                    padding: const EdgeInsets.all(KSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Local Date & Time',
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDate.toLocal().toString().split('.')[0],
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              ElevatedButton.icon(
                onPressed: _setNow,
                icon: const Icon(Icons.access_time, size: 16),
                label: const Text('Now'),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? KColors.surfaceElevatedDark
                        : KColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? KColors.glassBorderDark
                          : KColors.glassBorderLight,
                    ),
                  ),
                  child: TextField(
                    controller: _isoStringController,
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(KSpacing.md),
                      labelText: 'ISO 8601 String (e.g. 2026-08-16T12:00:00Z)',
                    ),
                    onChanged: (val) {
                      _isoString = val;
                      _calculate();
                    },
                  ),
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              ElevatedButton.icon(
                onPressed: _setNow,
                icon: const Icon(Icons.access_time, size: 16),
                label: const Text('Now'),
              ),
            ],
          ),
        ],
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(
            label: 'Conversion Error',
            value: _error!,
            isError: true,
          )
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Unix Timestamp (Seconds)',
            value: '${_result!.unixSeconds}',
            secondaryLabel: 'Milliseconds',
            secondaryValue: '${_result!.unixMilliseconds} ms',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date & Time Formats',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                _buildCopyableRow('UTC Date/Time:', _result!.formattedUtc),
                _buildCopyableRow('Local Date/Time:', _result!.formattedLocal),
                _buildCopyableRow('ISO 8601 (UTC):', _result!.iso8601Utc),
                _buildCopyableRow('ISO 8601 (Local):', _result!.iso8601Local),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCopyableRow(String label, String val) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? KColors.textSecondaryDark
                  : KColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    val,
                    style: TextStyle(
                      color: isDark
                          ? KColors.textPrimaryDark
                          : KColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: val));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied: $val'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
