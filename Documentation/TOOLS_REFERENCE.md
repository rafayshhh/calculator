# Calculator — Complete 150 Specialized Tools Reference

Calculator features **150 specialized mathematical, scientific, engineering, and statistical calculation tools** alongside **4 core calculation workspaces** (Arithmetic Calculator, Equation Solver, Function Grapher, and Function Table) and a **15-category Unit Converter**.

All calculation engines are implemented as pure, deterministic algorithms executing **100% on-device** with zero network calls, zero analytics, and zero external tracking.

---

## 🧭 Category Index

1. [1. Mathematics, Calculus & Geometry Suite (51 Tools)](#1-mathematics-calculus-geometry-suite)
2. [2. Statistics, Probability & Inferential Data Science (14 Tools)](#2-statistics-probability-inferential-data-science)
3. [3. Classical Physics & Mechanics Suite (14 Tools)](#3-classical-physics-mechanics-suite)
4. [4. Engineering & Circuit Analysis Suite (14 Tools)](#4-engineering-circuit-analysis-suite)
5. [5. Chemistry & Molecular Science Suite (8 Tools)](#5-chemistry-molecular-science-suite)
6. [6. Finance & Quantitative Mathematical Modeling (22 Tools)](#6-finance-quantitative-mathematical-modeling)
7. [7. Everyday Practical Calculators (5 Tools)](#7-everyday-practical-calculators)
8. [8. Date, Time & Calendar Mathematics (15 Tools)](#8-date-time-calendar-mathematics)
9. [9. Developer & Computer Science Utilities (6 Tools)](#9-developer-computer-science-utilities)
10. [10. Universal Unit Conversion Suite (1 Tools)](#10-universal-unit-conversion-suite)

---

## 1. Mathematics, Calculus & Geometry Suite

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Complex Numbers** | `/tools/math/advanced/complex_number` | Compute complex arithmetic, magnitude (modulus), and phase argument. | `ComplexNumberEngine` |
| 2 | **Coordinate Geometry** | `/tools/math/advanced/coordinate_geometry` | Compute Euclidean distance, midpoint, line slope, and linear equations between 2D points. | `CoordinateGeometryEngine` |
| 3 | **Cross & Dot Product (3D)** | `/tools/math/advanced/cross_dot_product` | Computes 3D dot product, cross product vector, and parallelogram area | `CrossDotProductEngine` |
| 4 | **Tangent & Normal Line Equations** | `/tools/math/advanced/curve_tangent` | Computes tangent and normal slopes and linear equations at curve point | `CurveTangentEngine` |
| 5 | **Numerical & Polynomial Derivative** | `/tools/math/advanced/derivative_calculator` | First and second order derivatives with concavity analysis | `DerivativeCalculatorEngine` |
| 6 | **Matrix Eigenvalues & Trace** | `/tools/math/advanced/eigenvalues` | Computes eigenvalues, trace, and determinant for 2x2 matrix | `EigenvaluesEngine` |
| 7 | **Exponents & Roots** | `/tools/math/advanced/exponent_root` | Compute powers, square roots, cube roots, and general nth-degree radical roots. | `ExponentRootEngine` |
| 8 | **Factorial & Gamma Function** | `/tools/math/advanced/factorial_gamma` | Evaluate integer factorials (n!) and real Gamma function values Γ(x). | `FactorialGammaEngine` |
| 9 | **Definite Integral Calculator** | `/tools/math/advanced/integral_calculator` | Computes exact polynomial and Simpson integration across bounds [a, b] | `IntegralCalculatorEngine` |
| 10 | **Function Limit Evaluator** | `/tools/math/advanced/limit_evaluator` | Computes left, right, and two-sided limits as x approaches target c | `LimitEvaluatorEngine` |
| 11 | **Logarithm Calculator** | `/tools/math/advanced/logarithm` | Evaluate natural log (ln), common log (log₁₀), and arbitrary base logarithms. | `LogarithmEngine` |
| 12 | **Matrix Calculator** | `/tools/math/advanced/matrix_calculator` | Compute matrix determinant (det A), trace, and inversion properties. | `MatrixCalculatorEngine` |
| 13 | **Matrix Inversion Calculator** | `/tools/math/advanced/matrix_inverse` | Computes determinant and matrix inverse A⁻¹ | `MatrixInverseEngine` |
| 14 | **Numerical Methods** | `/tools/math/advanced/numerical_methods` | Iterative root approximation via Newton-Raphson numerical algorithm. | `NumericalMethodsEngine` |
| 15 | **Polynomial Calculator** | `/tools/math/advanced/polynomial` | Evaluate polynomials P(x) = a₀ + a₁x + a₂x² + ... and analytical derivatives P\ | `PolynomialEngine` |
| 16 | **Bisection Root Finder** | `/tools/math/advanced/root_bisection` | Locates transcendental roots in interval [a, b] using binary subdivision | `RootBisectionEngine` |
| 17 | **Sequence & Progressions** | `/tools/math/advanced/sequence_calculator` | Compute nth term and series sum for arithmetic and geometric progressions. | `SequenceCalculatorEngine` |
| 18 | **Series Summation (Σ)** | `/tools/math/advanced/series_summation` | Compute finite series power sums Σ k^p over custom integer intervals. | `SeriesSummationEngine` |
| 19 | **Linear Systems Solver (2x2)** | `/tools/math/advanced/system_linear_equations` | Solves simultaneous equations a₁x + b₁y = c₁, a₂x + b₂y = c₂ | `SystemLinearEquationsEngine` |
| 20 | **Taylor & Maclaurin Series** | `/tools/math/advanced/taylor_series` | Polynomial approximation around expansion point a | `TaylorSeriesEngine` |
| 21 | **Trigonometry Solver** | `/tools/math/advanced/trigonometry_solver` | Evaluate sine, cosine, tangent, and trigonometric functions in degrees or radians. | `TrigonometrySolverEngine` |
| 22 | **3D Vector Calculator** | `/tools/math/advanced/vector_calculator` | Compute vector dot product, cross product, magnitude, and angle between 3D vectors. | `VectorCalculatorEngine` |
| 23 | **Vector Projection & Angle** | `/tools/math/advanced/vector_projection` | Computes scalar projection, vector projection of v onto u, and angle θ | `VectorProjectionEngine` |
| 24 | **Average & Mean Calculator** | `/tools/math/average` | Calculate arithmetic mean, median, sum, and range of number sets. | `AverageEngine` |
| 25 | **Boolean Algebra & Logic Gates** | `/tools/math/boolean_algebra` | Computes truth table outputs for AND, OR, XOR, NAND, NOR, and XNOR | `BooleanAlgebraEngine` |
| 26 | **Chinese Remainder Theorem (CRT)** | `/tools/math/chinese_remainder` | Solves system of simultaneous congruences x ≡ r_i (mod m_i) | `ChineseRemainderEngine` |
| 27 | **Circle & Sector Geometry** | `/tools/math/circle_geometry` | Calculates radius, diameter, area, circumference, arc length, and sector | `CircleGeometryEngine` |
| 28 | **Collatz Conjecture (3n + 1)** | `/tools/math/collatz_conjecture` | Simulates hailstone sequence trajectory, stopping time, and peak altitude | `CollatzConjectureEngine` |
| 29 | **Cone Slant, Surface & Volume** | `/tools/math/cone_calculator` | Right circular cone slant height, lateral area, and volume | `ConeCalculatorEngine` |
| 30 | **Cylinder Surface & Volume** | `/tools/math/cylinder_calculator` | Calculates base area, lateral surface, total surface, and volume | `CylinderCalculatorEngine` |
| 31 | **Linear Diophantine Equation** | `/tools/math/diophantine_equation` | Finds integer solutions (x, y) to ax + by = c using Euclidean algorithm | `DiophantineEquationEngine` |
| 32 | **Ellipse Area, Perimeter & Foci** | `/tools/math/ellipse_geometry` | Calculates area, Ramanujan perimeter, foci, and eccentricity | `EllipseGeometryEngine` |
| 33 | **Euler** | `/tools/math/euler_totient` | Counts positive integers up to n that are relatively prime to n | `EulerTotientEngine` |
| 34 | **Fibonacci & Golden Ratio (φ)** | `/tools/math/fibonacci_golden` | Calculates Fn, ratio Fn/Fn-1, and convergence to Golden Ratio φ | `FibonacciGoldenEngine` |
| 35 | **Fraction Simplifier** | `/tools/math/fraction` | Reduce fractions to lowest terms and convert to mixed numerals and decimals. | `FractionEngine` |
| 36 | **GCD & LCM Calculator** | `/tools/math/gcd_lcm` | Compute Greatest Common Divisor and Least Common Multiple of integers. | `GcdLcmEngine` |
| 37 | **2D Geometry** | `/tools/math/geometry_2d` | Calculate area, perimeter, and dimensions of shapes | `Geometry2DEngine` |
| 38 | **Hyperbola Foci & Asymptotes** | `/tools/math/hyperbola_geometry` | Focal distance, eccentricity, and linear asymptotes of hyperbola | `HyperbolaGeometryEngine` |
| 39 | **Modular Arithmetic & Inverses** | `/tools/math/modular_arithmetic` | Computes (a ± b) mod m, (a * b) mod m, a^b mod m, and inverse a⁻¹ mod m | `ModularArithmeticEngine` |
| 40 | **Parabola Conic Properties** | `/tools/math/parabola_geometry` | Vertex, focus, directrix equation, and axis of symmetry | `ParabolaGeometryEngine` |
| 41 | **Prime & Factorization** | `/tools/math/prime_checker` | Check primality and find prime factorization | `PrimeCheckerEngine` |
| 42 | **Prime Factorization & Multiplicity** | `/tools/math/prime_factorization` | Decomposes positive integers into canonical prime factors | `PrimeFactorizationEngine` |
| 43 | **Rectangular Prism & Space Diagonal** | `/tools/math/prism_calculator` | Computes 3D cuboid volume, surface area, and space diagonal | `PrismCalculatorEngine` |
| 44 | **Pyramid Surface & Volume** | `/tools/math/pyramid_calculator` | Rectangular pyramid base area, slant faces, and volume | `PyramidCalculatorEngine` |
| 45 | **Pythagorean Theorem** | `/tools/math/pythagorean` | Solve missing sides of right triangles using a² + b² = c². | `PythagoreanEngine` |
| 46 | **Quadratic Equation Solver** | `/tools/math/quadratic_solver` | Solve quadratic equations ax² + bx + c = 0, discriminant Δ, and parabola vertex. | `QuadraticSolverEngine` |
| 47 | **Ratio & Proportion** | `/tools/math/ratio_proportion` | Solve proportions a : b = c : d and simplify ratios | `RatioProportionEngine` |
| 48 | **Regular Polygon Calculator** | `/tools/math/regular_polygon` | Calculates interior angles, apothem, perimeter, and area of regular n-gon | `RegularPolygonEngine` |
| 49 | **Sphere & Hemisphere 3D** | `/tools/math/sphere_calculator` | Computes total surface area and volume of spheres and hemispheres | `SphereCalculatorEngine` |
| 50 | **Torus Surface Area & Volume** | `/tools/math/torus_calculator` | Ring torus 3D geometric properties | `TorusCalculatorEngine` |
| 51 | **Triangle Solver (SSS & Angles)** | `/tools/math/triangle_solver` | Computes angles, area, perimeter, inradius, and circumradius for triangle | `TriangleSolverEngine` |

---

## 2. Statistics, Probability & Inferential Data Science

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Basic Probability** | `/tools/math/basic_probability` | Calculate likelihood of events, complements, and odds | `BasicProbabilityEngine` |
| 2 | **Chi-Square (χ²) Goodness of Fit** | `/tools/math/chi_square_test` | Tests observed frequencies against theoretical expected values | `ChiSquareTestEngine` |
| 3 | **Combinations (nCr)** | `/tools/math/combinations` | Unordered subsets of r elements chosen from n items | `CombinationsEngine` |
| 4 | **Confidence Interval for Population Mean** | `/tools/math/confidence_interval` | Computes standard error, margin of error, and confidence bounds [Lower, Upper] | `ConfidenceIntervalEngine` |
| 5 | **Probability Distributions** | `/tools/math/distributions` | Compute binomial probability mass function P(X = k) and cumulative likelihoods. | `DistributionsEngine` |
| 6 | **Ordinary Least Squares Linear Regression** | `/tools/math/linear_regression` | Finds best fit line y = mx + b, Pearson | `LinearRegressionEngine` |
| 7 | **Mean, Median & Mode** | `/tools/math/mean_median_mode` | Analyze central tendency metrics across sample datasets. | `MeanMedianModeEngine` |
| 8 | **Percentile Calculator** | `/tools/math/percentile` | Compute arbitrary kth percentile thresholds using linear rank interpolation. | `PercentileEngine` |
| 9 | **Permutations & Combinations** | `/tools/math/permutations` | Compute permutations nPr and combinations nCr of finite sets. | `PermutationsEngine` |
| 10 | **Poisson Distribution Probability** | `/tools/math/poisson_distribution` | Computes exact PMF P(X = k) and cumulative probability P(X ≤ k) | `PoissonDistributionEngine` |
| 11 | **Range & Interquartile Range (IQR)** | `/tools/math/range_iqr` | Compute statistical spread, quartiles Q1/Q3, and outlier threshold fences. | `RangeIqrEngine` |
| 12 | **Student** | `/tools/math/t_distribution` | Computes degrees of freedom df = n - 1, t-score, and critical thresholds | `TDistributionEngine` |
| 13 | **Variance & Standard Deviation** | `/tools/math/variance_std_dev` | Compute sample and population dispersion, variance, and standard deviation. | `VarianceStdDevEngine` |
| 14 | **Z-Score & Normal Distribution CDF** | `/tools/math/z_score_normal` | Calculates standard score Z, cumulative probability, and tail p-values | `ZScoreNormalEngine` |

---

## 3. Classical Physics & Mechanics Suite

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Density Calculator** | `/tools/physics/density` | Volumetric mass density & mass-volume relations (ρ = m/V) | `DensityEngine` |
| 2 | **Electrical Power Calculator** | `/tools/physics/electrical_power` | Compute electric power (P = VI) in Watts and kiloWatts. | `ElectricalPowerEngine` |
| 3 | **Force Calculator** | `/tools/physics/force` | Compute net force according to Newton | `ForceEngine` |
| 4 | **Orbital Mechanics & Gravitation** | `/tools/physics/gravitational_orbit` | Computes circular orbital velocity, period, and Newton | `GravitationalOrbitEngine` |
| 5 | **Kinetic & Potential Energy** | `/tools/physics/kinetic_potential` | Calculate kinetic energy (½mv²) and gravitational potential energy (mgh). | `KineticPotentialEngine` |
| 6 | **Momentum Calculator** | `/tools/physics/momentum` | Compute linear momentum (p = mv) of moving bodies. | `MomentumEngine` |
| 7 | **Ohm** | `/tools/physics/ohms_law` | Solve voltage, current, and resistance in DC electrical circuits. | `OhmsLawEngine` |
| 8 | **Pressure Calculator** | `/tools/physics/pressure` | Compute hydrostatic and mechanical pressure (P = F / A) in Pascals and atmospheres. | `PressureEngine` |
| 9 | **Projectile Motion 2D Kinematics** | `/tools/physics/projectile_motion` | Computes flight time, horizontal range, and maximum trajectory altitude | `ProjectileMotionEngine` |
| 10 | **Resistance Calculator** | `/tools/physics/resistance` | Compute electrical resistance from potential drop and current. | `ResistanceEngine` |
| 11 | **Series & Parallel Resistors** | `/tools/physics/series_parallel_resistance` | Compute equivalent resistance of series and parallel resistor networks. | `SeriesParallelResistanceEngine` |
| 12 | **Velocity Calculator** | `/tools/physics/velocity` | Compute average linear velocity from displacement and elapsed time. | `VelocityEngine` |
| 13 | **Wave Speed Calculator** | `/tools/physics/wave_speed` | Compute phase velocity of mechanical and electromagnetic waves (v = fλ). | `WaveSpeedEngine` |
| 14 | **Work & Energy Calculator** | `/tools/physics/work_energy` | Compute mechanical work done (W = F · d · cos θ) in Joules. | `WorkEnergyEngine` |

---

## 4. Engineering & Circuit Analysis Suite

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Capacitor Networks** | `/tools/engineering/capacitors` | Compute equivalent capacitance in series (1/C) and parallel (ΣC) circuits. | `CapacitorsEngine` |
| 2 | **Electrical Energy & Cost** | `/tools/engineering/electrical_energy` | Calculate appliance kWh energy consumption and utility electricity bill costs | `ElectricalEnergyEngine` |
| 3 | **Gear Ratio Calculator** | `/tools/engineering/gear_ratio` | Compute drive gear train ratio, torque multiplication, and speed reduction. | `GearRatioEngine` |
| 4 | **Inductor Networks** | `/tools/engineering/inductors` | Compute equivalent inductance in series (ΣL) and parallel (1/L) circuits. | `InductorsEngine` |
| 5 | **LED Resistor Calculator** | `/tools/engineering/led_resistor` | Current-limiting series resistor & power dissipation for LEDs | `LedResistorEngine` |
| 6 | **Mechanical Advantage** | `/tools/engineering/mechanical_advantage` | Compute mechanical force multiplication factor (MA = F_out / F_in). | `MechanicalAdvantageEngine` |
| 7 | **Mechanical Efficiency** | `/tools/engineering/mechanical_efficiency` | Useful output vs. total input energy or power ratio | `MechanicalEfficiencyEngine` |
| 8 | **RC Time Constant** | `/tools/engineering/rc_time_constant` | Calculate charging and discharging time constant (τ = R · C) of RC circuits. | `RcTimeConstantEngine` |
| 9 | **RPM & Gear Speed** | `/tools/engineering/rpm_gear` | Compute driven shaft rotational speed from input RPM and gear reduction ratio. | `RpmGearEngine` |
| 10 | **Spring Force (Hooke** | `/tools/engineering/spring_force` | Calculate restoring elastic force (F = -kx) from Hooke | `SpringForceEngine` |
| 11 | **Stress & Strain Calculator** | `/tools/engineering/stress_strain` | Compute normal stress (σ = F/A) and engineering strain (ε = ΔL/L). | `StressStrainEngine` |
| 12 | **Torque Calculator** | `/tools/engineering/torque` | Compute rotational moment of force (τ = r · F · sin θ) in Newton-meters. | `TorqueEngine` |
| 13 | **Voltage Divider** | `/tools/engineering/voltage_divider` | Calculate output voltage and resistor network ratio (Vout = Vin · R2 / (R1 + R2)) | `VoltageDividerEngine` |
| 14 | **Young** | `/tools/engineering/young_modulus` | Compute material elastic modulus (E = σ / ε) in GigaPascals. | `YoungModulusEngine` |

---

## 5. Chemistry & Molecular Science Suite

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Concentration Calculator** | `/tools/chemistry/concentration` | Compute mass concentration percentage (% w/w) and ppm solutions. | `ConcentrationEngine` |
| 2 | **Dilution Calculator** | `/tools/chemistry/dilution` | Compute required stock volume for desired dilution using M₁V₁ = M₂V₂. | `DilutionEngine` |
| 3 | **Gas Laws Calculator** | `/tools/chemistry/gas_law` | Compute isobaric, isochoric, and isothermal gas state transitions. | `GasLawEngine` |
| 4 | **Ideal Gas Law** | `/tools/chemistry/ideal_gas` | Equation of state relating pressure, volume, amount, and temperature across ideal gases | `IdealGasEngine` |
| 5 | **Molar Mass Calculator** | `/tools/chemistry/molar_mass` | Calculate molecular weight, molar mass, and stoichiometric elemental composition | `MolarMassEngine` |
| 6 | **Molarity Calculator** | `/tools/chemistry/molarity` | Calculate concentration in molarity (mol/L), moles, or volume | `MolarityEngine` |
| 7 | **pH Calculator** | `/tools/chemistry/ph` | Compute pH, pOH, and hydronium concentration in aqueous equilibrium. | `PhEngine` |
| 8 | **Stoichiometry Calculator** | `/tools/chemistry/stoichiometry` | Compute theoretical molar yield and mass products from balanced reaction coefficients. | `StoichiometryEngine` |

---

## 6. Finance & Quantitative Mathematical Modeling

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Break-Even Analysis** | `/tools/finance/break_even` | Compute unit sales threshold and revenue required to recover operational costs. | `BreakEvenEngine` |
| 2 | **CAGR Calculator** | `/tools/finance/cagr` | Compute Compound Annual Growth Rate of investments across multi-year horizons. | `CagrEngine` |
| 3 | **Compound Interest** | `/tools/finance/compound_interest` | Compute compound interest accrual and future investment balances. | `CompoundInterestEngine` |
| 4 | **Currency Converter** | `/tools/finance/currency` | Convert between currencies using customized or live exchange rates. | `CurrencyEngine` |
| 5 | **Discount & Sale Calculator** | `/tools/finance/discount_sale` | Compute final checkout price after stacked discounts and localized sales tax. | `DiscountSaleEngine` |
| 6 | **Loan Payment Calculator** | `/tools/finance/loan_payment` | Calculate monthly installment payments and interest totals on personal or auto loans. | `LoanPaymentEngine` |
| 7 | **Mortgage Calculator** | `/tools/finance/mortgage` | Compute monthly mortgage payments, interest amortizations, and down payment ratios. | `MortgageEngine` |
| 8 | **Percentage Calculator** | `/tools/finance/percentage` | Compute percent of values, rate changes, differences, and reverse percentages. | `PercentageEngine` |
| 9 | **Profit Margin & Markup** | `/tools/finance/profit_margin` | Compute gross profit margin percentage and sales markup. | `ProfitMarginEngine` |
| 10 | **Return on Investment (ROI)** | `/tools/finance/roi` | Compute overall capital gain percentage and net profitability from invested assets. | `RoiEngine` |
| 11 | **Simple Interest Calculator** | `/tools/finance/simple_interest` | Compute linear interest accumulation (I = P · r · t). | `SimpleInterestEngine` |
| 12 | **Tip & Bill Splitter** | `/tools/finance/tip_split` | Calculate gratuity amounts and divide dining bills evenly across party members. | `TipSplitEngine` |
| 13 | **Compound Interest & Savings** | `/tools/financial/compound_interest` | Calculate periodic compounding wealth growth with recurring monthly contributions. | `CompoundInterestEngine` |
| 14 | **Discount & Tax** | `/tools/financial/discount_tax` | Compute final checkout price with applied promotional discount and tax. | `DiscountTaxEngine` |
| 15 | **Equated Monthly Installment (EMI)** | `/tools/financial/emi` | Compute precise monthly loan installment and total repayment breakdown. | `EmiEngine` |
| 16 | **Loan Amortization** | `/tools/financial/loan` | Compute total principal amortization, interest costs, and paydown schedule. | `LoanEngine` |
| 17 | **Mortgage Amortization** | `/tools/financial/mortgage` | Compute residential mortgage installments and aggregate interest payments. | `MortgageEngine` |
| 18 | **Salary & Wage Converter** | `/tools/financial/salary` | Convert between hourly wage, weekly paycheck, monthly income, and annual salary. | `SalaryEngine` |
| 19 | **Sales Tax Calculator** | `/tools/financial/sales_tax` | Compute retail sales tax amount and total transaction cost. | `SalesTaxEngine` |
| 20 | **Savings Calculator** | `/tools/financial/savings` | Plan and project your savings. | `SavingsEngine` |
| 21 | **Simple Interest** | `/tools/financial/simple_interest` | Calculate basic simple interest. | `SimpleInterestEngine` |
| 22 | **Value Added Tax (VAT)** | `/tools/financial/vat` | Compute inclusive and exclusive Value Added Tax. | `VatEngine` |

---

## 7. Everyday Practical Calculators

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Discount Calculator** | `/tools/everyday/discount_calculator` | Calculate final checkout prices, applied savings, and total discount amount | `DiscountCalculatorEngine` |
| 2 | **Fuel Cost Calculator** | `/tools/everyday/fuel_cost` | Compute trip fuel consumption, required volume, and total travel cost | `FuelCostEngine` |
| 3 | **Percentage Calculator** | `/tools/everyday/percentage_calculator` | Compute percent of values, proportions, and percentage increase/decrease. | `PercentageCalculatorEngine` |
| 4 | **Tip Calculator** | `/tools/everyday/tip_calculator` | Calculate gratuity and split dining checks evenly per person | `TipCalculatorEngine` |
| 5 | **Unit Price Comparison** | `/tools/everyday/unit_price` | Find the best deal by comparing price per unit across packaging sizes. | `UnitPriceEngine` |

---

## 8. Date, Time & Calendar Mathematics

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Age Calculator** | `/tools/date_time/age_calculator` | Calculate precise biological age in years, months, days, and total hours. | `AgeCalculatorEngine` |
| 2 | **Business Days Calculator** | `/tools/date_time/business_days` | Compute working days between dates with custom weekend models and excluded holidays | `BusinessDaysEngine` |
| 3 | **Event Countdown** | `/tools/date_time/countdown` | Compute precise remaining time until target events or deadlines. | `CountdownEngine` |
| 4 | **Add / Subtract Date** | `/tools/date_time/date_add_subtract` | Add or subtract years, months, weeks, and days with calendar-accurate month clamping | `DateAddSubtractEngine` |
| 5 | **Date Difference** | `/tools/date_time/date_diff` | Calculate the exact time between two dates (also works for Age). | `DateDiffEngine` |
| 6 | **Date Difference Calculator** | `/tools/date_time/date_difference` | Compute exact elapsed calendar time and total days between two dates. | `DateDifferenceEngine` |
| 7 | **Date Formatter** | `/tools/date_time/date_formatter` | Convert and inspect international date strings and standards. | `DateFormatterEngine` |
| 8 | **Day of the Week** | `/tools/date_time/day_of_week` | Identify the exact day of the week and yearly metrics for any calendar date. | `DayOfWeekEngine` |
| 9 | **Stopwatch & Timer** | `/tools/date_time/stopwatch_timer` | High-precision lap timer and millisecond stopwatch. | `StopwatchTimerEngine` |
| 10 | **Time Add / Subtract** | `/tools/date_time/time_add_subtract` | Add or subtract hours and minutes from any clock time. | `TimeAddSubtractEngine` |
| 11 | **Time Difference** | `/tools/date_time/time_difference` | Calculate elapsed duration between two clock times across hours and minutes. | `TimeDifferenceEngine` |
| 12 | **Add/Subtract Time** | `/tools/date_time/time_math` | Add or subtract years, months, days, and time from a specific date. | `TimeMathEngine` |
| 13 | **Time Zone Converter** | `/tools/date_time/time_zone_converter` | Convert date and clock times between international timezone offsets. | `TimeZoneConverterEngine` |
| 14 | **Timestamp Converter** | `/tools/date_time/timestamp_converter` | Bidirectional converter between Unix seconds, milliseconds, UTC, Local DateTime, and ISO 8601 | `TimestampConverterEngine` |
| 15 | **Week Number** | `/tools/date_time/week_number` | Compute ISO 8601 calendar week number for any date. | `WeekNumberEngine` |

---

## 9. Developer & Computer Science Utilities

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **Bitwise Logic Operations** | `/tools/developer/bitwise` | Perform bitwise AND, OR, XOR, NOT, NAND, NOR, and bitshifts across configurable bit widths. | `BitwiseEngine` |
| 2 | **RGB ↔ HEX Converter** | `/tools/developer/color_converter` | Convert between CSS RGB/RGBA, HEX, and HEXA formats with real-time preview swatch | `ColorConverterEngine` |
| 3 | **Data Transfer Time** | `/tools/developer/data_transfer` | Compute download/upload ETA based on file size and connection bandwidth. | `DataTransferEngine` |
| 4 | **Developer Utilities** | `/tools/developer/developer_utilities` | Format JSON, minify strings, URL encode/decode, and Base64 convert. | `DeveloperUtilitiesEngine` |
| 5 | **Number Base Converter** | `/tools/developer/number_base` | Convert values between Binary, Octal, Decimal, Hexadecimal, and arbitrary radix (2-36) | `NumberBaseEngine` |
| 6 | **Unix Timestamp Converter** | `/tools/developer/unix_timestamp` | Convert between Unix epoch integer seconds/milliseconds and human date strings. | `UnixTimestampEngine` |

---

## 10. Universal Unit Conversion Suite

| # | Tool Name | Route | Description | Engine Class |
|:---|:---|:---|:---|:---|
| 1 | **UnitConverter** | `/tools/unit_converter` | Calculation tool for UnitConverter | `UnitConverterEngine` |

---
