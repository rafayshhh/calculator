# Calculator

An offline-first mathematical calculation engine and multi-discipline utility suite built with Flutter and Dart by **Muhammad Abdul Rafay ([@rafayshhh](https://github.com/rafayshhh))**. Designed for researchers, engineers, students, and developers seeking precision, speed, and privacy.

---

## 🌟 Key Features

* **Advanced Mathematical Parser**: Custom pure-Dart lexer, recursive descent parser, and AST evaluator supporting implicit multiplication, trigonometric modes (DEG, RAD, GRAD), logarithms, powers, and percentages.
* **4 Core Calculation Workspaces**:
  * **Arithmetic Calculator**: Fast expressions evaluation with a morphing keypad.
  * **Equation Solver**: Linear, quadratic, and numerical root finding.
  * **Function Grapher**: Interactive $y = f(x)$ function plotting with pan and zoom.
  * **Function Table Generator**: Discrete interval step-evaluation.
* **150 Specialized Mathematical & Scientific Tools**:
  * **Calculus & Analysis**: Derivatives, Definite Simpson Integration, Limits, Taylor Series, Root Bisection, Tangent & Normal Equations.
  * **Linear Algebra**: Eigenvalues & Trace, Matrix Inverse ($A^{-1}$), Gaussian Elimination Linear Systems, Vector Projection, 3D Cross/Dot Products.
  * **Geometry 2D & 3D**: SSS Triangle Solver, Circle/Sector, Regular Polygons, Spheres, Cylinders, Cones, Pyramids, Prisms, Tori, Conic Sections.
  * **Discrete Math & Number Theory**: Prime Factorization, Modular Inverses, Collatz $3n+1$, Fibonacci & $\phi$, Diophantine Equations, Euler's Totient, CRT, Boolean Gates.
  * **Mathematics & Statistics**: Matrices ($4\times4$), 2D/3D Vectors, Complex Numbers, Polynomials, Mean/Median/Mode, Variance, IQR, Z-Score CDF, Regression, Chi-Square.
  * **Finance**: Compound Interest, Amortized Mortgage, Loans & EMI, Savings Goals, ROI, CAGR, Margin & Markup, Break-Even, Sales Tax & VAT.
  * **Science & Chemistry**: Molar Mass, Stoichiometry, Molarity, Solution Dilution, Ideal Gas Law, Combined Gas Laws, Concentration, pH / pOH equilibrium.
  * **Physics & Mechanics**: Newton's Laws ($F=ma$), Kinematics, Momentum, Work & Energy, Density, Hydrostatic Pressure, Wave Speed, Projectile Motion, Gravitational Orbits.
  * **Electrical & Electronics**: Ohm's Law, Circuit Power, Series/Parallel Resistors, Voltage Dividers, LED Resistors, RC Time Constant, Inductors, Capacitors.
  * **Mechanical Engineering**: Torque, Gear Ratios, Mechanical Advantage, Hooke's Law, Stress & Strain, Young's Modulus, Efficiency, RPM.
  * **Everyday Calculators**: Discounts, Fuel Trip Costs, Unit Price Comparison, Percentage Variations.
  * **Date & Time**: Date Difference, Interval Addition, Age Breakdown, Business Days, Unix Timestamps, Duration Math.
  * **Developer**: Number Base Conversion (BIN/OCT/DEC/HEX), Bitwise Logic, Data Transfer Rates, Color Format Translation.
* **15-Category Unit Converter**: High-precision reciprocal unit conversions across Length, Mass, Temperature, Area, Volume, Speed, Time, Digital Storage, Energy, Pressure, Power, Fuel Economy, Angle, Frequency, and Data Rates.
* **12-Theme Design System**: 6 custom palettes (Kreate Blue, Midnight Violet, Cyan Glow, Emerald Green, Solar Yellow, Sunset Crimson) in Light & Dark modes.
* **Privacy-First & Offline-First**: 0 trackers, 0 network telemetry, 0 cloud dependencies. Persisted locally via Hive binary storage.
* **Responsive Multi-Platform**: Adaptive layout engine optimized for Mobile (<600dp), Tablet (600–899dp), and Desktop/Web (≥900dp).

---

## 🚀 Quick Start

### Prerequisites
* Flutter SDK `3.13.0` or higher
* Dart SDK `3.13.0` or higher

### Installation & Run
```bash
# Clone the repository
git clone https://github.com/rafayshhh/calculator.git
cd calculator/"Calculator With Math Tools"

# Fetch dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on Desktop (Windows / macOS / Linux)
flutter run -d windows

# Run on Android
flutter run -d android
```

### Running Tests
```bash
flutter test
```

---

## 🏗️ Architecture & Tech Stack

* **UI Framework**: Flutter (Material 3 with custom semantic tokens)
* **Language**: Dart (strict null-safety)
* **State Management**: Flutter Riverpod (`flutter_riverpod`)
* **Routing**: GoRouter (`go_router`) with state serialization
* **Local Storage**: Hive (`hive_flutter`)
* **Mathematical Engine**: Custom Pure-Dart AST (zero external calculation dependencies)

---

## 📖 Detailed Documentation

Comprehensive architectural blueprints and developer references are maintained in the `Documentation/` directory:

* [System Architecture](../Documentation/ARCHITECTURE.md)
* [Tools & Formulas Reference](../Documentation/TOOLS_REFERENCE.md)
* [Development & Contributor Guide](../Documentation/DEVELOPMENT_GUIDE.md)
* [Testing Guide](../Documentation/TESTING_GUIDE.md)
* [Open Source Roadmap](../Documentation/OPEN_SOURCE_ROADMAP.md)
* [Security Policy](../Documentation/SECURITY.md)
* [Project Status & Verification](../Documentation/PROJECT_STATUS.md)

---

## 👤 Creator & Maintainer

**Muhammad Abdul Rafay** ([@rafayshhh](https://github.com/rafayshhh))

- **GitHub Profile**: [github.com/rafayshhh](https://github.com/rafayshhh)
- **Repository**: [github.com/rafayshhh/calculator](https://github.com/rafayshhh/calculator)
- **Instagram**: [@kreatekode](https://www.instagram.com/kreatekode/)
- **Website**: [kreatekode.website](https://kreatekode.website)
- **Google Play Store**: [KreateKode Apps](https://play.google.com/store/apps/developer?id=KreateKode)
