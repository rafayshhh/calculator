import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_variable_selector.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/k_error_card.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/chemistry_engine.dart';

enum IdealGasSolveMode { pressure, volume, moles, temperature }

class IdealGasScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const IdealGasScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<IdealGasScreen> createState() => _IdealGasScreenState();
}

class _IdealGasScreenState extends ConsumerState<IdealGasScreen> {
  IdealGasSolveMode _mode = IdealGasSolveMode.pressure;

  String _pressure = '101.325';
  String _pressureUnit = 'kPa'; // 'kPa', 'atm', 'Pa'

  String _volume = '22.414';
  String _volumeUnit = 'L'; // 'L', 'm³'

  String _moles = '1.0';

  String _temperature = '25.0';
  String _tempUnit = '°C'; // '°C', 'K'

  Map<String, dynamic>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        final modeStr = data['mode'] ?? 'pressure';
        _mode = IdealGasSolveMode.values.firstWhere(
          (e) => e.name == modeStr,
          orElse: () => IdealGasSolveMode.pressure,
        );
        _pressure = data['pressure'] ?? '101.325';
        _pressureUnit = data['pressureUnit'] ?? 'kPa';
        _volume = data['volume'] ?? '22.414';
        _volumeUnit = data['volumeUnit'] ?? 'L';
        _moles = data['moles'] ?? '1.0';
        _temperature = data['temperature'] ?? '25.0';
        _tempUnit = data['tempUnit'] ?? '°C';
      } catch (_) {}
    }
    _calculate();
  }

  double _normalizePressureToKPa(double p, String unit) {
    switch (unit) {
      case 'atm':
        return p * 101.325;
      case 'Pa':
        return p / 1000.0;
      case 'kPa':
      default:
        return p;
    }
  }

  double _convertPressureFromKPa(double kPa, String unit) {
    switch (unit) {
      case 'atm':
        return kPa / 101.325;
      case 'Pa':
        return kPa * 1000.0;
      case 'kPa':
      default:
        return kPa;
    }
  }

  double _normalizeVolumeToLiters(double v, String unit) {
    return unit == 'm³' ? v * 1000.0 : v;
  }

  double _convertVolumeFromLiters(double liters, String unit) {
    return unit == 'm³' ? liters / 1000.0 : liters;
  }

  double _normalizeTempToKelvin(double t, String unit) {
    return unit == '°C' ? ChemistryEngine.celsiusToKelvin(t) : t;
  }

  double _convertTempFromKelvin(double kelvin, String unit) {
    return unit == '°C' ? ChemistryEngine.kelvinToCelsius(kelvin) : kelvin;
  }

  void _calculate() {
    try {
      final pVal = double.tryParse(_pressure);
      final vVal = double.tryParse(_volume);
      final nVal = double.tryParse(_moles);
      final tVal = double.tryParse(_temperature);

      if (_mode == IdealGasSolveMode.pressure) {
        if (vVal == null || nVal == null || tVal == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid volume, moles, and temperature values';
          });
          return;
        }
        final vL = _normalizeVolumeToLiters(vVal, _volumeUnit);
        final tK = _normalizeTempToKelvin(tVal, _tempUnit);
        final pKPa = ChemistryEngine.calculateIdealGasPressure(vL, nVal, tK);
        final pDisplay = _convertPressureFromKPa(pKPa, _pressureUnit);

        setState(() {
          _error = null;
          _results = {
            'target': 'Gas Pressure (P)',
            'value':
                '${pDisplay.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} $_pressureUnit',
            'secondary':
                '${pKPa.toStringAsFixed(3)} kPa (${(pKPa / 101.325).toStringAsFixed(3)} atm)',
            'formula': 'P = (n × R × T) / V',
            'substitution':
                'P = ($nVal mol × 8.314 J/(mol·K) × ${tK.toStringAsFixed(2)} K) / ${vL.toStringAsFixed(2)} L = ${pDisplay.toStringAsFixed(3)} $_pressureUnit',
            'notes':
                'Universal Gas Constant R = 8.314 J/(mol·K) · Absolute Temp T = ${tK.toStringAsFixed(2)} K',
          };
        });
      } else if (_mode == IdealGasSolveMode.volume) {
        if (pVal == null || nVal == null || tVal == null) {
          setState(() {
            _results = null;
            _error =
                'Please enter valid pressure, moles, and temperature values';
          });
          return;
        }
        final pKPa = _normalizePressureToKPa(pVal, _pressureUnit);
        final tK = _normalizeTempToKelvin(tVal, _tempUnit);
        final vL = ChemistryEngine.calculateIdealGasVolume(pKPa, nVal, tK);
        final vDisplay = _convertVolumeFromLiters(vL, _volumeUnit);

        setState(() {
          _error = null;
          _results = {
            'target': 'Gas Volume (V)',
            'value':
                '${vDisplay.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} $_volumeUnit',
            'secondary':
                '${vL.toStringAsFixed(3)} L (${(vL / 1000.0).toStringAsFixed(4)} m³)',
            'formula': 'V = (n × R × T) / P',
            'substitution':
                'V = ($nVal mol × 8.314 × ${tK.toStringAsFixed(2)} K) / ${pKPa.toStringAsFixed(2)} kPa = ${vDisplay.toStringAsFixed(3)} $_volumeUnit',
            'notes':
                'Universal Gas Constant R = 8.314 J/(mol·K) · Absolute Temp T = ${tK.toStringAsFixed(2)} K',
          };
        });
      } else if (_mode == IdealGasSolveMode.moles) {
        if (pVal == null || vVal == null || tVal == null) {
          setState(() {
            _results = null;
            _error =
                'Please enter valid pressure, volume, and temperature values';
          });
          return;
        }
        final pKPa = _normalizePressureToKPa(pVal, _pressureUnit);
        final vL = _normalizeVolumeToLiters(vVal, _volumeUnit);
        final tK = _normalizeTempToKelvin(tVal, _tempUnit);
        final n = ChemistryEngine.calculateIdealGasMoles(pKPa, vL, tK);

        setState(() {
          _error = null;
          _results = {
            'target': 'Moles of Gas (n)',
            'value':
                '${n.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')} mol',
            'secondary':
                '${(n * ChemistryEngine.avogadroConstant).toStringAsExponential(3)} particles',
            'formula': 'n = (P × V) / (R × T)',
            'substitution':
                'n = (${pKPa.toStringAsFixed(2)} kPa × ${vL.toStringAsFixed(2)} L) / (8.314 × ${tK.toStringAsFixed(2)} K) = ${n.toStringAsFixed(4)} mol',
            'notes':
                'Particles: ${(n * ChemistryEngine.avogadroConstant).toStringAsExponential(3)} (Avogadro Constant N_A = 6.022 × 10²³)',
          };
        });
      } else {
        if (pVal == null || vVal == null || nVal == null) {
          setState(() {
            _results = null;
            _error = 'Please enter valid pressure, volume, and moles values';
          });
          return;
        }
        final pKPa = _normalizePressureToKPa(pVal, _pressureUnit);
        final vL = _normalizeVolumeToLiters(vVal, _volumeUnit);
        final tK = ChemistryEngine.calculateIdealGasTemperature(pKPa, vL, nVal);
        final tDisplay = _convertTempFromKelvin(tK, _tempUnit);

        setState(() {
          _error = null;
          _results = {
            'target': 'Gas Temperature (T)',
            'value':
                '${tDisplay.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} $_tempUnit',
            'secondary':
                '${tK.toStringAsFixed(2)} K (${(tK - 273.15).toStringAsFixed(2)} °C)',
            'formula': 'T = (P × V) / (n × R)',
            'substitution':
                'T = (${pKPa.toStringAsFixed(2)} kPa × ${vL.toStringAsFixed(2)} L) / ($nVal mol × 8.314) = ${tK.toStringAsFixed(2)} K',
            'notes':
                'Equivalent Kelvin Temperature: ${tK.toStringAsFixed(2)} K',
          };
        });
      }

      final stateJson = jsonEncode({
        'mode': _mode.name,
        'pressure': _pressure,
        'pressureUnit': _pressureUnit,
        'volume': _volume,
        'volumeUnit': _volumeUnit,
        'moles': _moles,
        'temperature': _temperature,
        'tempUnit': _tempUnit,
      });

      ref
          .read(historyProvider.notifier)
          .add(
            'Ideal Gas (PV=nRT): ${_results!['value']}',
            _results!['secondary'],
            toolRoute: '/tools/chemistry/ideal_gas',
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
      _mode = IdealGasSolveMode.pressure;
      _pressure = '101.325';
      _pressureUnit = 'kPa';
      _volume = '22.414';
      _volumeUnit = 'L';
      _moles = '1.0';
      _temperature = '25.0';
      _tempUnit = '°C';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'ideal_gas',
      title: 'Ideal Gas Law',
      description: 'Equation of state relating pressure, volume, amount, and temperature across ideal gases',
      icon: Icons.air_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        KVariableSelector<IdealGasSolveMode>(
          selected: _mode,
          items: IdealGasSolveMode.values,
          itemLabel: (m) => m == IdealGasSolveMode.pressure
              ? 'Pressure'
              : (m == IdealGasSolveMode.volume
                    ? 'Volume'
                    : (m == IdealGasSolveMode.moles ? 'Moles' : 'Temperature')),
          itemSymbol: (m) => m == IdealGasSolveMode.pressure
              ? 'P'
              : (m == IdealGasSolveMode.volume
                    ? 'V'
                    : (m == IdealGasSolveMode.moles ? 'n' : 'T')),
          onSelected: (val) {
            setState(() => _mode = val);
            _calculate();
          },
        ),
        const SizedBox(height: KSpacing.md),
        if (_mode != IdealGasSolveMode.pressure) ...[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PremiumNumericField(
                  label: 'Gas Pressure',
                  value: _pressure,
                  onChanged: (val) {
                    _pressure = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                flex: 1,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'kPa', label: Text('kPa')),
                    ButtonSegment(value: 'atm', label: Text('atm')),
                    ButtonSegment(value: 'Pa', label: Text('Pa')),
                  ],
                  selected: {_pressureUnit},
                  onSelectionChanged: (set) {
                    setState(() => _pressureUnit = set.first);
                    _calculate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode != IdealGasSolveMode.volume) ...[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PremiumNumericField(
                  label: 'Gas Volume',
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
                    ButtonSegment(value: 'L', label: Text('L')),
                    ButtonSegment(value: 'm³', label: Text('m³')),
                  ],
                  selected: {_volumeUnit},
                  onSelectionChanged: (set) {
                    setState(() => _volumeUnit = set.first);
                    _calculate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode != IdealGasSolveMode.moles) ...[
          PremiumNumericField(
            label: 'Moles of Gas',
            suffix: 'mol',
            value: _moles,
            onChanged: (val) {
              _moles = val;
              _calculate();
            },
          ),
          const SizedBox(height: KSpacing.md),
        ],
        if (_mode != IdealGasSolveMode.temperature) ...[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PremiumNumericField(
                  label: 'Gas Temperature',
                  value: _temperature,
                  onChanged: (val) {
                    _temperature = val;
                    _calculate();
                  },
                ),
              ),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                flex: 1,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '°C', label: Text('°C')),
                    ButtonSegment(value: 'K', label: Text('K')),
                  ],
                  selected: {_tempUnit},
                  onSelectionChanged: (set) {
                    setState(() => _tempUnit = set.first);
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
          KErrorCard(title: 'Gas Law Error', message: _error!, onRetry: _reset)
        else if (_results != null) ...[
          ResultDisplayCard(
            label: _results!['target'],
            value: _results!['value'],
            secondaryLabel: 'Unit Equivalents',
            secondaryValue: _results!['secondary'],
            bottomContent: Column(
              children: [
                const SizedBox(height: KSpacing.sm),
                KStatRow(
                  label: 'Equivalent Metric',
                  value: _results!['secondary'],
                  isHighlighted: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.md),
          KFormulaCard(
            title: 'Equation & Substitution',
            formula: _results!['formula'],
            substitution: _results!['substitution'],
            notes: _results!['notes'],
          ),
        ],
      ],
    );
  }
}
