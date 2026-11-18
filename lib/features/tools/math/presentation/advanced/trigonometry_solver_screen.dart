import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/k_spacing.dart';
import '../../../../../core/widgets/k_stat_row.dart';
import '../../../../../core/widgets/premium_numeric_field.dart';
import '../../../../../core/widgets/result_display_card.dart';
import '../../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../history/providers/history_provider.dart';

class TrigonometrySolverScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const TrigonometrySolverScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TrigonometrySolverScreen> createState() => _TrigonometrySolverScreenState();
}

class _TrigonometrySolverScreenState extends ConsumerState<TrigonometrySolverScreen> {
  String _angle = '45.0';
  bool _isDegrees = true;
  double? _sin;
  double? _cos;
  double? _tan;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final a = double.tryParse(_angle);
    if (a == null) return;

    final rad = _isDegrees ? a * (math.pi / 180.0) : a;
    setState(() {
      _sin = math.sin(rad);
      _cos = math.cos(rad);
      _tan = _cos!.abs() > 1e-12 ? math.tan(rad) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'trigonometry_solver',
      title: 'Trigonometry Solver',
      description: 'Evaluate sine, cosine, tangent, and trigonometric functions in degrees or radians.',
      icon: Icons.details_rounded,
      onBack: () => context.pop(),
      onRefresh: () => setState(() {
        _angle = '45.0';
        _isDegrees = true;
        _calculate();
      }),
      inputs: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Degrees (°)')),
            ButtonSegment(value: false, label: Text('Radians (rad)')),
          ],
          selected: {_isDegrees},
          onSelectionChanged: (s) {
            setState(() => _isDegrees = s.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Angle (θ)',
          suffix: _isDegrees ? '°' : 'rad',
          value: _angle,
          onChanged: (v) {
            _angle = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_sin != null && _cos != null) ...[
          ResultDisplayCard(
            label: 'Sine sin(θ)',
            value: _sin!.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+\$'), ''),
            secondaryLabel: 'Cosine cos(θ)',
            secondaryValue: _cos!.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+\$'), ''),
            formula: 'tan(θ) = sin(θ) / cos(θ)',
            substitution: 'tan(θ) = ${_tan != null ? _tan!.toStringAsFixed(6) : "Undefined"}',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Tangent tan(θ)', value: _tan != null ? _tan!.toStringAsFixed(6) : 'Undefined (Asymptote)'),
        ],
      ],
    );
  }
}
