import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/advanced_statistics_engine.dart';

class ConfidenceIntervalScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ConfidenceIntervalScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ConfidenceIntervalScreen> createState() => _ConfidenceIntervalScreenState();
}

class _ConfidenceIntervalScreenState extends ConsumerState<ConfidenceIntervalScreen> {
  String _mean = '50.0';
  String _stdDev = '8.0';
  String _n = '36';
  String _level = '95.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _mean = map['mean']?.toString() ?? '50.0';
        _stdDev = map['stdDev']?.toString() ?? '8.0';
        _n = map['n']?.toString() ?? '36';
        _level = map['level']?.toString() ?? '95.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _mean = '50.0';
      _stdDev = '8.0';
      _n = '36';
      _level = '95.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'mean': _mean, 'stdDev': _stdDev, 'n': _n, 'level': _level});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/math/confidence_interval',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final mean = double.tryParse(_mean) ?? 0.0;
    final stdDev = double.tryParse(_stdDev) ?? 1.0;
    final n = int.tryParse(_n) ?? 30;
    final level = double.tryParse(_level) ?? 95.0;
    final res = AdvancedStatisticsEngine.confidenceIntervalMean(
      sampleMean: mean,
      sampleStdDev: stdDev,
      sampleSize: n,
      confidenceLevelPercent: level,
    );
    final intStr = res['intervalString'] as String? ?? 'N/A';
    final me = res['marginOfError'] as double? ?? 0.0;
    final se = res['standardError'] as double? ?? 0.0;

    return ToolPageScaffold(
      title: 'Confidence Interval for Population Mean',
      description: 'Computes standard error, margin of error, and confidence bounds [Lower, Upper]',
      formula: 'CI = x̄ ± Z* · (s / √n)',
      onReset: _reset,
      onSave: () => _logHistory('$level% CI for mean=$mean, n=$n', '$intStr (ME: ±${me.toStringAsFixed(2)})'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: '$intStr',
          details: 'Confidence Level: $level%\nMargin of Error: ±${me.toStringAsFixed(4)}\nStandard Error: ${se.toStringAsFixed(4)}\nCritical Value Z*: ${res['zCritical'] ?? 1.96}',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Sample Mean x̄',
            initialValue: _mean,
            onChanged: (val) => setState(() => _mean = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Sample Std Dev s',
            initialValue: _stdDev,
            onChanged: (val) => setState(() => _stdDev = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Sample Size n',
            initialValue: _n,
            onChanged: (val) => setState(() => _n = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Confidence Level %',
            initialValue: _level,
            onChanged: (val) => setState(() => _level = val),
          ),
      ],
    );
  }
}
