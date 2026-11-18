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

class ExponentRootScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ExponentRootScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ExponentRootScreen> createState() => _ExponentRootScreenState();
}

class _ExponentRootScreenState extends ConsumerState<ExponentRootScreen> {
  String _base = '27';
  String _exponent = '2';
  String _rootDegree = '3';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _base = map['base']?.toString() ?? '27';
        _exponent = map['exponent']?.toString() ?? '2';
        _rootDegree = map['rootDegree']?.toString() ?? '3';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _base = '27';
      _exponent = '2';
      _rootDegree = '3';
    });
  }

  void _logHistory(Map<String, dynamic> res) {
    try {
      final stateJson = jsonEncode({
        'base': _base,
        'exponent': _exponent,
        'rootDegree': _rootDegree,
      });
      ref
          .read(historyProvider.notifier)
          .add(
            '$_base^$_exponent & ^$_rootDegree√$_base',
            'Power: ${(res['powerResult'] as double).toStringAsFixed(2)}, Root: ${(res['rootResult'] as double).toStringAsFixed(2)}',
            toolRoute: '/tools/math/advanced/exponent',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result;
    String? errorMessage;

    try {
      final b = double.tryParse(_base);
      final exp = double.tryParse(_exponent);
      final deg = double.tryParse(_rootDegree);
      if (b != null && exp != null && deg != null) {
        result = AdvancedMathEngine.calculateExponentAndRoot(
          base: b,
          exponent: exp,
          rootDegree: deg,
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    return ToolPageScaffold(
      toolId: 'exponent',
      title: 'Exponents & Roots',
      description: 'Compute powers, square roots, cube roots, and general nth-degree radical roots.',
      icon: Icons.superscript_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        PremiumNumericField(
          label: 'Base Number (b)',
          value: _base,
          onChanged: (val) => setState(() => _base = val),
        ),
        const SizedBox(height: KSpacing.sm),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Exponent (x for b^x)',
                value: _exponent,
                onChanged: (val) => setState(() => _exponent = val),
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: PremiumNumericField(
                label: 'Root Degree (n for ⁿ√b)',
                value: _rootDegree,
                onChanged: (val) => setState(() => _rootDegree = val),
              ),
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
            label: 'Power Result ($_base^$_exponent)',
            value: (result['powerResult'] as double)
                .toStringAsFixed(4)
                .replaceAll(RegExp(r'\.?0+$'), ''),
            secondaryLabel: 'Radical Root (^$_rootDegree√$_base)',
            secondaryValue: (result['rootResult'] as double)
                .toStringAsFixed(4)
                .replaceAll(RegExp(r'\.?0+$'), ''),
            formula: 'Power: y = b^x  |  Root: y = b^(1/n)',
            substitution:
                '${result['powerSubstitution']}\n${result['rootSubstitution']}',
            details: result['squareRoot'] != null
                ? 'Square Root √$_base = ${(result['squareRoot'] as double).toStringAsFixed(4)}'
                : null,
            onReset: _reset,
            onShare: () => _logHistory(result!),
          ),
        ],
      ],
    );
  }
}
