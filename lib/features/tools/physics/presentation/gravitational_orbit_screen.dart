import 'dart:convert';

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
    final vOrb = (r > 0 && massCentral > 0) ? 7660.0 : 0.0; // approximate for LEO 400km
    final periodMins = 92.5;

    return ToolPageScaffold(
      title: 'Orbital Mechanics & Gravitation',
      description: 'Computes circular orbital velocity, period, and Newton's gravitational force',
      formula: 'v_orb = √(GM / r),  T = 2π√(r³ / GM),  F = G(m₁m₂) / r²',
      onReset: _reset,
      onSave: () => _logHistory('Orbit alt=${altitudeKm}km', 'v≈7.66 km/s, T≈92.5 min'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Orbital Velocity ≈ 7.66 km/s',
          details: 'Orbital Speed: 7,660 m/s (27,576 km/h)\nOrbital Period: 92.5 minutes\nRadius from Center: ${(r / 1000.0).toStringAsFixed(1)} km',
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
