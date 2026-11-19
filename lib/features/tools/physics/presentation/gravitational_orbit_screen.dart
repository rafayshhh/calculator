import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';


class GravitationalOrbitScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const GravitationalOrbitScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<GravitationalOrbitScreen> createState() => _GravitationalOrbitScreenState();
}

class _GravitationalOrbitScreenState extends ConsumerState<GravitationalOrbitScreen> {
  String _massCentral = '5.972e24';
  String _altitudeKm = '400.0';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _massCentral = map['massCentral']?.toString() ?? '5.972e24';
        _altitudeKm = map['altitudeKm']?.toString() ?? '400.0';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _massCentral = '5.972e24';
      _altitudeKm = '400.0';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'massCentral': _massCentral, 'altitudeKm': _altitudeKm});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/physics/gravitational_orbit',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final massCentral = double.tryParse(_massCentral) ?? 5.972e24;
    final altitudeKm = double.tryParse(_altitudeKm) ?? 400.0;
    const G = 6.67430e-11;
    const rEarth = 6371000.0;
    final r = rEarth + altitudeKm * 1000.0;
    final double vOrb;
    final double periodMins;
    if (r > 0 && massCentral > 0) {
      final mu = G * massCentral;
      vOrb = math.sqrt(mu / r);
      final periodSecs = 2 * math.pi * math.sqrt(math.pow(r, 3) / mu);
      periodMins = periodSecs / 60.0;
    } else {
      vOrb = 0.0;
      periodMins = 0.0;
    }
    final vKmS = vOrb / 1000.0;
    final vKmH = vOrb * 3.6;

    return ToolPageScaffold(
      title: 'Orbital Mechanics & Gravitation',
      description: "Computes circular orbital velocity, period, and Newton's gravitational force",
      formula: 'v_orb = √(GM / r),  T = 2π√(r³ / GM),  F = G(m₁m₂) / r²',
      onReset: _reset,
      onSave: () => _logHistory('Orbit alt=${altitudeKm}km, M=$massCentral', 'v=${vKmS.toStringAsFixed(2)} km/s, T=${periodMins.toStringAsFixed(1)} min'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Orbital Velocity ≈ ${vKmS.toStringAsFixed(2)} km/s',
          details: 'Orbital Speed: ${vOrb.toStringAsFixed(1)} m/s (${vKmH.toStringAsFixed(0)} km/h)\nOrbital Period: ${periodMins.toStringAsFixed(1)} minutes (${(periodMins / 60.0).toStringAsFixed(2)} hours)\nRadius from Center: ${(r / 1000.0).toStringAsFixed(1)} km',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Central Mass M (kg)',
            initialValue: _massCentral,
            onChanged: (val) => setState(() => _massCentral = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Orbital Altitude (km)',
            initialValue: _altitudeKm,
            onChanged: (val) => setState(() => _altitudeKm = val),
          ),
      ],
    );
  }
}
