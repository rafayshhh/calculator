import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../history/providers/history_provider.dart';
import '../../domain/advanced_math_engine.dart';

class LogarithmScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const LogarithmScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<LogarithmScreen> createState() => _LogarithmScreenState();
}

class _LogarithmScreenState extends ConsumerState<LogarithmScreen> {
  String _value = '100';
  String _base = '10';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _value = map['value']?.toString() ?? '100';
        _base = map['base']?.toString() ?? '10';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _value = '100';
      _base = '10';
    });
  }

  void _logHistory(Map<String, dynamic> res) {
    try {
      final stateJson = jsonEncode({'value': _value, 'base': _base});
      ref
          .read(historyProvider.notifier)
          .add(
            'log_$_base($_value)',
            (res['result'] as double).toStringAsFixed(4),
            toolRoute: '/tools/math/advanced/logarithm',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result;
    String? errorMessage;

    try {
      final val = double.tryParse(_value);
      final b = double.tryParse(_base);
      if (val != null && b != null) {
        result = AdvancedMathEngine.calculateLogarithm(value: val, base: b);
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    return ToolPageScaffold(
      toolId: 'logarithm',
      title: 'Logarithm Calculator',
      description: 'Evaluate natural log (ln), common log (log₁₀), and arbitrary base logarithms.',
      icon: Icons.functions_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Value (x, where x > 0)',
          value: _value,
          onChanged: (val) => setState(() => _value = val),
        ),
        const SizedBox(height: KSpacing.sm),
        PremiumNumericField(
          label: 'Logarithm Base (b, where b > 0, b ≠ 1)',
          value: _base,
          onChanged: (val) => setState(() => _base = val),
        ),
        const SizedBox(height: KSpacing.md),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('log₁₀ (Base 10)'),
              onPressed: () => setState(() => _base = '10'),
            ),
            ActionChip(
              label: const Text('ln (Base e = 2.718)'),
              onPressed: () => setState(() => _base = '2.718281828'),
            ),
            ActionChip(
              label: const Text('log₂ (Base 2)'),
              onPressed: () => setState(() => _base = '2'),
            ),
          ],
        ),
      ],
      results: [
        if (errorMessage != null)
          ResultDisplayCard(
            label: 'Domain Error',
            value: errorMessage,
            isError: true,
          )
        else if (result != null) ...[
          ResultDisplayCard(
            label: 'log_$_base($_value)',
            value: (result['result'] as double)
                .toStringAsFixed(6)
                .replaceAll(RegExp(r'\.?0+$'), ''),
            secondaryLabel: 'Natural Log ln($_value)',
            secondaryValue: (result['naturalLog'] as double).toStringAsFixed(6),
            formula: result['formula'],
            substitution: result['substitution'],
            details:
                'Common Log log₁₀($_value) = ${(result['log10'] as double).toStringAsFixed(6)}',
            onReset: _reset,
            onShare: () => _logHistory(result!),
          ),
        ],
      ],
    );
  }
}
