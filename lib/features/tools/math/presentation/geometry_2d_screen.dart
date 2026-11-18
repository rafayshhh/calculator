import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/math_advanced_engine.dart';

enum GeometryShape { rectangle, square, circle, triangle }

class Geometry2DScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const Geometry2DScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<Geometry2DScreen> createState() => _Geometry2DScreenState();
}

class _Geometry2DScreenState extends ConsumerState<Geometry2DScreen> {
  GeometryShape _shape = GeometryShape.rectangle;
  String _val1 = '10'; // length / side / radius / base
  String _val2 = '5'; // width / height

  Map<String, double>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final shapeStr = data['shape'] ?? 'rectangle';
        _shape = GeometryShape.values.firstWhere(
          (s) => s.name == shapeStr,
          orElse: () => GeometryShape.rectangle,
        );
        _val1 = data['val1'] ?? '10';
        _val2 = data['val2'] ?? '5';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final v1 = double.tryParse(_val1);
    final v2 = double.tryParse(_val2);

    if (v1 == null) {
      setState(() {
        _results = null;
        _error = 'Please enter valid positive dimensions';
      });
      return;
    }

    try {
      Map<String, double> res;
      String summary;

      switch (_shape) {
        case GeometryShape.rectangle:
          if (v2 == null) {
            setState(() {
              _results = null;
              _error = 'Please enter width';
            });
            return;
          }
          res = MathAdvancedEngine.calculateRectangle(v1, v2);
          summary = 'Rectangle ($v1×$v2)';
          break;
        case GeometryShape.square:
          res = MathAdvancedEngine.calculateSquare(v1);
          summary = 'Square (side $v1)';
          break;
        case GeometryShape.circle:
          res = MathAdvancedEngine.calculateCircle(v1);
          summary = 'Circle (r=$v1)';
          break;
        case GeometryShape.triangle:
          if (v2 == null) {
            setState(() {
              _results = null;
              _error = 'Please enter height';
            });
            return;
          }
          res = MathAdvancedEngine.calculateTriangle(v1, v2);
          summary = 'Triangle (b=$v1, h=$v2)';
          break;
      }

      setState(() {
        _results = res;
        _error = null;
      });

      final stateJson = jsonEncode({
        'shape': _shape.name,
        'val1': _val1,
        'val2': _val2,
      });

      final areaStr =
          res['area']?.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '') ??
          '0';
      ref
          .read(historyProvider.notifier)
          .add(
            '2D Geometry: $summary',
            'Area = $areaStr',
            toolRoute: '/tools/math/geometry_2d',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _results = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _shape = GeometryShape.rectangle;
      _val1 = '10';
      _val2 = '5';
    });
    _calculate();
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

    String label1 = 'Length';
    String? label2 = 'Width';
    String formula = 'Area = l × w';

    switch (_shape) {
      case GeometryShape.rectangle:
        label1 = 'Length';
        label2 = 'Width';
        formula = 'Area = l × w  |  Perimeter = 2(l + w)';
        break;
      case GeometryShape.square:
        label1 = 'Side Length (s)';
        label2 = null;
        formula = 'Area = s²  |  Perimeter = 4s';
        break;
      case GeometryShape.circle:
        label1 = 'Radius (r)';
        label2 = null;
        formula = 'Area = πr²  |  Circumference = 2πr';
        break;
      case GeometryShape.triangle:
        label1 = 'Base (b)';
        label2 = 'Height (h)';
        formula = 'Area = ½ × b × h';
        break;
    }

    final areaFormatted = _results?['area'] != null
        ? _results!['area']!
              .toStringAsFixed(4)
              .replaceAll(RegExp(r'\.?0+$'), '')
        : '0';

    final secondaryLabel = _shape == GeometryShape.circle
        ? 'Circumference'
        : 'Perimeter';
    final secondaryVal = _shape == GeometryShape.circle
        ? (_results?['circumference']
                  ?.toStringAsFixed(4)
                  .replaceAll(RegExp(r'\.?0+$'), '') ??
              '0')
        : (_results?['perimeter']
                  ?.toStringAsFixed(4)
                  .replaceAll(RegExp(r'\.?0+$'), '') ??
              '0');

    return FinancialToolScaffold(
      title: '2D Geometry',
      description: 'Calculate area, perimeter, and dimensions of shapes',
      icon: Icons.architecture_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<GeometryShape>(
          segments: const [
            ButtonSegment(value: GeometryShape.rectangle, label: Text('Rect')),
            ButtonSegment(value: GeometryShape.square, label: Text('Square')),
            ButtonSegment(value: GeometryShape.circle, label: Text('Circle')),
            ButtonSegment(
              value: GeometryShape.triangle,
              label: Text('Triangle'),
            ),
          ],
          selected: {_shape},
          onSelectionChanged: (set) {
            setState(() {
              _shape = set.first;
              if (_shape == GeometryShape.circle) {
                _val1 = '5';
              } else if (_shape == GeometryShape.square) {
                _val1 = '6';
              } else {
                _val1 = '10';
                _val2 = '5';
              }
            });
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.lg),
        PremiumNumericField(
          label: label1,
          value: _val1,
          onChanged: (val) {
            _val1 = val;
            _calculate();
          },
        ),
        if (label2 != null) ...[
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: label2,
            value: _val2,
            onChanged: (val) {
              _val2 = val;
              _calculate();
            },
          ),
        ],
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(label: 'Error', value: _error!, isError: true)
        else if (_results != null) ...[
          ResultDisplayCard(
            label: 'Area',
            value: areaFormatted,
            secondaryLabel: secondaryLabel,
            secondaryValue: secondaryVal,
            bottomContent: _results?['diagonal'] != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diagonal:',
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _results!['diagonal']!
                              .toStringAsFixed(4)
                              .replaceAll(RegExp(r'\.?0+$'), ''),
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formulas',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formula,
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
