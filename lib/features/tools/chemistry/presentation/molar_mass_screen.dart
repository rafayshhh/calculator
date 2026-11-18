import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/k_error_card.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/chemistry_engine.dart';

class MolarMassScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const MolarMassScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<MolarMassScreen> createState() => _MolarMassScreenState();
}

class _MolarMassScreenState extends ConsumerState<MolarMassScreen> {
  String _formula = 'Ca(OH)2';
  late final TextEditingController _formulaController;

  MolarMassResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data =
            jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _formula = data['formula'] ?? 'Ca(OH)2';
      } catch (_) {}
    }
    _formulaController = TextEditingController(text: _formula);
    _calculate();
  }

  @override
  void didUpdateWidget(covariant MolarMassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_formula != _formulaController.text) {
      _formulaController.text = _formula;
    }
  }

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      if (_formula.trim().isEmpty) {
        setState(() {
          _result = null;
          _error = 'Please enter a chemical formula';
        });
        return;
      }
      final res = ChemistryEngine.calculateMolarMass(_formula);
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'formula': _formula});

      ref
          .read(historyProvider.notifier)
          .add(
            'Molar Mass: ${_result!.formula}',
            '${_result!.totalMolarMass.toStringAsFixed(3)} g/mol',
            toolRoute: '/tools/chemistry/molar_mass',
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
      _formula = 'Ca(OH)2';
      if (_formulaController.text != _formula) {
        _formulaController.text = _formula;
      }
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    // Sync controller just in case, per user request if didUpdateWidget was meant for this or if build was meant
    if (_formulaController.text != _formula) {
      _formulaController.text = _formula;
    }

    return ToolPageScaffold(
      toolId: 'molar_mass',
      title: 'Molar Mass Calculator',
      description: 'Calculate molecular weight, molar mass, and stoichiometric elemental composition',
      icon: Icons.science_outlined,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Text(
          'Chemical Formula (case-sensitive, e.g. H2O, Ca(OH)2, Al2(SO4)3)',
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: KSpacing.xs),
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
            controller: _formulaController,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: KSpacing.md,
                vertical: KSpacing.md,
              ),
              hintText: 'e.g. C6H12O6, NaCl',
            ),
            onChanged: (val) {
              _formula = val;
              _calculate();
            },
          ),
        ),
        const SizedBox(height: KSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                [
                  'H2O',
                  'CO2',
                  'NaCl',
                  'Ca(OH)2',
                  'C6H12O6',
                  'H2SO4',
                  'Al2(SO4)3',
                ].map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: KSpacing.xs),
                    child: ActionChip(
                      label: Text(f, style: const TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() {
                          _formula = f;
                          if (_formulaController.text != f) {
                            _formulaController.text = f;
                          }
                        });
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
            title: 'Chemical Formula Error',
            message: _error!,
            onRetry: _reset,
          )
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Total Molar Mass',
            value: '${_result!.totalMolarMass.toStringAsFixed(3)} g/mol',
            secondaryLabel: 'Elemental Count',
            secondaryValue: '${_result!.elements.length} unique elements',
            bottomContent: Column(
              children: [
                const SizedBox(height: KSpacing.sm),
                KStatRow(
                  label: 'Normalized Formula',
                  value: _result!.formula,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.md),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ELEMENTAL MASS BREAKDOWN',
                  style: TextStyle(
                    color: primaryAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                ..._result!.elements.map((elem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  elem.symbol,
                                  style: TextStyle(
                                    color: primaryAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${elem.name} (${elem.count} × ${elem.atomicMass.toStringAsFixed(2)})',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${elem.contribution.toStringAsFixed(2)} g (${elem.massPercentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.md),
          KFormulaCard(
            title: 'Molar Mass Summation',
            formula: 'M = Σ (n_i × M_i)',
            substitution:
                'M = ${_result!.elements.map((e) => '${e.count} × (${e.symbol}: ${e.atomicMass.toStringAsFixed(2)})').join(' + ')}',
          ),
        ],
      ],
    );
  }
}
