import 'dart:math' as math;

class AdvancedMathEngine {
  // --------------------------------------------------------------------------
  // 1. Coordinate Geometry
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateCoordinateGeometry({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final distance = math.sqrt(dx * dx + dy * dy);
    final midX = (x1 + x2) / 2.0;
    final midY = (y1 + y2) / 2.0;
    final midpoint = '(${_formatNum(midX)}, ${_formatNum(midY)})';

    double? slope;
    String lineEq;
    if (dx.abs() < 1e-12) {
      slope = null;
      lineEq = 'x = ${_formatNum(x1)}';
    } else {
      final m = dy / dx;
      slope = m;
      final b = y1 - m * x1;
      final mStr = _formatNum(m);
      final bStr = b >= 0 ? '+ ${_formatNum(b)}' : '- ${_formatNum(b.abs())}';
      lineEq = 'y = $mStr x $bStr';
    }

    return {
      'distance': distance,
      'midpoint': midpoint,
      'slope': slope,
      'lineEquation': lineEq,
      'formula': 'd = √((x₂ - x₁)² + (y₂ - y₁)²) | Midpoint = ((x₁+x₂)/2, (y₁+y₂)/2)',
      'substitution': 'd = √(($x2 - $x1)² + ($y2 - $y1)²) = ${_formatNum(distance)}',
    };
  }

  // --------------------------------------------------------------------------
  // 2. Exponents and Radical Roots
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateExponentAndRoot({
    required double base,
    required double exponent,
    required double rootDegree,
  }) {
    if (rootDegree == 0) {
      throw ArgumentError('Root degree cannot be 0');
    }

    double powerResult;
    if (base < 0 && exponent.truncateToDouble() != exponent) {
      throw ArgumentError('Negative base with fractional exponent results in complex numbers');
    } else {
      powerResult = math.pow(base, exponent).toDouble();
    }

    double rootResult;
    if (base < 0) {
      if (rootDegree.toInt() % 2 != 0) {
        rootResult = -math.pow(-base, 1.0 / rootDegree).toDouble();
      } else {
        throw ArgumentError('Even root of negative number is complex');
      }
    } else {
      rootResult = math.pow(base, 1.0 / rootDegree).toDouble();
    }

    double? squareRoot;
    if (base >= 0) {
      squareRoot = math.sqrt(base);
    }

    return {
      'powerResult': powerResult,
      'rootResult': rootResult,
      'squareRoot': squareRoot,
      'powerSubstitution': '$base^$exponent = ${_formatNum(powerResult)}',
      'rootSubstitution': 'ⁿ√x where n=$rootDegree = ${_formatNum(rootResult)}',
    };
  }

  // --------------------------------------------------------------------------
  // 3. Logarithms
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateLogarithm({
    required double value,
    required double base,
  }) {
    if (value <= 0) {
      throw ArgumentError('Logarithm input value must be strictly positive');
    }
    if (base <= 0 || (base - 1.0).abs() < 1e-12) {
      throw ArgumentError('Logarithm base must be positive and not equal to 1');
    }

    final naturalLog = math.log(value);
    final log10 = naturalLog / math.ln10;
    final result = naturalLog / math.log(base);

    return {
      'result': result,
      'naturalLog': naturalLog,
      'log10': log10,
      'formula': 'log_b(x) = ln(x) / ln(b)',
      'substitution': 'log_${_formatNum(base)}(${_formatNum(value)}) = ln($value) / ln($base) = ${_formatNum(result)}',
    };
  }

  // --------------------------------------------------------------------------
  // 4. Polynomial Evaluation & Derivative
  // --------------------------------------------------------------------------
  static Map<String, dynamic> evaluatePolynomial({
    required List<double> coefficients,
    required double x,
  }) {
    if (coefficients.isEmpty) {
      throw ArgumentError('Coefficients list cannot be empty');
    }

    double value = 0.0;
    double derivative = 0.0;

    for (int i = 0; i < coefficients.length; i++) {
      final c = coefficients[i];
      value += c * math.pow(x, i);
      if (i > 0) {
        derivative += i * c * math.pow(x, i - 1);
      }
    }

    final polyTerms = <String>[];
    for (int i = coefficients.length - 1; i >= 0; i--) {
      final c = coefficients[i];
      if (c == 0 && coefficients.length > 1) continue;
      if (i == 0) {
        polyTerms.add(_formatNum(c));
      } else if (i == 1) {
        polyTerms.add('${_formatNum(c)}x');
      } else {
        polyTerms.add('${_formatNum(c)}x^$i');
      }
    }

    final polyStr = polyTerms.isEmpty ? '0' : polyTerms.join(' + ');

    return {
      'value': value,
      'derivativeAtX': derivative,
      'formula': 'P(x) = $polyStr',
      'substitution': 'P($x) = ${_formatNum(value)} | P\'($x) = ${_formatNum(derivative)}',
    };
  }

  // --------------------------------------------------------------------------
  // 5. Complex Numbers
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateComplex({
    required double r1,
    required double i1,
    required double r2,
    required double i2,
    required String op, // '+', '-', '*', '/'
  }) {
    double resR;
    double resI;

    switch (op) {
      case '+':
        resR = r1 + r2;
        resI = i1 + i2;
        break;
      case '-':
        resR = r1 - r2;
        resI = i1 - i2;
        break;
      case '*':
        resR = r1 * r2 - i1 * i2;
        resI = r1 * i2 + i1 * r2;
        break;
      case '/':
        final denom = r2 * r2 + i2 * i2;
        if (denom == 0) throw ArgumentError('Division by zero in complex numbers');
        resR = (r1 * r2 + i1 * i2) / denom;
        resI = (i1 * r2 - r1 * i2) / denom;
        break;
      default:
        throw ArgumentError('Unknown complex operator: $op');
    }

    final mag = math.sqrt(resR * resR + resI * resI);
    final arg = math.atan2(resI, resR);

    final sign = resI >= 0 ? '+' : '-';
    final formatted = '${_formatNum(resR)} $sign ${_formatNum(resI.abs())}i';

    return {
      'real': resR,
      'imaginary': resI,
      'formatted': formatted,
      'magnitude': mag,
      'argument': arg,
      'argumentDegrees': arg * 180.0 / math.pi,
    };
  }

  // --------------------------------------------------------------------------
  // 6. Factorial & Gamma Function
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateFactorialGamma(double n) {
    if (n < 0 && n.truncateToDouble() == n) {
      throw ArgumentError('Gamma function is undefined at non-positive integers');
    }

    double val;
    if (n.truncateToDouble() == n && n >= 0 && n <= 170) {
      double f = 1.0;
      for (int i = 2; i <= n.toInt(); i++) {
        f *= i;
      }
      val = f;
    } else {
      // Lanczos approximation for Gamma(n+1)
      val = _lanczosGamma(n + 1.0);
    }

    return {
      'input': n,
      'factorial': val,
      'gamma': _lanczosGamma(n),
    };
  }

  static double _lanczosGamma(double z) {
    if (z < 0.5) {
      return math.pi / (math.sin(math.pi * z) * _lanczosGamma(1.0 - z));
    }
    z -= 1.0;
    const g = 7;
    const p = [
      0.99999999999980993,
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7,
    ];

    double x = p[0];
    for (int i = 1; i < p.length; i++) {
      x += p[i] / (z + i);
    }
    final t = z + g + 0.5;
    return math.sqrt(2.0 * math.pi) * math.pow(t, z + 0.5) * math.exp(-t) * x;
  }

  // --------------------------------------------------------------------------
  // 7. Matrix Operations (2x2 and 3x3)
  // --------------------------------------------------------------------------
  static double determinant2x2(double a, double b, double c, double d) {
    return a * d - b * c;
  }

  static double determinant3x3(List<List<double>> m) {
    return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
        m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
        m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
  }

  // --------------------------------------------------------------------------
  // 8. Vectors (3D)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateVectors3D({
    required List<double> v1,
    required List<double> v2,
  }) {
    final dot = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
    final cross = [
      v1[1] * v2[2] - v1[2] * v2[1],
      v1[2] * v2[0] - v1[0] * v2[2],
      v1[0] * v2[1] - v1[1] * v2[0],
    ];
    final mag1 = math.sqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]);
    final mag2 = math.sqrt(v2[0] * v2[0] + v2[1] * v2[1] + v2[2] * v2[2]);
    final cosTheta = (mag1 > 0 && mag2 > 0) ? (dot / (mag1 * mag2)).clamp(-1.0, 1.0) : 1.0;
    final angleRad = math.acos(cosTheta);
    final angleDeg = angleRad * 180.0 / math.pi;

    return {
      'dotProduct': dot,
      'crossProduct': cross,
      'mag1': mag1,
      'mag2': mag2,
      'angleDegrees': angleDeg,
    };
  }

  // --------------------------------------------------------------------------
  // 9. Sequences (Arithmetic & Geometric)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> calculateSequence({
    required double a1,
    required double diffOrRatio,
    required int n,
    required bool isGeometric,
  }) {
    if (n <= 0) throw ArgumentError('Term index n must be positive');

    double nthTerm;
    double sum;

    if (!isGeometric) {
      // Arithmetic: an = a1 + (n - 1)d
      nthTerm = a1 + (n - 1) * diffOrRatio;
      sum = (n / 2.0) * (a1 + nthTerm);
    } else {
      // Geometric: an = a1 * r^(n-1)
      nthTerm = a1 * math.pow(diffOrRatio, n - 1);
      if ((diffOrRatio - 1.0).abs() < 1e-12) {
        sum = a1 * n;
      } else {
        sum = a1 * (1.0 - math.pow(diffOrRatio, n)) / (1.0 - diffOrRatio);
      }
    }

    return {
      'nthTerm': nthTerm,
      'sum': sum,
    };
  }

  // --------------------------------------------------------------------------
  // Helper
  // --------------------------------------------------------------------------
  static String _formatNum(double num) {
    if (num.isNaN) return 'NaN';
    if (num.isInfinite) return num.isNegative ? '-Infinity' : 'Infinity';
    if (num.truncateToDouble() == num) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
