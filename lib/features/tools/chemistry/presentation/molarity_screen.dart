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
import '../domain/chemistry_engine.dart';

enum MolaritySolveMode { molarity, moles, volume }

class MolarityScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MolarityScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MolarityScreen> createState() => _MolarityScreenState();
}

class _MolarityScreenState extends ConsumerState<MolarityScreen> {
  MolaritySolveMode _mode = MolaritySolveMode.molarity;

  String _moles = '0.5';
  String _volume = '250';
  String _molarity = '2.0';
  String _volumeUnit = 'mL'; // 'L' or 'mL'

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final modeStr = data['mode'] ?? 'molarity';
        _mode = MolaritySolveMode.values.firstWhere(
          (e) => e.name == modeStr,
          orElse: () => MolaritySolveMode.molarity,
        );
        _moles = data['moles'] ?? '0.5';
        _volume = data['volume'] ?? '250';
        _molarity = data['molarity'] ?? '2.0';
        _volumeUnit = data['volumeUnit'] ?? 'mL';
      } catch (_) {}
    }
    _calculate();
  }

  double _getVolumeInLiters(double rawVolume) {
    return _volumeUnit == 'mL' ? rawVolume / 1000.0 : rawVolume;
  }

  void _calculate() {
    try {
      if (_mode == MolaritySolveMode.molarity) {
        final n = double.tryParse(_moles);
        final rawV = double.tryParse(_volume);
        if (n == null || rawV == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid numerical moles and volume';
          });
          return;
        }
        final vL = _getVolumeInLiters(rawV);
        final m = ChemistryEngine.calculateMolarity(n, vL);
        setState(() {
          _error = null;
          _results = {
            'target': 'Molarity (M)',
            'value':
                '${m.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} M (mol/L)',
            'formula': 'M = n / V',
            'substitution': 'M = $n mol / $vL L',
            'summary': 'Moles: $n mol, Volume: $rawV $_volumeUnit',
          };
        });
      } else if (_mode == MolaritySolveMode.moles) {
        final m = double.tryParse(_molarity);
        final rawV = double.tryParse(_volume);
        if (m == null || rawV == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid numerical molarity and volume';
          });
          return;
        }
        final vL = _getVolumeInLiters(rawV);
        final n = ChemistryEngine.calculateMolesFromMolarity(m, vL);
        setState(() {
          _error = null;
          _results = {
            'target': 'Solute Moles (n)',
            'value':
                '${n.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} mol',
            'formula': 'n = M × V',
            'substitution': 'n = $m M × $vL L',
            'summary': 'Molarity: $m M, Volume: $rawV $_volumeUnit',
          };
        });
      } else {
        final n = double.tryParse(_moles);
        final m = double.tryParse(_molarity);
        if (n == null || m == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid numerical moles and molarity';
          });
          return;
        }
        final vL = ChemistryEngine.calculateVolumeFromMolarity(n, m);
        final vDisplay = _volumeUnit == 'mL' ? vL * 1000.0 : vL;
        setState(() {
          _error = null;
          _results = {
            'target': 'Solution Volume (V)',
            'value':
                '${vDisplay.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} $_volumeUnit (${vL.toStringAsFixed(4)} L)',
            'formula': 'V = n / M',
            'substitution': 'V = $n mol / $m M',
            'summary': 'Moles: $n mol, Molarity: $m M',
          };
        });
      }

      final stateJson = jsonEncode({
        'mode': _mode.name,
        'moles': _moles,
        'volume': _volume,
        'molarity': _molarity,
        'volumeUnit': _volumeUnit,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Molarity: ${_results!['value']}',
            _results!['summary'],
            toolRoute: '/tools/chemistry/molarity',
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
      _mode = MolaritySolveMode.molarity;
      _moles = '0.5';
      _volume = '250';
      _molarity = '2.0';
      _volumeUnit = 'mL';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textSecondaryColor = isDark
        ? KColors.textSecondaryDark
        : KColors.textSecondaryLight;

    return FinancialToolScaffold(
      title: 'Molarity Calculator',
      description:
          'Calculate concentration in molarity (mol/L), moles, or volume',
      icon: Icons.water_drop_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        SegmentedButton<MolaritySolveMode>(
          segments: const [
            ButtonSegment(
              value: MolaritySolveMode.molarity,
              label: Text('Molarity (M)'),
            ),
            ButtonSegment(
              value: MolaritySolveMode.moles,
              label: Text('Moles (n)'),
            ),
            ButtonSegment(
              value: MolaritySolveMode.volume,
              label: Text('Volume (V)'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (set) {
            setState(() {
              _mode = set.first;
            });
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_mode != MolaritySolveMode.molarity) ...[
          PremiumNumericField(
            label: 'Molarity (M or mol/L)',
            value: _molarity,
            onChanged: (val) {
              _molarity = val;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode != MolaritySolveMode.moles) ...[
          PremiumNumericField(
            label: 'Moles of Solute (n in mol)',
            value: _moles,
            onChanged: (val) {
              _moles = val;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode != MolaritySolveMode.volume) ...[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PremiumNumericField(
                  label: 'Solution Volume',
                  value: _volume,
                  onChanged: (val) {
                    _volume = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                flex: 1,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'mL', label: Text('mL')),
                    ButtonSegment(value: 'L', label: Text('L')),
                  ],
                  selected: {_volumeUnit},
                  onSelectionChanged: (set) {
                    setState(() {
                      _volumeUnit = set.first;
                    });
                    _calculate();
                  },
                ),
              ),
            ],
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
        else if (_results != null) ...[
          ResultDisplayCard(
            label: _results!['target'],
            value: _results!['value'],
            secondaryLabel: 'Mode',
            secondaryValue: _mode.name.toUpperCase(),
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formula & Substitution',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _results!['formula'],
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _results!['substitution'],
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
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
