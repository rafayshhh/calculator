import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_error_card.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/developer_engine.dart';

class NumberBaseScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const NumberBaseScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<NumberBaseScreen> createState() => _NumberBaseScreenState();
}

class _NumberBaseScreenState extends ConsumerState<NumberBaseScreen> {
  String _inputVal = '255';
  late final TextEditingController _inputValController;
  int _sourceBase = 10;
  int _targetBase = 16;

  NumberBaseResult? _result;
  String? _error;

  final Map<int, String> _baseOptions = {
    2: 'BIN (2)',
    8: 'OCT (8)',
    10: 'DEC (10)',
    16: 'HEX (16)',
    36: 'Base 36',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _inputVal = data['inputVal'] ?? '255';
        _sourceBase = data['sourceBase'] ?? 10;
        _targetBase = data['targetBase'] ?? 16;
      } catch (_) {}
    }
    _inputValController = TextEditingController(text: _inputVal);
    _calculate();
  }

  @override
  void dispose() {
    _inputValController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      if (_inputVal.trim().isEmpty) {
        setState(() {
          _result = null;
          _error = 'Please enter a value to convert';
        });
        return;
      }

      final res = DeveloperEngine.convertNumberBase(
        value: _inputVal,
        sourceBase: _sourceBase,
        targetBase: _targetBase,
      );

      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({
        'inputVal': _inputVal,
        'sourceBase': _sourceBase,
        'targetBase': _targetBase,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            '$_inputVal (Base $_sourceBase) → ${_result!.convertedValue} (Base $_targetBase)',
            'Dec: ${_result!.decimal}, Hex: ${_result!.hex}, Bin: ${_result!.binary}',
            toolRoute: '/tools/developer/number_base',
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
    setState(() {
      _inputVal = '255';
      _sourceBase = 10;
      _targetBase = 16;
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = KColors.primaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);

    return ToolPageScaffold(
      toolId: 'number_base',
      title: 'Number Base Converter',
      description: 'Convert values between Binary, Octal, Decimal, Hexadecimal, and arbitrary radix (2-36)',
      icon: Icons.numbers_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _sourceBase,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'From',
                  filled: true,
                  fillColor: isDark
                      ? KColors.surfaceElevatedDark
                      : KColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                dropdownColor: isDark
                    ? KColors.surfaceElevatedDark
                    : KColors.surfaceLight,
                items: _baseOptions.entries.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(
                      e.value,
                      style: TextStyle(color: textPrimary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _sourceBase = val);
                    _calculate();
                  }
                },
              ),
            ),
            const SizedBox(width: KSpacing.xs),
            Semantics(
              label: 'Swap bases',
              button: true,
              child: IconButton.filledTonal(
                tooltip: 'Swap Bases',
                icon: const Icon(Icons.swap_horiz_rounded),
                onPressed: () {
                  setState(() {
                    final temp = _sourceBase;
                    _sourceBase = _targetBase;
                    _targetBase = temp;
                  });
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.xs),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _targetBase,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'To',
                  filled: true,
                  fillColor: isDark
                      ? KColors.surfaceElevatedDark
                      : KColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                dropdownColor: isDark
                    ? KColors.surfaceElevatedDark
                    : KColors.surfaceLight,
                items: _baseOptions.entries.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(
                      e.value,
                      style: TextStyle(color: textPrimary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _targetBase = val);
                    _calculate();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: isDark ? KColors.surfaceElevatedDark : KColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? KColors.glassBorderDark
                  : KColors.glassBorderLight,
            ),
          ),
          child: TextField(
            controller: _inputValController,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              labelText: 'Input Value (Base $_sourceBase)',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: KSpacing.md,
                vertical: KSpacing.md,
              ),
            ),
            onChanged: (val) {
              _inputVal = val;
              _calculate();
            },
          ),
        ),
        const SizedBox(height: KSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['255', '1024', '65535', 'FF', '101010'].map((preset) {
              return Padding(
                padding: const EdgeInsets.only(right: KSpacing.xs),
                child: ActionChip(
                  label: Text(
                    preset,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  onPressed: () {
                    setState(() => _inputVal = preset);
                    _calculate();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
      results: [
        if (_error != null)
          KErrorCard(
            title: 'Radix Conversion Error',
            message: _error!,
            onRetry: _reset,
          )
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Converted Value (Base $_targetBase)',
            value: _result!.convertedValue,
            secondaryLabel: 'Source Radix',
            secondaryValue: '${_result!.originalValue} (Base $_sourceBase)',
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STANDARD RADIX SPECIFICATIONS',
                  style: TextStyle(
                    color: primaryAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                _buildBaseRow(
                  'Binary (Base 2)',
                  _result!.binary,
                  textSecondary,
                  textPrimary,
                ),
                _buildBaseRow(
                  'Octal (Base 8)',
                  _result!.octal,
                  textSecondary,
                  textPrimary,
                ),
                _buildBaseRow(
                  'Decimal (Base 10)',
                  _result!.decimal,
                  textSecondary,
                  textPrimary,
                ),
                _buildBaseRow(
                  'Hexadecimal (Base 16)',
                  _result!.hex,
                  textSecondary,
                  textPrimary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBaseRow(
    String label,
    String val,
    Color secondary,
    Color primary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: secondary, fontSize: 12)),
          Row(
            children: [
              Text(
                val,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Semantics(
                label: 'Copy $label to clipboard',
                button: true,
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: val));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $val to clipboard'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(Icons.copy_outlined, size: 14, color: secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
