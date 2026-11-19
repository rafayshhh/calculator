import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/web_state_serializer.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/calculator/presentation/equation_solver_screen.dart';
import '../../features/calculator/presentation/graphing_screen.dart';
import '../../features/calculator/presentation/table_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/tools/presentation/all_tools_screen.dart';
import '../../features/tools/presentation/category_screen.dart';
import '../../features/tools/domain/tool_definition.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/screens/theme_settings_screen.dart';
import '../../features/settings/presentation/screens/haptics_settings_screen.dart';
import '../../features/settings/presentation/screens/data_settings_screen.dart';
import '../../features/settings/presentation/screens/ecosystem_screen.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/support/presentation/support_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/tools/chemistry/presentation/concentration_screen.dart';
import '../../features/tools/chemistry/presentation/dilution_screen.dart';
import '../../features/tools/chemistry/presentation/gas_law_screen.dart';
import '../../features/tools/chemistry/presentation/ideal_gas_screen.dart';
import '../../features/tools/chemistry/presentation/molar_mass_screen.dart';
import '../../features/tools/chemistry/presentation/molarity_screen.dart';
import '../../features/tools/chemistry/presentation/ph_screen.dart';
import '../../features/tools/chemistry/presentation/stoichiometry_screen.dart';
import '../../features/tools/date_time/presentation/age_calculator_screen.dart';
import '../../features/tools/date_time/presentation/business_days_screen.dart';
import '../../features/tools/date_time/presentation/countdown_screen.dart';
import '../../features/tools/date_time/presentation/date_add_subtract_screen.dart';
import '../../features/tools/date_time/presentation/date_diff_screen.dart';
import '../../features/tools/date_time/presentation/date_difference_screen.dart';
import '../../features/tools/date_time/presentation/date_formatter_screen.dart';
import '../../features/tools/date_time/presentation/day_of_week_screen.dart';
import '../../features/tools/date_time/presentation/stopwatch_timer_screen.dart';
import '../../features/tools/date_time/presentation/time_add_subtract_screen.dart';
import '../../features/tools/date_time/presentation/time_difference_screen.dart';
import '../../features/tools/date_time/presentation/time_math_screen.dart';
import '../../features/tools/date_time/presentation/time_zone_converter_screen.dart';
import '../../features/tools/date_time/presentation/timestamp_converter_screen.dart';
import '../../features/tools/date_time/presentation/week_number_screen.dart';
import '../../features/tools/developer/presentation/bitwise_screen.dart';
import '../../features/tools/developer/presentation/color_converter_screen.dart';
import '../../features/tools/developer/presentation/data_transfer_screen.dart';
import '../../features/tools/developer/presentation/developer_utilities_screen.dart';
import '../../features/tools/developer/presentation/number_base_screen.dart';
import '../../features/tools/developer/presentation/unix_timestamp_screen.dart';
import '../../features/tools/engineering/presentation/capacitors_screen.dart';
import '../../features/tools/engineering/presentation/electrical_energy_screen.dart';
import '../../features/tools/engineering/presentation/gear_ratio_screen.dart';
import '../../features/tools/engineering/presentation/inductors_screen.dart';
import '../../features/tools/engineering/presentation/led_resistor_screen.dart';
import '../../features/tools/engineering/presentation/mechanical_advantage_screen.dart';
import '../../features/tools/engineering/presentation/mechanical_efficiency_screen.dart';
import '../../features/tools/engineering/presentation/rc_time_constant_screen.dart';
import '../../features/tools/engineering/presentation/rpm_gear_screen.dart';
import '../../features/tools/engineering/presentation/spring_force_screen.dart';
import '../../features/tools/engineering/presentation/stress_strain_screen.dart';
import '../../features/tools/engineering/presentation/torque_screen.dart';
import '../../features/tools/engineering/presentation/voltage_divider_screen.dart';
import '../../features/tools/engineering/presentation/young_modulus_screen.dart';
import '../../features/tools/everyday_calculators/presentation/discount_calculator_screen.dart';
import '../../features/tools/everyday_calculators/presentation/fuel_cost_screen.dart';
import '../../features/tools/everyday_calculators/presentation/percentage_calculator_screen.dart';
import '../../features/tools/everyday_calculators/presentation/tip_calculator_screen.dart';
import '../../features/tools/everyday_calculators/presentation/unit_price_screen.dart';
import '../../features/tools/finance/presentation/break_even_screen.dart';
import '../../features/tools/finance/presentation/cagr_screen.dart';
import '../../features/tools/finance/presentation/compound_interest_screen.dart' as fin_finance_compound_interest;
import '../../features/tools/finance/presentation/currency_screen.dart';
import '../../features/tools/finance/presentation/discount_sale_screen.dart';
import '../../features/tools/finance/presentation/loan_payment_screen.dart';
import '../../features/tools/finance/presentation/mortgage_screen.dart' as fin_finance_mortgage;
import '../../features/tools/finance/presentation/percentage_screen.dart' as fin_percentage;
import '../../features/tools/finance/presentation/profit_margin_screen.dart';
import '../../features/tools/finance/presentation/roi_screen.dart';
import '../../features/tools/finance/presentation/simple_interest_screen.dart' as fin_finance_simple_interest;
import '../../features/tools/finance/presentation/tip_split_screen.dart';
import '../../features/tools/financial/presentation/compound_interest_screen.dart';
import '../../features/tools/financial/presentation/discount_tax_screen.dart';
import '../../features/tools/financial/presentation/emi_screen.dart';
import '../../features/tools/financial/presentation/loan_screen.dart';
import '../../features/tools/financial/presentation/mortgage_screen.dart';
import '../../features/tools/financial/presentation/salary_screen.dart';
import '../../features/tools/financial/presentation/sales_tax_screen.dart';
import '../../features/tools/financial/presentation/savings_screen.dart';
import '../../features/tools/financial/presentation/simple_interest_screen.dart';
import '../../features/tools/financial/presentation/vat_screen.dart';
import '../../features/tools/math/presentation/advanced/complex_number_screen.dart';
import '../../features/tools/math/presentation/advanced/coordinate_geometry_screen.dart';
import '../../features/tools/math/presentation/advanced/cross_dot_product_screen.dart';
import '../../features/tools/math/presentation/advanced/curve_tangent_screen.dart';
import '../../features/tools/math/presentation/advanced/derivative_calculator_screen.dart';
import '../../features/tools/math/presentation/advanced/eigenvalues_screen.dart';
import '../../features/tools/math/presentation/advanced/exponent_root_screen.dart';
import '../../features/tools/math/presentation/advanced/factorial_gamma_screen.dart';
import '../../features/tools/math/presentation/advanced/integral_calculator_screen.dart';
import '../../features/tools/math/presentation/advanced/limit_evaluator_screen.dart';
import '../../features/tools/math/presentation/advanced/logarithm_screen.dart';
import '../../features/tools/math/presentation/advanced/matrix_calculator_screen.dart';
import '../../features/tools/math/presentation/advanced/matrix_inverse_screen.dart';
import '../../features/tools/math/presentation/advanced/numerical_methods_screen.dart';
import '../../features/tools/math/presentation/advanced/polynomial_screen.dart';
import '../../features/tools/math/presentation/advanced/root_bisection_screen.dart';
import '../../features/tools/math/presentation/advanced/sequence_calculator_screen.dart';
import '../../features/tools/math/presentation/advanced/series_summation_screen.dart';
import '../../features/tools/math/presentation/advanced/system_linear_equations_screen.dart';
import '../../features/tools/math/presentation/advanced/taylor_series_screen.dart';
import '../../features/tools/math/presentation/advanced/trigonometry_solver_screen.dart';
import '../../features/tools/math/presentation/advanced/vector_calculator_screen.dart';
import '../../features/tools/math/presentation/advanced/vector_projection_screen.dart';
import '../../features/tools/math/presentation/average_screen.dart';
import '../../features/tools/math/presentation/basic_probability_screen.dart';
import '../../features/tools/math/presentation/boolean_algebra_screen.dart';
import '../../features/tools/math/presentation/chi_square_test_screen.dart';
import '../../features/tools/math/presentation/chinese_remainder_screen.dart';
import '../../features/tools/math/presentation/circle_geometry_screen.dart';
import '../../features/tools/math/presentation/collatz_conjecture_screen.dart';
import '../../features/tools/math/presentation/combinations_screen.dart';
import '../../features/tools/math/presentation/cone_calculator_screen.dart';
import '../../features/tools/math/presentation/confidence_interval_screen.dart';
import '../../features/tools/math/presentation/cylinder_calculator_screen.dart';
import '../../features/tools/math/presentation/diophantine_equation_screen.dart';
import '../../features/tools/math/presentation/distributions_screen.dart';
import '../../features/tools/math/presentation/ellipse_geometry_screen.dart';
import '../../features/tools/math/presentation/euler_totient_screen.dart';
import '../../features/tools/math/presentation/fibonacci_golden_screen.dart';
import '../../features/tools/math/presentation/fraction_screen.dart';
import '../../features/tools/math/presentation/gcd_lcm_screen.dart';
import '../../features/tools/math/presentation/geometry_2d_screen.dart';
import '../../features/tools/math/presentation/hyperbola_geometry_screen.dart';
import '../../features/tools/math/presentation/linear_regression_screen.dart';
import '../../features/tools/math/presentation/mean_median_mode_screen.dart';
import '../../features/tools/math/presentation/modular_arithmetic_screen.dart';
import '../../features/tools/math/presentation/parabola_geometry_screen.dart';
import '../../features/tools/math/presentation/percentile_screen.dart';
import '../../features/tools/math/presentation/permutations_screen.dart';
import '../../features/tools/math/presentation/poisson_distribution_screen.dart';
import '../../features/tools/math/presentation/prime_checker_screen.dart';
import '../../features/tools/math/presentation/prime_factorization_screen.dart';
import '../../features/tools/math/presentation/prism_calculator_screen.dart';
import '../../features/tools/math/presentation/pyramid_calculator_screen.dart';
import '../../features/tools/math/presentation/pythagorean_screen.dart';
import '../../features/tools/math/presentation/quadratic_solver_screen.dart';
import '../../features/tools/math/presentation/range_iqr_screen.dart';
import '../../features/tools/math/presentation/ratio_proportion_screen.dart';
import '../../features/tools/math/presentation/regular_polygon_screen.dart';
import '../../features/tools/math/presentation/sphere_calculator_screen.dart';
import '../../features/tools/math/presentation/t_distribution_screen.dart';
import '../../features/tools/math/presentation/torus_calculator_screen.dart';
import '../../features/tools/math/presentation/triangle_solver_screen.dart';
import '../../features/tools/math/presentation/variance_std_dev_screen.dart';
import '../../features/tools/math/presentation/z_score_normal_screen.dart';
import '../../features/tools/physics/presentation/density_screen.dart';
import '../../features/tools/physics/presentation/electrical_power_screen.dart';
import '../../features/tools/physics/presentation/force_screen.dart';
import '../../features/tools/physics/presentation/gravitational_orbit_screen.dart';
import '../../features/tools/physics/presentation/kinetic_potential_screen.dart';
import '../../features/tools/physics/presentation/momentum_screen.dart';
import '../../features/tools/physics/presentation/ohms_law_screen.dart';
import '../../features/tools/physics/presentation/pressure_screen.dart';
import '../../features/tools/physics/presentation/projectile_motion_screen.dart';
import '../../features/tools/physics/presentation/resistance_screen.dart';
import '../../features/tools/physics/presentation/series_parallel_resistance_screen.dart';
import '../../features/tools/physics/presentation/velocity_screen.dart';
import '../../features/tools/physics/presentation/wave_speed_screen.dart';
import '../../features/tools/physics/presentation/work_energy_screen.dart';
import '../../features/tools/unit_converter/presentation/unit_converter_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Calculator (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  final initialState = WebStateSerializer.decodeState(
                    state.uri.queryParameters['state'],
                  );
                  return CalculatorScreen(initialStateJson: initialState);
                },
                routes: [
                  GoRoute(
                    path: 'calculator/equation',
                    builder: (context, state) {
                      final initialState = WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      );
                      return EquationSolverScreen(
                        initialStateJson: initialState,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'calculator/graph',
                    builder: (context, state) {
                      final initialState = WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      );
                      return GraphingScreen(initialStateJson: initialState);
                    },
                  ),
                  GoRoute(
                    path: 'calculator/table',
                    builder: (context, state) {
                      final initialState = WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      );
                      return TableScreen(initialStateJson: initialState);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Tools (150 Specialized Calculation Tools)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                builder: (context, state) => const ToolsScreen(),
                routes: [
                  GoRoute(
                    path: 'directory',
                    builder: (context, state) => const AllToolsScreen(),
                  ),
                  GoRoute(
                    path: 'category/:slug',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      final cat = ToolCategory.values.firstWhere(
                        (c) => c.name == slug,
                        orElse: () => ToolCategory.other,
                      );
                      return CategoryScreen(category: cat);
                    },
                  ),
                  GoRoute(
                    path: 'unit_converter',
                    builder: (context, state) {
                      final initialState = WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      );
                      return UnitConverterScreen(
                        initialStateJson: initialState,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':category',
                        builder: (context, state) {
                          final catSlug = state.pathParameters['category'];
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return UnitConverterScreen(
                            categorySlug: catSlug,
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: CHEMISTRY (8 tools) ---
                  GoRoute(
                    path: 'chemistry',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'concentration',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ConcentrationScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'dilution',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DilutionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'gas_law',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return GasLawScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'ideal_gas',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return IdealGasScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'molar_mass',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MolarMassScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'molarity',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MolarityScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'ph',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PhScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'stoichiometry',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return StoichiometryScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: DATE_TIME (15 tools) ---
                  GoRoute(
                    path: 'date_time',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'age_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return AgeCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'business_days',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return BusinessDaysScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'countdown',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CountdownScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'date_add_subtract',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DateAddSubtractScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'date_diff',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DateDiffScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'date_difference',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DateDifferenceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'date_formatter',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DateFormatterScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'day_of_week',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DayOfWeekScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'stopwatch_timer',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return StopwatchTimerScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'time_add_subtract',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TimeAddSubtractScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'time_difference',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TimeDifferenceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'time_math',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TimeMathScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'time_zone_converter',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TimeZoneConverterScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'timestamp_converter',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TimestampConverterScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'week_number',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return WeekNumberScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: DEVELOPER (6 tools) ---
                  GoRoute(
                    path: 'developer',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'bitwise',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return BitwiseScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'color_converter',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ColorConverterScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'data_transfer',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DataTransferScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'developer_utilities',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DeveloperUtilitiesScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'number_base',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return NumberBaseScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'unix_timestamp',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return UnixTimestampScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: ENGINEERING (14 tools) ---
                  GoRoute(
                    path: 'engineering',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'capacitors',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CapacitorsScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'electrical_energy',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ElectricalEnergyScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'gear_ratio',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return GearRatioScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'inductors',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return InductorsScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'led_resistor',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return LedResistorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'mechanical_advantage',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MechanicalAdvantageScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'mechanical_efficiency',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MechanicalEfficiencyScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'rc_time_constant',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return RcTimeConstantScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'rpm_gear',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return RpmGearScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'spring_force',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SpringForceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'stress_strain',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return StressStrainScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'torque',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TorqueScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'voltage_divider',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return VoltageDividerScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'young_modulus',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return YoungModulusScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: EVERYDAY (5 tools) ---
                  GoRoute(
                    path: 'everyday',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'discount_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DiscountCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'fuel_cost',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return FuelCostScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'percentage_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PercentageCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'tip_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TipCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'unit_price',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return UnitPriceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: FINANCE (12 tools) ---
                  GoRoute(
                    path: 'finance',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'break_even',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return BreakEvenScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'cagr',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CagrScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'compound_interest',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return fin_finance_compound_interest.CompoundInterestScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'currency',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CurrencyScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'discount_sale',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DiscountSaleScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'loan_payment',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return LoanPaymentScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'mortgage',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return fin_finance_mortgage.MortgageScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'percentage',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return fin_percentage.PercentageScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'profit_margin',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ProfitMarginScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'roi',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return RoiScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'simple_interest',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return fin_finance_simple_interest.SimpleInterestScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'tip_split',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TipSplitScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: FINANCIAL (10 tools) ---
                  GoRoute(
                    path: 'financial',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'compound_interest',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CompoundInterestScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'discount_tax',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DiscountTaxScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'emi',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return EmiScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'loan',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return LoanScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'mortgage',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MortgageScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'salary',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SalaryScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'sales_tax',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SalesTaxScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'savings',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SavingsScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'simple_interest',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SimpleInterestScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'vat',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return VatScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Group: MATH (65 tools) ---
                  GoRoute(
                    path: 'math',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'average',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return AverageScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'basic_probability',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return BasicProbabilityScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'boolean_algebra',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return BooleanAlgebraScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'chi_square_test',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ChiSquareTestScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'chinese_remainder',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ChineseRemainderScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'circle_geometry',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CircleGeometryScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'collatz_conjecture',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CollatzConjectureScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'combinations',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CombinationsScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'cone_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ConeCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'confidence_interval',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ConfidenceIntervalScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'cylinder_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return CylinderCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'diophantine_equation',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DiophantineEquationScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'distributions',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DistributionsScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'ellipse_geometry',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return EllipseGeometryScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'euler_totient',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return EulerTotientScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'fibonacci_golden',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return FibonacciGoldenScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'fraction',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return FractionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'gcd_lcm',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return GcdLcmScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'geometry_2d',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return Geometry2DScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'hyperbola_geometry',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return HyperbolaGeometryScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'linear_regression',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return LinearRegressionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'mean_median_mode',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MeanMedianModeScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'modular_arithmetic',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ModularArithmeticScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'parabola_geometry',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ParabolaGeometryScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'percentile',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PercentileScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'permutations',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PermutationsScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'poisson_distribution',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PoissonDistributionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'prime_checker',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PrimeCheckerScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'prime_factorization',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PrimeFactorizationScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'prism_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PrismCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'pyramid_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PyramidCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'pythagorean',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PythagoreanScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'quadratic_solver',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return QuadraticSolverScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'range_iqr',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return RangeIqrScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'ratio_proportion',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return RatioProportionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'regular_polygon',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return RegularPolygonScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'sphere_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SphereCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 't_distribution',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TDistributionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'torus_calculator',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TorusCalculatorScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'triangle_solver',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return TriangleSolverScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'variance_std_dev',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return VarianceStdDevScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'z_score_normal',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ZScoreNormalScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'advanced',
                        builder: (context, state) => const ToolsScreen(),
                        routes: [
                          GoRoute(
                            path: 'complex_number',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return ComplexNumberScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'coordinate_geometry',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return CoordinateGeometryScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'cross_dot_product',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return CrossDotProductScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'curve_tangent',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return CurveTangentScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'derivative_calculator',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return DerivativeCalculatorScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'eigenvalues',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return EigenvaluesScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'exponent_root',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return ExponentRootScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'factorial_gamma',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return FactorialGammaScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'integral_calculator',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return IntegralCalculatorScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'limit_evaluator',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return LimitEvaluatorScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'logarithm',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return LogarithmScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'matrix_calculator',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return MatrixCalculatorScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'matrix_inverse',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return MatrixInverseScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'numerical_methods',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return NumericalMethodsScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'polynomial',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return PolynomialScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'root_bisection',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return RootBisectionScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'sequence_calculator',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return SequenceCalculatorScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'series_summation',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return SeriesSummationScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'system_linear_equations',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return SystemLinearEquationsScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'taylor_series',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return TaylorSeriesScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'trigonometry_solver',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return TrigonometrySolverScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'vector_calculator',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return VectorCalculatorScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'vector_projection',
                            builder: (context, state) {
                              final initialState = WebStateSerializer.decodeState(
                                state.uri.queryParameters['state'],
                              );
                              return VectorProjectionScreen(
                                initialStateJson: initialState,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // --- Group: PHYSICS (14 tools) ---
                  GoRoute(
                    path: 'physics',
                    builder: (context, state) => const ToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'density',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return DensityScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'electrical_power',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ElectricalPowerScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'force',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ForceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'gravitational_orbit',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return GravitationalOrbitScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'kinetic_potential',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return KineticPotentialScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'momentum',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return MomentumScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'ohms_law',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return OhmsLawScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'pressure',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return PressureScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'projectile_motion',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ProjectileMotionScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'resistance',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return ResistanceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'series_parallel_resistance',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return SeriesParallelResistanceScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'velocity',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return VelocityScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'wave_speed',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return WaveSpeedScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'work_energy',
                        builder: (context, state) {
                          final initialState = WebStateSerializer.decodeState(
                            state.uri.queryParameters['state'],
                          );
                          return WorkEnergyScreen(
                            initialStateJson: initialState,
                          );
                        },
                      ),
                    ],
                  ),
                  // --- Legacy Top-Level Aliases for Compatibility ---
                  GoRoute(
                    path: 'percentage',
                    builder: (context, state) => PercentageCalculatorScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'discount',
                    builder: (context, state) => DiscountCalculatorScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'tip',
                    builder: (context, state) => TipCalculatorScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'fuel_cost',
                    builder: (context, state) => FuelCostScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'unit_price',
                    builder: (context, state) => UnitPriceScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'date_diff',
                    builder: (context, state) => DateDiffScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'time_math',
                    builder: (context, state) => TimeMathScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'average',
                    builder: (context, state) => AverageScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'fraction',
                    builder: (context, state) => FractionScreen(
                      initialStateJson: WebStateSerializer.decodeState(
                        state.uri.queryParameters['state'],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),

          // Branch 3: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'theme',
                    builder: (context, state) => const ThemeSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'haptics',
                    builder: (context, state) => const HapticsSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'data',
                    builder: (context, state) => const DataSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'ecosystem',
                    builder: (context, state) => const EcosystemScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                  GoRoute(
                    path: 'support',
                    builder: (context, state) => const SupportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

final routerProvider = appRouterProvider;
