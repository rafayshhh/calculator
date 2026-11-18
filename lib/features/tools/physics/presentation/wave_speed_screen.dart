import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/physics_engine.dart';

class WaveSpeedScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const WaveSpeedScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<WaveSpeedScreen> createState() => _WaveSpeedScreenState();
}

class _WaveSpeedScreenState extends ConsumerState<WaveSpeedScreen> {
  String _frequency = '440.0';
  String _wavelength = '0.78';
  double? _speed;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _frequency = data['frequency']?.toString() ?? '440.0';
        _wavelength = data['wavelength']?.toString() ?? '0.78';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final f = double.tryParse(_frequency);
    final w = double.tryParse(_wavelength);
    if (f == null || w == null) {
      setState(() {
        _speed = null;
        _error = 'Please enter valid frequency and wavelength';
      });
      return;
    }

    try {
      final v = PhysicsEngine.calculateWaveSpeed(f, w);
      setState(() {
        _error = null;
        _speed = v;
      });

      final stateJson = jsonEncode({'frequency': _frequency, 'wavelength': _wavelength});
      ref.read(historyProvider.notifier).add(
        'Wave Speed: $_frequency Hz × $_wavelength m',
        '${v.toStringAsFixed(2)} m/s',
        toolRoute: '/tools/physics/wave_speed',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _speed = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _frequency = '440.0';
      _wavelength = '0.78';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'wave_speed',
      title: 'Wave Speed Calculator',
      description: 'Compute phase velocity of mechanical and electromagnetic waves (v = fλ).',
      icon: Icons.waves_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        const KFormulaCard(
          formula: 'v = f × λ',
          description: 'Wave velocity equals oscillation frequency multiplied by wavelength.',
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Frequency (f)',
          suffix: 'Hz',
          value: _frequency,
          onChanged: (v) {
            _frequency = v;
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        PremiumNumericField(
          label: 'Wavelength (λ)',
          suffix: 'm',
          value: _wavelength,
          onChanged: (v) {
            _wavelength = v;
            _calculate();
          },
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_speed != null) ...[
          ResultDisplayCard(
            label: 'Wave Speed (v)',
            value: '${_speed!.toStringAsFixed(2)} m/s',
            secondaryLabel: 'km/h',
            secondaryValue: '${(_speed! * 3.6).toStringAsFixed(2)} km/h',
            formula: 'v = f × λ',
            substitution: 'v = $_frequency Hz × $_wavelength m = ${_speed!.toStringAsFixed(2)} m/s',
            onShare: () {},
          ),
        ],
      ],
    );
  }
}
