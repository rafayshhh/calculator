import 'dart:math' as math;

class MathAdvancedEngine {
  MathAdvancedEngine._();

  /// Solves quadratic equation ax^2 + bx + c = 0
  /// Returns map with roots, discriminant, and formatted strings
  static Map<String, dynamic> solveQuadratic(double a, double b, double c) {
    if (a == 0) {
      if (b == 0) {
        throw ArgumentError(
          'Invalid quadratic equation: a and b cannot both be 0',
        );
      }
      final root = -c / b;
      return {
        'discriminant': 0.0,
        'rootType': 'Linear Equation',
        'roots': [root],
        'displayText': 'x = ${_formatNumber(root)}',
        'x1': _formatNumber(root),
        'x2': null,
      };
    }

    final discriminant = (b * b) - (4 * a * c);

    if (discriminant > 0) {
      final root1 = (-b + math.sqrt(discriminant)) / (2 * a);
      final root2 = (-b - math.sqrt(discriminant)) / (2 * a);
      return {
        'discriminant': discriminant,
        'rootType': 'Two Real Roots',
        'roots': [root1, root2],
        'displayText':
            'x₁ = ${_formatNumber(root1)}, x₂ = ${_formatNumber(root2)}',
        'x1': _formatNumber(root1),
        'x2': _formatNumber(root2),
      };
    } else if (discriminant == 0) {
      final root = -b / (2 * a);
      return {
        'discriminant': 0.0,
        'rootType': 'One Repeated Real Root',
        'roots': [root],
        'displayText': 'x = ${_formatNumber(root)}',
        'x1': _formatNumber(root),
        'x2': _formatNumber(root),
      };
    } else {
      final realPart = -b / (2 * a);
      final imagPart = math.sqrt(-discriminant) / (2 * a).abs();
      final complexStr =
          '${_formatNumber(realPart)} ± ${_formatNumber(imagPart)}i';
      return {
        'discriminant': discriminant,
        'rootType': 'Complex Roots',
        'roots': <double>[],
        'displayText': complexStr,
        'x1': '${_formatNumber(realPart)} + ${_formatNumber(imagPart)}i',
        'x2': '${_formatNumber(realPart)} - ${_formatNumber(imagPart)}i',
      };
    }
  }

  /// Greatest Common Divisor (GCD / HCF)
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  /// Least Common Multiple (LCM)
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() * b.abs()) ~/ gcd(a, b);
  }

  /// Checks if an integer is prime
  static bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  /// Prime factorization of integer
  static List<int> primeFactors(int n) {
    n = n.abs();
    final factors = <int>[];
    if (n <= 1) return factors;

    while (n % 2 == 0) {
      factors.add(2);
      n ~/= 2;
    }

    for (int d = 3; d * d <= n; d += 2) {
      while (n % d == 0) {
        factors.add(d);
        n ~/= d;
      }
    }

    if (n > 2) {
      factors.add(n);
    }

    return factors;
  }

  /// Formatted exponential prime factorization, e.g., 60 -> 2² × 3 × 5
  static String formatExponentialFactorization(List<int> factors) {
    if (factors.isEmpty) return 'None';
    final map = <int, int>{};
    for (var f in factors) {
      map[f] = (map[f] ?? 0) + 1;
    }

    const superscripts = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };

    String toSuperscript(int num) {
      return num.toString().split('').map((c) => superscripts[c] ?? c).join();
    }

    final parts = <String>[];
    for (var entry in map.entries) {
      if (entry.value > 1) {
        parts.add('${entry.key}${toSuperscript(entry.value)}');
      } else {
        parts.add('${entry.key}');
      }
    }
    return parts.join(' × ');
  }

  /// Pythagorean Theorem: calculate missing side
  /// If finding hypotenuse, c is null. If finding leg, either a or b is null.
  static double pythagorean({double? a, double? b, double? c}) {
    if (c == null && a != null && b != null) {
      if (a <= 0 || b <= 0) throw ArgumentError('Legs must be positive');
      return math.sqrt((a * a) + (b * b));
    } else if (a == null && b != null && c != null) {
      if (c <= b || b <= 0) {
        throw ArgumentError('Hypotenuse must be greater than leg');
      }
      return math.sqrt((c * c) - (b * b));
    } else if (b == null && a != null && c != null) {
      if (c <= a || a <= 0) {
        throw ArgumentError('Hypotenuse must be greater than leg');
      }
      return math.sqrt((c * c) - (a * a));
    }
    throw ArgumentError('Provide exactly two sides');
  }

  /// Permutations nPr = n! / (n - r)!
  static int permutations(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw ArgumentError('Invalid n or r for permutations');
    }
    int result = 1;
    for (int i = 0; i < r; i++) {
      result *= (n - i);
    }
    return result;
  }

  /// Combinations nCr = n! / (r! * (n - r)!)
  static int combinations(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw ArgumentError('Invalid n or r for combinations');
    }
    if (r == 0 || r == n) return 1;
    if (r > n / 2) r = n - r;

    int result = 1;
    for (int i = 1; i <= r; i++) {
      result = (result * (n - i + 1)) ~/ i;
    }
    return result;
  }

  /// Proportion solver: a/b = c/d
  /// Solves for missing variable among a, b, c, d
  static double solveProportion({double? a, double? b, double? c, double? d}) {
    if (a == null && b != null && c != null && d != null) {
      if (d == 0) throw ArgumentError('Cannot divide by zero');
      return (b * c) / d;
    } else if (b == null && a != null && c != null && d != null) {
      if (c == 0) throw ArgumentError('Cannot divide by zero');
      return (a * d) / c;
    } else if (c == null && a != null && b != null && d != null) {
      if (b == 0) throw ArgumentError('Cannot divide by zero');
      return (a * d) / b;
    } else if (d == null && a != null && b != null && c != null) {
      if (a == 0) throw ArgumentError('Cannot divide by zero');
      return (b * c) / a;
    }
    throw ArgumentError('Specify exactly 3 values to solve for the fourth');
  }

  /// 2D Geometry calculations
  static Map<String, double> calculateRectangle(double length, double width) {
    if (length <= 0 || width <= 0) {
      throw ArgumentError('Dimensions must be positive');
    }
    final area = length * width;
    final perimeter = 2 * (length + width);
    final diagonal = math.sqrt((length * length) + (width * width));
    return {'area': area, 'perimeter': perimeter, 'diagonal': diagonal};
  }

  static Map<String, double> calculateSquare(double side) {
    if (side <= 0) throw ArgumentError('Side must be positive');
    final area = side * side;
    final perimeter = 4 * side;
    final diagonal = side * math.sqrt(2);
    return {'area': area, 'perimeter': perimeter, 'diagonal': diagonal};
  }

  static Map<String, double> calculateCircle(double radius) {
    if (radius <= 0) throw ArgumentError('Radius must be positive');
    final area = math.pi * radius * radius;
    final circumference = 2 * math.pi * radius;
    final diameter = 2 * radius;
    return {'area': area, 'circumference': circumference, 'diameter': diameter};
  }

  static Map<String, double> calculateTriangle(
    double base,
    double height, {
    double? sideA,
    double? sideC,
  }) {
    if (base <= 0 || height <= 0) {
      throw ArgumentError('Base and height must be positive');
    }
    final area = 0.5 * base * height;
    double perimeter = 0.0;
    if (sideA != null && sideC != null && sideA > 0 && sideC > 0) {
      perimeter = sideA + base + sideC;
    }
    return {'area': area, 'perimeter': perimeter};
  }

  static String _formatNumber(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
