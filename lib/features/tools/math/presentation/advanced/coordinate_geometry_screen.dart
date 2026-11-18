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

class CoordinateGeometryScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CoordinateGeometryScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CoordinateGeometryScreen> createState() =>
      _CoordinateGeometryScreenState();
}

class _CoordinateGeometryScreenState
    extends ConsumerState<CoordinateGeometryScreen> {
  String _x1 = '0', _y1 = '0';
  String _x2 = '3', _y2 = '4';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null &&
        widget.initialStateJson!.isNotEmpty) {
      try {
        final map =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _x1 = map['x1']?.toString() ?? '0';
        _y1 = map['y1']?.toString() ?? '0';
        _x2 = map['x2']?.toString() ?? '3';
        _y2 = map['y2']?.toString() ?? '4';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _x1 = '0';
      _y1 = '0';
      _x2 = '3';
      _y2 = '4';
    });
  }

  void _logHistory(Map<String, dynamic> res) {
    try {
      final stateJson = jsonEncode({
        'x1': _x1,
        'y1': _y1,
        'x2': _x2,
        'y2': _y2,
      });
      ref
          .read(historyProvider.notifier)
          .add(
            'Points ($_x1, $_y1) & ($_x2, $_y2)',
            'Dist: ${(res['distance'] as double).toStringAsFixed(2)}, Eq: ${res['lineEquation']}',
            toolRoute: '/tools/math/advanced/coordinate_geometry',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? result;
    String? errorMessage;

    try {
      final px1 = double.parse(_x1);
      final py1 = double.parse(_y1);
      final px2 = double.parse(_x2);
      final py2 = double.parse(_y2);

      result = AdvancedMathEngine.calculateCoordinateGeometry(
        x1: px1,
        y1: py1,
        x2: px2,
        y2: py2,
      );
    } catch (e) {
      errorMessage = e.toString().replaceAll('ArgumentError: ', '');
    }

    return ToolPageScaffold(
      toolId: 'coordinate_geometry',
      title: 'Coordinate Geometry',
      description: 'Compute Euclidean distance, midpoint, line slope, and linear equations between 2D points.',
      icon: Icons.timeline_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const Text(
          'Point 1 (x₁, y₁):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'x₁',
                value: _x1,
                onChanged: (v) => setState(() => _x1 = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PremiumNumericField(
                label: 'y₁',
                value: _y1,
                onChanged: (v) => setState(() => _y1 = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        const Text(
          'Point 2 (x₂, y₂):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: PremiumNumericField(
                label: 'x₂',
                value: _x2,
                onChanged: (v) => setState(() => _x2 = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PremiumNumericField(
                label: 'y₂',
                value: _y2,
                onChanged: (v) => setState(() => _y2 = v),
              ),
            ),
          ],
        ),
      ],
      results: [
        if (errorMessage != null)
          ResultDisplayCard(
            label: 'Geometry Error',
            value: errorMessage,
            isError: true,
          )
        else if (result != null) ...[
          ResultDisplayCard(
            label: 'Distance Between Points',
            value: (result['distance'] as double)
                .toStringAsFixed(4)
                .replaceAll(RegExp(r'\.?0+$'), ''),
            secondaryLabel: 'Midpoint',
            secondaryValue: result['midpoint'] as String,
            formula: result['formula'],
            substitution: result['substitution'],
            details:
                'Line Equation: ${result['lineEquation']}${result['slope'] != null ? "\nSlope (m): ${(result['slope'] as double).toStringAsFixed(4)}" : ""}',
            onReset: _reset,
            onShare: () => _logHistory(result!),
          ),
        ],
      ],
    );
  }
}
