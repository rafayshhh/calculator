import 'dart:math' as math;

/// Pure-Dart numerical and symbolic calculus engine for single-variable functions,
/// polynomial analysis, numerical integration, derivatives, and root finding.
class CalculusEngine {
  CalculusEngine._();

  /// Computes the first and second numerical derivatives at [x] using central finite differences.
  static Map<String, dynamic> numericalDerivative(
    double Function(double) f,
    double x, {
    double h = 1e-5,
  }) {
    final fxPlus = f(x + h);
    final fxMinus = f(x - h);
    final fx = f(x);

    // Central difference formula: f'(x) ≈ (f(x+h) - f(x-h)) / (2h)
    final firstDerivative = (fxPlus - fxMinus) / (2 * h);

    // Second derivative formula: f''(x) ≈ (f(x+h) - 2f(x) + f(x-h)) / (h^2)
    final secondDerivative = (fxPlus - 2 * fx + fxMinus) / (h * h);

    return {
      'x': x,
      'fx': fx,
      'firstDerivative': firstDerivative,
      'secondDerivative': secondDerivative,
      'concavity': secondDerivative > 0 ? 'Concave Up' : (secondDerivative < 0 ? 'Concave Down' : 'Inflection Point'),
    };
  }

  /// Evaluates exact analytical derivative for a polynomial: P(x) = c0 + c1*x + c2*x^2 + ... + cn*x^n
  /// [coefficients] ordered from degree 0 to degree n.
  static Map<String, dynamic> polynomialDerivative(
    List<double> coefficients,
    double x,
  ) {
    if (coefficients.isEmpty) {
      return {'fx': 0.0, 'firstDerivative': 0.0, 'secondDerivative': 0.0, 'polyString': '0', 'derivativeString': '0'};
    }

    double fx = 0;
    double dfx = 0;
    double d2fx = 0;
    final List<String> polyTerms = [];
    final List<String> derivTerms = [];

    for (int i = 0; i < coefficients.length; i++) {
      final c = coefficients[i];
      if (c.abs() > 1e-12) {
        fx += c * math.pow(x, i);
        final term = i == 0 ? c.toStringAsFixed(2) : (i == 1 ? '${c.toStringAsFixed(2)}x' : '${c.toStringAsFixed(2)}x^$i');
        polyTerms.add(term);

        if (i >= 1) {
          final dc = c * i;
          dfx += dc * math.pow(x, i - 1);
          final dTerm = (i - 1 == 0) ? dc.toStringAsFixed(2) : (i - 1 == 1 ? '${dc.toStringAsFixed(2)}x' : '${dc.toStringAsFixed(2)}x^${i - 1}');
          derivTerms.add(dTerm);
        }

        if (i >= 2) {
          final d2c = c * i * (i - 1);
          d2fx += d2c * math.pow(x, i - 2);
        }
      }
    }

    return {
      'x': x,
      'fx': fx,
      'firstDerivative': dfx,
      'secondDerivative': d2fx,
      'polyString': polyTerms.isEmpty ? '0' : polyTerms.join(' + '),
      'derivativeString': derivTerms.isEmpty ? '0' : derivTerms.join(' + '),
    };
  }

  /// Composite Simpson's 1/3 rule for definite numerical integration: ∫_a^b f(x) dx
  static Map<String, dynamic> numericalIntegration(
    double Function(double) f,
    double a,
    double b, {
    int intervals = 1000,
  }) {
    if (intervals % 2 != 0) intervals += 1;
    final h = (b - a) / intervals;

    double sum = f(a) + f(b);
    for (int i = 1; i < intervals; i++) {
      final x = a + i * h;
      if (i % 2 == 1) {
        sum += 4 * f(x);
      } else {
        sum += 2 * f(x);
      }
    }

    final result = (h / 3) * sum;
    return {
      'integral': result,
      'lowerBound': a,
      'upperBound': b,
      'intervals': intervals,
      'stepSize': h,
    };
  }

  /// Exact analytical definite integral of polynomial: P(x) = c0 + c1*x + ... + cn*x^n
  static Map<String, dynamic> polynomialDefiniteIntegral(
    List<double> coefficients,
    double a,
    double b,
  ) {
    double evalAntiderivative(double t) {
      double sum = 0;
      for (int i = 0; i < coefficients.length; i++) {
        sum += (coefficients[i] / (i + 1)) * math.pow(t, i + 1);
      }
      return sum;
    }

    final fb = evalAntiderivative(b);
    final fa = evalAntiderivative(a);
    final result = fb - fa;

    return {
      'integral': result,
      'lowerBound': a,
      'upperBound': b,
      'antiderivativeAtB': fb,
      'antiderivativeAtA': fa,
    };
  }

  /// Approximates left-sided, right-sided, and two-sided limits as x -> c
  static Map<String, dynamic> limitApproximation(
    double Function(double) f,
    double c, {
    double epsilon = 1e-6,
  }) {
    final leftVal = f(c - epsilon);
    final rightVal = f(c + epsilon);
    final diff = (leftVal - rightVal).abs();
    final exists = diff < 1e-4;

    return {
      'target': c,
      'leftLimit': leftVal,
      'rightLimit': rightVal,
      'limit': exists ? (leftVal + rightVal) / 2 : double.nan,
      'exists': exists,
    };
  }

  /// Computes tangent and normal lines at (x0, f(x0))
  static Map<String, dynamic> tangentAndNormalLine(
    double Function(double) f,
    double x0,
  ) {
    final y0 = f(x0);
    final m = numericalDerivative(f, x0)['firstDerivative'] as double;

    // Tangent: y - y0 = m*(x - x0) => y = m*x + (y0 - m*x0)
    final cTangent = y0 - m * x0;

    // Normal: slope = -1/m (if m != 0)
    final double? mNormal = m.abs() > 1e-9 ? -1.0 / m : null;
    final double? cNormal = mNormal != null ? (y0 - mNormal * x0) : null;

    return {
      'x0': x0,
      'y0': y0,
      'tangentSlope': m,
      'tangentIntercept': cTangent,
      'tangentEquation': 'y = ${m.toStringAsFixed(4)}x + ${cTangent.toStringAsFixed(4)}',
      'normalSlope': mNormal,
      'normalIntercept': cNormal,
      'normalEquation': mNormal != null
          ? 'y = ${mNormal.toStringAsFixed(4)}x + ${cNormal!.toStringAsFixed(4)}'
          : 'x = ${x0.toStringAsFixed(4)} (Vertical)',
    };
  }

  /// Root finding using Bisection Method on interval [a, b]
  static Map<String, dynamic> bisectionRoot(
    double Function(double) f,
    double a,
    double b, {
    int maxIterations = 100,
    double tol = 1e-7,
  }) {
    double fa = f(a);
    double fb = f(b);

    if (fa * fb > 0) {
      return {
        'converged': false,
        'error': 'f(a) and f(b) must have opposite signs (f(a)*f(b) <= 0)',
        'root': double.nan,
        'iterations': 0,
      };
    }

    double c = a;
    int iter = 0;
    for (iter = 0; iter < maxIterations; iter++) {
      c = (a + b) / 2;
      final fc = f(c);

      if (fc.abs() < tol || ((b - a) / 2).abs() < tol) {
        return {
          'converged': true,
          'root': c,
          'fc': fc,
          'iterations': iter + 1,
        };
      }

      if (fa * fc < 0) {
        b = c;
        fb = fc;
      } else {
        a = c;
        fa = fc;
      }
    }

    return {
      'converged': true,
      'root': c,
      'fc': f(c),
      'iterations': iter,
    };
  }
}
