import 'dart:math' as math;

import 'math_engine.dart';

class EquationSolution {
  final String equation;
  final String type; // 'linear', 'quadratic', 'numerical'
  final List<String> solutions;
  final List<String> steps;
  final String? verification;

  const EquationSolution({
    required this.equation,
    required this.type,
    required this.solutions,
    required this.steps,
    this.verification,
  });
}

class EquationSolverEngine {
  static EquationSolution solve(String rawEquation) {
    String eq = rawEquation.trim();
    if (!eq.contains('=')) {
      eq = '$eq = 0';
    }

    final parts = eq.split('=');
    if (parts.length != 2) {
      throw ArgumentError('Equation must contain exactly one "=" sign');
    }

    final lhsStr = parts[0].trim();
    final rhsStr = parts[1].trim();

    final steps = <String>[];
    steps.add('Original Equation: $lhsStr = $rhsStr');

    // 1. Check for Quadratic standard form ax^2 + bx + c = 0 or similar
    final quadraticMatch = _tryParseQuadratic(lhsStr, rhsStr);
    if (quadraticMatch != null) {
      final a = quadraticMatch['a']!;
      final b = quadraticMatch['b']!;
      final c = quadraticMatch['c']!;

      steps.add(
        'Rearranged to standard polynomial form: ${a}x^2 + ($b)x + ($c) = 0',
      );
      final disc = b * b - 4 * a * c;
      steps.add('Discriminant Δ = b² - 4ac = ($b)² - 4($a)($c) = $disc');

      if (disc > 0) {
        final x1 = (-b + math.sqrt(disc)) / (2 * a);
        final x2 = (-b - math.sqrt(disc)) / (2 * a);
        steps.add('Two distinct real solutions:');
        steps.add('x₁ = (-($b) + √$disc) / (2 × $a) = ${_clean(x1)}');
        steps.add('x₂ = (-($b) - √$disc) / (2 × $a) = ${_clean(x2)}');
        return EquationSolution(
          equation: eq,
          type: 'Quadratic Equation',
          solutions: ['x₁ = ${_clean(x1)}', 'x₂ = ${_clean(x2)}'],
          steps: steps,
          verification:
              'Verified: $a(${_clean(x1)})² + $b(${_clean(x1)}) + $c = 0',
        );
      } else if (disc == 0) {
        final x = -b / (2 * a);
        steps.add('One repeated real solution:');
        steps.add('x = -($b) / (2 × $a) = ${_clean(x)}');
        return EquationSolution(
          equation: eq,
          type: 'Quadratic Equation',
          solutions: ['x = ${_clean(x)}'],
          steps: steps,
          verification:
              'Verified: $a(${_clean(x)})² + $b(${_clean(x)}) + $c = 0',
        );
      } else {
        final realPart = -b / (2 * a);
        final imagPart = math.sqrt(-disc) / (2 * a);
        steps.add('Complex conjugate roots:');
        final sol1 = '${_clean(realPart)} + ${_clean(imagPart)}i';
        final sol2 = '${_clean(realPart)} - ${_clean(imagPart)}i';
        steps.add('x₁ = $sol1');
        steps.add('x₂ = $sol2');
        return EquationSolution(
          equation: eq,
          type: 'Quadratic Equation (Complex Roots)',
          solutions: ['x₁ = $sol1', 'x₂ = $sol2'],
          steps: steps,
        );
      }
    }

    // 2. Linear Equation Solver or Bisection Numerical Solver
    // f(x) = LHS - RHS = 0
    // Pre-parse ASTs once for efficient repeated evaluation
    final Expr lhsAst;
    final Expr rhsAst;
    try {
      lhsAst = Parser(Tokenizer(lhsStr).tokenize()).parse();
      rhsAst = Parser(Tokenizer(rhsStr).tokenize()).parse();
    } catch (e) {
      throw ArgumentError('Could not parse equation variables: $e');
    }

    // Check if linear by sampling f(0), f(1), f(2)
    double f0, f1, f2;
    try {
      f0 = _evalDiffAst(lhsAst, rhsAst, 0.0);
      f1 = _evalDiffAst(lhsAst, rhsAst, 1.0);
      f2 = _evalDiffAst(lhsAst, rhsAst, 2.0);
    } catch (e) {
      throw ArgumentError('Could not parse equation variables: $e');
    }

    final d1 = f1 - f0; // slope between 0 and 1
    final d2 = f2 - f1; // slope between 1 and 2

    if ((d1 - d2).abs() < 1e-9 && d1.abs() > 1e-12) {
      // It is Linear! f(x) = m*x + f(0) = 0 => x = -f(0)/m
      final slope = d1;
      final intercept = f0;
      final sol = -intercept / slope;

      steps.add(
        'Simplified to linear form: ${_clean(slope)}x + ${_clean(intercept)} = 0',
      );
      steps.add(
        'Subtract intercept: ${_clean(slope)}x = ${_clean(-intercept)}',
      );
      steps.add(
        'Divide by coefficient: x = ${_clean(-intercept)} / ${_clean(slope)} = ${_clean(sol)}',
      );

      return EquationSolution(
        equation: eq,
        type: 'Linear Equation',
        solutions: ['x = ${_clean(sol)}'],
        steps: steps,
        verification: 'Verified: $lhsStr when x=${_clean(sol)} equals $rhsStr',
      );
    }

    // 3. Numerical Root Finding (Bisection / Secant)
    steps.add('General non-linear equation f(x) = ($lhsStr) - ($rhsStr) = 0');
    final root = _findRootNumerically(lhsAst, rhsAst);
    if (root != null) {
      steps.add('Numerical convergence achieved at x ≈ ${_clean(root)}');
      return EquationSolution(
        equation: eq,
        type: 'Non-Linear / Transcendental Equation',
        solutions: ['x ≈ ${_clean(root)}'],
        steps: steps,
        verification:
            'f(${_clean(root)}) ≈ ${_evalDiffAst(lhsAst, rhsAst, root).toStringAsExponential(2)}',
      );
    }

    throw ArgumentError(
      'No real roots found within standard search domain [-100, 100]',
    );
  }

  static double _evalDiff(String lhs, String rhs, double x) {
    final leftVal = CalculatorEngine.evaluateNumeric(lhs, variables: {'x': x});
    final rightVal = CalculatorEngine.evaluateNumeric(rhs, variables: {'x': x});
    return leftVal - rightVal;
  }

  /// Evaluate f(x) = LHS - RHS using pre-parsed ASTs for efficiency.
  static double _evalDiffAst(Expr lhsAst, Expr rhsAst, double x) {
    final evaluator = Evaluator(variables: {'x': x});
    return evaluator.evaluate(lhsAst) - evaluator.evaluate(rhsAst);
  }

  static Map<String, double>? _tryParseQuadratic(String lhs, String rhs) {
    // If equation has x^2 or x²
    if (!lhs.contains('x^2') &&
        !lhs.contains('x²') &&
        !rhs.contains('x^2') &&
        !rhs.contains('x²')) {
      return null;
    }

    try {
      final f0 = _evalDiff(lhs, rhs, 0.0);
      final f1 = _evalDiff(lhs, rhs, 1.0);
      final fm1 = _evalDiff(lhs, rhs, -1.0);

      // For a*x^2 + b*x + c:
      // f(0) = c
      // f(1) = a + b + c
      // f(-1) = a - b + c
      // => a = (f(1) + f(-1) - 2*f(0)) / 2
      // => b = (f(1) - f(-1)) / 2
      final c = f0;
      final a = (f1 + fm1 - 2 * f0) / 2.0;
      final b = (f1 - fm1) / 2.0;

      // Verify at x=2
      final f2 = _evalDiff(lhs, rhs, 2.0);
      final predictedF2 = a * 4 + b * 2 + c;
      if ((f2 - predictedF2).abs() < 1e-7 && a.abs() > 1e-12) {
        return {'a': a, 'b': b, 'c': c};
      }
    } catch (_) {}

    return null;
  }

  static double? _findRootNumerically(Expr lhsAst, Expr rhsAst) {
    double? prevF;

    for (double x = -100.0; x <= 100.0; x += 0.5) {
      try {
        final f = _evalDiffAst(lhsAst, rhsAst, x);
        if (f.abs() < 1e-9) return x;
        if (prevF != null && (prevF * f) < 0) {
          // Bracket found between (x - 0.5) and x
          return _bisect(lhsAst, rhsAst, x - 0.5, x);
        }
        prevF = f;
      } catch (_) {}
    }
    return null;
  }

  static double _bisect(Expr lhsAst, Expr rhsAst, double low, double high) {
    double l = low;
    double r = high;
    for (int i = 0; i < 100; i++) {
      final mid = (l + r) / 2.0;
      final fMid = _evalDiffAst(lhsAst, rhsAst, mid);
      if (fMid.abs() < 1e-10 || (r - l).abs() < 1e-10) {
        return mid;
      }
      final fLow = _evalDiffAst(lhsAst, rhsAst, l);
      if (fLow * fMid < 0) {
        r = mid;
      } else {
        l = mid;
      }
    }
    return (l + r) / 2.0;
  }

  static String _clean(double val) {
    final rounded = double.parse(val.toStringAsFixed(6));
    if ((rounded - val).abs() < 1e-6) {
      val = rounded;
    }
    if (val == val.toInt().toDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }
}

