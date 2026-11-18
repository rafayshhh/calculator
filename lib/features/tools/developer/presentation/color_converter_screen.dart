import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/k_error_card.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/developer_engine.dart';

enum ColorConvertMode { rgbToHex, hexToRgb }

class ColorConverterScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ColorConverterScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ColorConverterScreen> createState() =>
      _ColorConverterScreenState();
}

class _ColorConverterScreenState extends ConsumerState<ColorConverterScreen> {
  ColorConvertMode _mode = ColorConvertMode.rgbToHex;

  String _r = '255';
  String _g = '87';
  String _b = '51';
  String _a = '1.0';

  String _hexInput = '#FF5733';
  late final TextEditingController _hexController;

  ColorConversionResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final modeStr = data['mode'] ?? 'rgbToHex';
        _mode = ColorConvertMode.values.firstWhere(
          (e) => e.name == modeStr,
          orElse: () => ColorConvertMode.rgbToHex,
        );
        _r = data['r'] ?? '255';
        _g = data['g'] ?? '87';
        _b = data['b'] ?? '51';
        _a = data['a'] ?? '1.0';
        _hexInput = data['hexInput'] ?? '#FF5733';
      } catch (_) {}
    }
    _hexController = TextEditingController(text: _hexInput);
    _calculate();
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      if (_mode == ColorConvertMode.rgbToHex) {
        final rVal = int.tryParse(_r);
        final gVal = int.tryParse(_g);
        final bVal = int.tryParse(_b);
        final aVal = double.tryParse(_a) ?? 1.0;

        if (rVal == null || gVal == null || bVal == null) {
          setState(() {
            _result = null;
            _error = 'Please enter integer RGB values between 0 and 255';
          });
          return;
        }

        final res = DeveloperEngine.rgbToHex(
          r: rVal,
          g: gVal,
          b: bVal,
          a: aVal,
        );
        setState(() {
          _error = null;
          _result = res;
        });
      } else {
        if (_hexInput.trim().isEmpty) {
          setState(() {
            _result = null;
            _error = 'Please enter a HEX code (e.g. #FF5733)';
          });
          return;
        }

        final res = DeveloperEngine.hexToRgb(_hexInput);
        setState(() {
          _error = null;
          _result = res;
        });
      }

      final stateJson = jsonEncode({
        'mode': _mode.name,
        'r': _r,
        'g': _g,
        'b': _b,
        'a': _a,
        'hexInput': _hexInput,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Color: ${_result!.hex} ↔ ${_result!.rgbString}',
            _result!.rgbaString,
            toolRoute: '/tools/developer/color_converter',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e
            .toString()
            .replaceAll('ArgumentError: ', '')
            .replaceAll('FormatException: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _mode = ColorConvertMode.rgbToHex;
      _r = '255';
      _g = '87';
      _b = '51';
      _a = '1.0';
      _hexInput = '#FF5733';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);

    return ToolPageScaffold(
      toolId: 'color_converter',
      title: 'RGB ↔ HEX Converter',
      description: 'Convert between CSS RGB/RGBA, HEX, and HEXA formats with real-time preview swatch',
      icon: Icons.palette_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<ColorConvertMode>(
          segments: const [
            ButtonSegment(
              value: ColorConvertMode.rgbToHex,
              label: Text('RGB → HEX'),
            ),
            ButtonSegment(
              value: ColorConvertMode.hexToRgb,
              label: Text('HEX → RGB'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (set) {
            setState(() => _mode = set.first);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_mode == ColorConvertMode.rgbToHex) ...[
          Row(
            children: [
              Expanded(
                child: PremiumNumericField(
                  label: 'Red (R)',
                  hint: '0-255',
                  value: _r,
                  onChanged: (val) {
                    _r = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                child: PremiumNumericField(
                  label: 'Green (G)',
                  hint: '0-255',
                  value: _g,
                  onChanged: (val) {
                    _g = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                child: PremiumNumericField(
                  label: 'Blue (B)',
                  hint: '0-255',
                  value: _b,
                  onChanged: (val) {
                    _b = val;
                    _calculate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Alpha Opacity (0.0 to 1.0)',
            hint: '1.0',
            value: _a,
            onChanged: (val) {
              _a = val;
              _calculate();
            },
          ),
        ] else ...[
          Container(
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
              controller: _hexController,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                labelText: 'HEX Color Code (e.g. #FF5733, #FFF, #FF573380)',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(KSpacing.md),
              ),
              onChanged: (val) {
                _hexInput = val;
                _calculate();
              },
            ),
          ),
        ],
      ],
      results: [
        if (_error != null)
          KErrorCard(
            title: 'Color Conversion Error',
            message: _error!,
            onRetry: _reset,
          )
        else if (_result != null) ...[
          ResultDisplayCard(
            label: _mode == ColorConvertMode.rgbToHex
                ? 'HEX Color Code'
                : 'CSS RGB Format',
            value: _mode == ColorConvertMode.rgbToHex
                ? _result!.hex
                : _result!.rgbString,
            secondaryLabel: 'Alpha / Opacity',
            secondaryValue: '${(_result!.a * 100).toStringAsFixed(0)}%',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      _result!.r,
                      _result!.g,
                      _result!.b,
                      _result!.a,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(
                          _result!.r,
                          _result!.g,
                          _result!.b,
                          0.4,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLOR NOTATION SPECS',
                        style: TextStyle(
                          color: primaryAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: KSpacing.xs),
                      KStatRow(label: 'HEX String', value: _result!.hex),
                      KStatRow(label: 'RGB String', value: _result!.rgbString),
                      KStatRow(
                        label: 'RGBA String',
                        value: _result!.rgbaString,
                      ),
                    ],
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
