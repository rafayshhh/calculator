import 'dart:math' as math;

class AverageResult {
  final double sum;
  final double mean;
  final double median;
  final double min;
  final double max;
  final int count;

  const AverageResult({
    required this.sum,
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    required this.count,
  });
}

class FractionResult {
  final int numerator;
  final int denominator;
  final int wholeNumber;
  final String mixedFraction;
  final double decimal;

  const FractionResult({
    required this.numerator,
    required this.denominator,
    required this.wholeNumber,
    required this.mixedFraction,
    required this.decimal,
  });
}

class MathUtilitiesEngine {
  MathUtilitiesEngine._();

  /// Calculate summary statistics and averages
  static AverageResult calculateAverage(List<double> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('List of numbers cannot be empty');
    }

    double sum = 0.0;
    double min = numbers.first;
    double max = numbers.first;

    for (final n in numbers) {
      sum += n;
      if (n < min) min = n;
      if (n > max) max = n;
    }

    final mean = sum / numbers.length;

    final sorted = List<double>.from(numbers)..sort();
    double median;
    final len = sorted.length;
    if (len % 2 == 1) {
      median = sorted[len ~/ 2];
    } else {
      median = (sorted[(len ~/ 2) - 1] + sorted[len ~/ 2]) / 2.0;
    }

    return AverageResult(
      sum: sum,
      mean: mean,
      median: median,
      min: min,
      max: max,
      count: numbers.length,
    );
  }

  /// Simplifies fraction and computes mixed fraction representation
  static FractionResult simplifyFraction(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError('Denominator cannot be zero');
    }

    final double decimal = numerator / denominator;
    final whole = numerator ~/ denominator;
    final rem = (numerator % denominator).abs();

    if (rem == 0) {
      return FractionResult(
        numerator: 0,
        denominator: 1,
        wholeNumber: whole,
        mixedFraction: '$whole',
        decimal: decimal,
      );
    }

    final divisor = gcd(rem, denominator.abs());
    final simpNum = rem ~/ divisor;
    final simpDen = denominator.abs() ~/ divisor;

    final mixed = whole != 0 ? '$whole $simpNum/$simpDen' : '$simpNum/$simpDen';

    return FractionResult(
      numerator: simpNum,
      denominator: simpDen,
      wholeNumber: whole,
      mixedFraction: mixed,
      decimal: decimal,
    );
  }

  /// Greatest Common Divisor
  static int gcd(int a, int b) {
    int x = a.abs();
    int y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x;
  }

  /// Least Common Multiple
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() ~/ gcd(a, b)) * b.abs();
  }

  /// Prime check
  static bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  /// Pythagorean Theorem: a² + b² = c²
  static double solvePythagorean({double? a, double? b, double? c}) {
    if (a != null && b != null) {
      return math.sqrt(a * a + b * b);
    } else if (c != null && a != null) {
      if (c <= a) throw ArgumentError('Hypotenuse c must be greater than leg a');
      return math.sqrt(c * c - a * a);
    } else if (c != null && b != null) {
      if (c <= b) throw ArgumentError('Hypotenuse c must be greater than leg b');
      return math.sqrt(c * c - b * b);
    } else {
      throw ArgumentError('Provide at least two sides');
    }
  }

  /// Quadratic equation: ax² + bx + c = 0
  static Map<String, dynamic> solveQuadratic(double a, double b, double c) {
    if (a == 0) throw ArgumentError('Coefficient "a" cannot be zero for quadratic');
    final discriminant = b * b - 4 * a * c;
    if (discriminant > 0) {
      final sqrtD = math.sqrt(discriminant);
      final r1 = (-b + sqrtD) / (2 * a);
      final r2 = (-b - sqrtD) / (2 * a);
      return {
        'type': 'two_real',
        'discriminant': discriminant,
        'root1': r1,
        'root2': r2,
      };
    } else if (discriminant == 0) {
      final r = -b / (2 * a);
      return {
        'type': 'one_real',
        'discriminant': 0.0,
        'root1': r,
        'root2': r,
      };
    } else {
      final realPart = -b / (2 * a);
      final imagPart = math.sqrt(-discriminant) / (2 * a);
      return {
        'type': 'complex',
        'discriminant': discriminant,
        'realPart': realPart,
        'imagPart': imagPart,
      };
    }
  }
}
