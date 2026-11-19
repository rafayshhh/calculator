import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';


class ProjectileMotionScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const ProjectileMotionScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<ProjectileMotionScreen> createState() => _ProjectileMotionScreenState();
}

class _ProjectileMotionScreenState extends ConsumerState<ProjectileMotionScreen> {
  String _v0 = '25.0';
  String _theta = '45.0';
  String _g = '9.80665';

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null && widget.initialStateJson!.isNotEmpty) {
      try {
        final map = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _v0 = map['v0']?.toString() ?? '25.0';
        _theta = map['theta']?.toString() ?? '45.0';
        _g = map['g']?.toString() ?? '9.80665';
      } catch (_) {}
    }
  }

  void _reset() {
    setState(() {
      _v0 = '25.0';
      _theta = '45.0';
      _g = '9.80665';
    });
  }

  void _logHistory(String expression, String result) {
    try {
      final stateJson = jsonEncode({'v0': _v0, 'theta': _theta, 'g': _g});
      ref.read(historyProvider.notifier).add(
            expression,
            result,
            toolRoute: '/tools/physics/projectile_motion',
            toolStateJson: stateJson,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {

    final v0 = double.tryParse(_v0) ?? 0.0;
    final theta = double.tryParse(_theta) ?? 45.0;
    final g = double.tryParse(_g) ?? 9.80665;
    final rad = theta * (math.pi / 180.0);
    final vx = v0 * math.cos(rad);
    final vy = v0 * math.sin(rad);
    final flightTime = (g > 0 && vy >= 0) ? (2 * vy) / g : 0.0;
    final maxHeight = (g > 0 && vy >= 0) ? (vy * vy) / (2 * g) : 0.0;
    final range = vx * flightTime;

    return ToolPageScaffold(
      title: 'Projectile Motion 2D Kinematics',
      description: 'Computes flight time, horizontal range, and maximum trajectory altitude',
      formula: 'R = (v₀² sin 2θ) / g,  H = (v₀² sin²θ) / (2g),  T = (2v₀ sin θ) / g',
      onReset: _reset,
      onSave: () => _logHistory('Projectile v0=$v0, θ=$theta°', 'Range=${range.toStringAsFixed(2)}m, Time=${flightTime.toStringAsFixed(2)}s'),
      children: [
        ResultDisplayCard(
          title: 'Result',
          value: 'Range = ${range.toStringAsFixed(2)} m',
          details: 'Initial vx: ${vx.toStringAsFixed(2)} m/s, vy: ${vy.toStringAsFixed(2)} m/s\nMax Altitude H: ${maxHeight.toStringAsFixed(3)} m\nTotal Flight Time: ${flightTime.toStringAsFixed(3)} s\nHorizontal Range R: ${range.toStringAsFixed(3)} m\nGravity: $g m/s²',
        ),
        const SizedBox(height: KSpacing.lg),
          PremiumNumericField(
            label: 'Launch Velocity v₀ (m/s)',
            initialValue: _v0,
            onChanged: (val) => setState(() => _v0 = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Launch Angle θ (Degrees)',
            initialValue: _theta,
            onChanged: (val) => setState(() => _theta = val),
          ),
          const SizedBox(height: KSpacing.md),
          PremiumNumericField(
            label: 'Gravity g (m/s²)',
            initialValue: _g,
            onChanged: (val) => setState(() => _g = val),
          ),
      ],
    );
  }
}
