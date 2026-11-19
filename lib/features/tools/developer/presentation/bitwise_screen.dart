import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/developer_engine.dart';

class BitwiseScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const BitwiseScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<BitwiseScreen> createState() => _BitwiseScreenState();
}

class _BitwiseScreenState extends ConsumerState<BitwiseScreen> {
  String _valA = '42';
  String _valB = '15';
  String _op = 'AND';
  int _wordSize = 32;

  BitwiseResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _valA = data['valA']?.toString() ?? '42';
        _valB = data['valB']?.toString() ?? '15';
        _op = data['op'] ?? 'AND';
        _wordSize = data['wordSize'] ?? 32;
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      final res = DeveloperEngine.calculateBitwise(
        aString: _valA,
        bString: _op == 'NOT' ? null : _valB,
        operation: _op,
        wordSize: _wordSize,
      );
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'valA': _valA, 'valB': _valB, 'op': _op, 'wordSize': _wordSize});
      ref.read(historyProvider.notifier).add(
        'Bitwise: $_valA $_op ${_op == "NOT" ? "" : _valB}',
        res.decimal,
        toolRoute: '/tools/developer/bitwise',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _valA = '42';
      _valB = '15';
      _op = 'AND';
      _wordSize = 32;
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'bitwise',
      title: 'Bitwise Logic Operations',
      description: 'Perform bitwise AND, OR, XOR, NOT, NAND, NOR, and bitshifts across configurable bit widths.',
      icon: Icons.memory_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _valA,
                decoration: const InputDecoration(labelText: 'Operand A (Dec or 0x Hex)', border: OutlineInputBorder()),
                onChanged: (v) {
                  _valA = v.trim();
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            if (_op != 'NOT')
              Expanded(
                child: TextFormField(
                  initialValue: _valB,
                  decoration: const InputDecoration(labelText: 'Operand B (Dec or 0x Hex)', border: OutlineInputBorder()),
                  onChanged: (v) {
                    _valB = v.trim();
                    _calculate();
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Wrap(
          spacing: 8,
          children: ['AND', 'OR', 'XOR', 'NOT', 'SHL', 'SHR'].map((op) {
            return ChoiceChip(
              label: Text(op),
              selected: _op == op,
              onSelected: (s) {
                if (s) {
                  setState(() => _op = op);
                  _calculate();
                }
              },
            );
          }).toList(),
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Decimal Result',
            value: _result!.decimal,
            secondaryLabel: 'Hexadecimal',
            secondaryValue: _result!.hexadecimal,
            formula: '$_valA $_op ${_op == "NOT" ? "" : _valB}',
            substitution: 'Binary: ${_result!.binary}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Binary (Base 2)', value: _result!.binary),
          const SizedBox(height: KSpacing.xs),
          KStatRow(label: 'Octal (Base 8)', value: _result!.octal),
        ],
      ],
    );
  }
}
