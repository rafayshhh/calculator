import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/financial_tool_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/physics_engine.dart';

enum DensitySolveTarget { density, mass, volume }

class DensityScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DensityScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DensityScreen> createState() => _DensityScreenState();
}

class _DensityScreenState extends ConsumerState<DensityScreen> {
  DensitySolveTarget _target = DensitySolveTarget.density;
  String _rho = '1000';
  String _m = '500';
  String _v = '0.5';

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final targetStr = data['target'] ?? 'density';
        if (targetStr == 'mass') {
          _target = DensitySolveTarget.mass;
        } else if (targetStr == 'volume') {
          _target = DensitySolveTarget.volume;
        } else {
          _target = DensitySolveTarget.density;
        }
        _rho = data['rho'] ?? '1000';
        _m = data['m'] ?? '500';
        _v = data['v'] ?? '0.5';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    try {
      if (_target == DensitySolveTarget.density) {
        final mVal = double.tryParse(_m);
        final vVal = double.tryParse(_v);
        if (mVal == null || vVal == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid mass and volume';
          });
          return;
        }
        final rho = PhysicsEngine.calculateDensity(mVal, vVal);
        final gCm3 = rho / 1000.0;
        setState(() {
          _error = null;
          _results = {
            'target': 'Mass Density (ρ)',
            'value':
                '${rho.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} kg/m³',
            'formula': 'ρ = m / V (${gCm3.toStringAsFixed(4)} g/cm³)',
            'substitution': 'ρ = $mVal kg / $vVal m³',
          };
        });
      } else if (_target == DensitySolveTarget.mass) {
        final rhoVal = double.tryParse(_rho);
        final vVal = double.tryParse(_v);
        if (rhoVal == null || vVal == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid density and volume';
          });
          return;
        }
        final m = PhysicsEngine.calculateMassFromDensity(rhoVal, vVal);
        setState(() {
          _error = null;
          _results = {
            'target': 'Mass (m)',
            'value':
                '${m.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} kg',
            'formula': 'm = ρ · V',
            'substitution': 'm = $rhoVal kg/m³ · $vVal m³',
          };
        });
      } else {
        final mVal = double.tryParse(_m);
        final rhoVal = double.tryParse(_rho);
        if (mVal == null || rhoVal == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid mass and density';
          });
          return;
        }
        final v = PhysicsEngine.calculateVolumeFromDensity(mVal, rhoVal);
        final liters = v * 1000.0;
        setState(() {
          _error = null;
          _results = {
            'target': 'Volume (V)',
            'value':
                '${v.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} m³',
            'formula': 'V = m / ρ (${liters.toStringAsFixed(2)} L)',
            'substitution': 'V = $mVal kg / $rhoVal kg/m³',
          };
        });
      }

      final stateJson = jsonEncode({
        'target': _target.name,
        'rho': _rho,
        'm': _m,
        'v': _v,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Density: ${_results!['target']}',
            _results!['value'],
            toolRoute: '/tools/physics/density',
            toolStateJson: stateJson,
          );
    } catch (e) {
      setState(() {
        _results = null;
        _error = e
            .toString()
            .replaceAll('ArgumentError: ', '')
            .replaceAll('Invalid argument(s): ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _target = DensitySolveTarget.density;
      _rho = '1000';
      _m = '500';
      _v = '0.5';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return FinancialToolScaffold(
      title: 'Density Calculator',
      description: 'Volumetric mass density & mass-volume relations (ρ = m/V)',
      icon: Icons.opacity_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<DensitySolveTarget>(
          segments: const [
            ButtonSegment(
              value: DensitySolveTarget.density,
              label: Text('Find ρ'),
            ),
            ButtonSegment(
              value: DensitySolveTarget.mass,
              label: Text('Find m'),
            ),
            ButtonSegment(
              value: DensitySolveTarget.volume,
              label: Text('Find V'),
            ),
          ],
          selected: {_target},
          onSelectionChanged: (set) {
            setState(() {
              _target = set.first;
            });
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_target != DensitySolveTarget.density)
          PremiumNumericField(
            label: 'Density (ρ)',
            suffix: 'kg/m³',
            hint: 'Water: 1000',
            value: _rho,
            onChanged: (val) {
              _rho = val;
              _calculate();
            },
          ),
        if (_target != DensitySolveTarget.mass) ...[
          if (_target != DensitySolveTarget.density)
            const SizedBox(height: KSpacing.sm),
          PremiumNumericField(
            label: 'Mass (m)',
            suffix: 'kg',
            hint: 'e.g. 500',
            value: _m,
            onChanged: (val) {
              _m = val;
              _calculate();
            },
          ),
        ],
        if (_target != DensitySolveTarget.volume) ...[
          const SizedBox(height: KSpacing.sm),
          PremiumNumericField(
            label: 'Volume (V)',
            suffix: 'm³',
            hint: 'e.g. 0.5',
            value: _v,
            onChanged: (val) {
              _v = val;
              _calculate();
            },
          ),
        ],
      ],
      results: [
        if (_error != null)
          ResultDisplayCard(
            label: 'Calculation Error',
            value: _error!,
            isError: true,
          )
        else if (_results != null)
          ResultDisplayCard(
            label: _results!['target'],
            value: _results!['value'],
            secondaryLabel: 'Formula: ${_results!['formula']}',
            secondaryValue: _results!['substitution'],
          ),
      ],
    );
  }
}
