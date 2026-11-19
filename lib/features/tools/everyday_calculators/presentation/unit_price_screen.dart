import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/everyday_engine.dart';

class UnitPriceScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const UnitPriceScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<UnitPriceScreen> createState() => _UnitPriceScreenState();
}

class _UnitPriceScreenState extends ConsumerState<UnitPriceScreen> {
  String _priceA = '12.99';
  String _qtyA = '500';
  String _priceB = '19.99';
  String _qtyB = '850';

  double? _unitA;
  double? _unitB;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _priceA = data['priceA']?.toString() ?? '12.99';
        _qtyA = data['qtyA']?.toString() ?? '500';
        _priceB = data['priceB']?.toString() ?? '19.99';
        _qtyB = data['qtyB']?.toString() ?? '850';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final pa = double.tryParse(_priceA);
    final qa = double.tryParse(_qtyA);
    final pb = double.tryParse(_priceB);
    final qb = double.tryParse(_qtyB);

    if (pa == null || qa == null || pa < 0 || qa <= 0) {
      setState(() {
        _unitA = null;
        _unitB = null;
        _error = 'Please enter valid positive price and quantity for Option A';
      });
      return;
    }

    try {
      final ua = EverydayEngine.calculateUnitPrice(pa, qa);
      double? ub;
      if (pb != null && qb != null && pb >= 0 && qb > 0) {
        ub = EverydayEngine.calculateUnitPrice(pb, qb);
      }

      setState(() {
        _error = null;
        _unitA = ua;
        _unitB = ub;
      });

      final stateJson = jsonEncode({'priceA': _priceA, 'qtyA': _qtyA, 'priceB': _priceB, 'qtyB': _qtyB});
      ref.read(historyProvider.notifier).add(
        'Unit Price: \$$_priceA / $_qtyA units',
        '\$${ua.toStringAsFixed(4)}/unit',
        toolRoute: '/tools/everyday/unit_price',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _unitA = null;
        _unitB = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _priceA = '12.99';
      _qtyA = '500';
      _priceB = '19.99';
      _qtyB = '850';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    String bestDeal = 'Option A';
    if (_unitA != null && _unitB != null) {
      if (_unitA! < _unitB!) {
        final diff = ((_unitB! - _unitA!) / _unitB!) * 100;
        bestDeal = 'Option A is cheaper by ${diff.toStringAsFixed(1)}%';
      } else if (_unitB! < _unitA!) {
        final diff = ((_unitA! - _unitB!) / _unitA!) * 100;
        bestDeal = 'Option B is cheaper by ${diff.toStringAsFixed(1)}%';
      } else {
        bestDeal = 'Both options have identical unit pricing';
      }
    }

    return ToolPageScaffold(
      toolId: 'unit_price',
      title: 'Unit Price Comparison',
      description: 'Find the best deal by comparing price per unit across packaging sizes.',
      icon: Icons.shopping_basket_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text('Option A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: KSpacing.xs),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Total Price A',
                prefix: '\$',
                value: _priceA,
                onChanged: (v) {
                  _priceA = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Quantity A',
                suffix: 'units',
                value: _qtyA,
                onChanged: (v) {
                  _qtyA = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.lg),
        const Text('Option B (Comparison)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: KSpacing.xs),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'Total Price B',
                prefix: '\$',
                value: _priceB,
                onChanged: (v) {
                  _priceB = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: PremiumNumericField(
                label: 'Quantity B',
                suffix: 'units',
                value: _qtyB,
                onChanged: (v) {
                  _qtyB = v;
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_unitA != null) ...[
          ResultDisplayCard(
            label: 'Option A Unit Price',
            value: '\$${_unitA!.toStringAsFixed(4)} / unit',
            secondaryLabel: _unitB != null ? 'Option B Unit Price' : null,
            secondaryValue: _unitB != null ? '\$${_unitB!.toStringAsFixed(4)} / unit' : null,
            formula: 'Unit Price = Total Price / Quantity',
            substitution: bestDeal,
            onShare: () {},
          ),
          if (_unitB != null) ...[
            const SizedBox(height: KSpacing.md),
            KStatRow(label: 'Comparison Winner', value: bestDeal),
          ],
        ],
      ],
    );
  }
}
