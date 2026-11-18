import 'dart:math' as math;

/// Pure-Dart Advanced Statistics & Probability Engine.
class AdvancedStatisticsEngine {
  AdvancedStatisticsEngine._();

  /// Standard Normal Cumulative Distribution Function Φ(z) using high-precision Hart approximation:
  static double standardNormalCDF(double z) {
    if (z < -8.0) return 0.0;
    if (z > 8.0) return 1.0;

    // Error function approximation
    double erf(double x) {
      const a1 = 0.254829592;
      const a2 = -0.284496736;
      const a3 = 1.421413741;
      const a4 = -1.453152027;
      const a5 = 1.061405429;
      const p = 0.3275911;

      final sign = x < 0 ? -1 : 1;
      final absX = x.abs();
      final t = 1.0 / (1.0 + p * absX);
      final y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-absX * absX);
      return sign * y;
    }

    return 0.5 * (1.0 + erf(z / math.sqrt(2.0)));
  }

  /// Calculates Z-Score and cumulative probabilities:
  static Map<String, dynamic> calculateZScore({
    required double rawScore,
    required double mean,
    required double stdDev,
  }) {
    if (stdDev <= 0) return {'error': 'Standard deviation must be strictly positive (> 0)'};

    final z = (rawScore - mean) / stdDev;
    final cdf = standardNormalCDF(z); // P(X <= rawScore)
    final rightTail = 1.0 - cdf; // P(X >= rawScore)
    final twoTailed = 2.0 * (z >= 0 ? rightTail : cdf);

    return {
      'rawScore': rawScore,
      'mean': mean,
      'stdDev': stdDev,
      'zScore': z,
      'percentile': cdf * 100.0,
      'pLessEqual': cdf,
      'pGreaterEqual': rightTail,
      'pTwoTailed': twoTailed.clamp(0.0, 1.0),
    };
  }

  /// Confidence Interval for a Population Mean:
  static Map<String, dynamic> confidenceIntervalMean({
    required double sampleMean,
    required double sampleStdDev,
    required int sampleSize,
    required double confidenceLevelPercent, // e.g. 95 for 95%
  }) {
    if (sampleSize <= 1) return {'error': 'Sample size must be greater than 1'};
    if (sampleStdDev < 0) return {'error': 'Standard deviation cannot be negative'};

    // Approximate z-critical value:
    // 90% -> 1.645, 95% -> 1.960, 99% -> 2.576
    final alpha = 1.0 - (confidenceLevelPercent / 100.0);
    double zCritical;
    if (confidenceLevelPercent >= 98.5) {
      zCritical = 2.576;
    } else if (confidenceLevelPercent >= 94.5) {
      zCritical = 1.960;
    } else if (confidenceLevelPercent >= 89.5) {
      zCritical = 1.645;
    } else {
      zCritical = 1.960; // fallback
    }

    final standardError = sampleStdDev / math.sqrt(sampleSize);
    final marginOfError = zCritical * standardError;
    final lowerBound = sampleMean - marginOfError;
    final upperBound = sampleMean + marginOfError;

    return {
      'sampleMean': sampleMean,
      'sampleSize': sampleSize,
      'confidenceLevel': confidenceLevelPercent,
      'zCritical': zCritical,
      'standardError': standardError,
      'marginOfError': marginOfError,
      'lowerBound': lowerBound,
      'upperBound': upperBound,
      'intervalString': '[${lowerBound.toStringAsFixed(3)}, ${upperBound.toStringAsFixed(3)}]',
    };
  }

  /// Ordinary Least Squares Linear Regression: y = mx + b
  static Map<String, dynamic> linearRegression(
    List<double> x,
    List<double> y,
  ) {
    if (x.length != y.length || x.length < 2) {
      return {'error': 'Lists x and y must have equal length with at least 2 points'};
    }

    final n = x.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;
    double sumY2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }

    final denom = n * sumX2 - sumX * sumX;
    if (denom.abs() < 1e-12) {
      return {'error': 'Vertical line (all x values are identical). Slope is undefined.'};
    }

    final m = (n * sumXY - sumX * sumY) / denom;
    final b = (sumY - m * sumX) / n;

    // Pearson correlation r
    final numR = n * sumXY - sumX * sumY;
    final denR = math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    final r = denR > 1e-12 ? (numR / denR) : 0.0;
    final rSquared = r * r;

    return {
      'slope': m,
      'intercept': b,
      'r': r,
      'rSquared': rSquared,
      'equation': 'y = ${m.toStringAsFixed(4)}x + ${b.toStringAsFixed(4)}',
      'n': n,
    };
  }

  /// Chi-Square (χ²) Goodness-of-Fit test:
  static Map<String, dynamic> chiSquareTest(
    List<double> observed,
    List<double> expected,
  ) {
    if (observed.length != expected.length || observed.isEmpty) {
      return {'error': 'Observed and expected lists must have the same non-zero length'};
    }

    double chiSquare = 0;
    for (int i = 0; i < observed.length; i++) {
      if (expected[i] <= 0) return {'error': 'Expected frequencies must be strictly positive'};
      final diff = observed[i] - expected[i];
      chiSquare += (diff * diff) / expected[i];
    }

    final degreesOfFreedom = observed.length - 1;

    return {
      'chiSquare': chiSquare,
      'degreesOfFreedom': degreesOfFreedom,
      'categoriesCount': observed.length,
    };
  }

  /// Poisson distribution: P(X = k) = (λ^k * e^(-λ)) / k!
  static Map<String, dynamic> poissonDistribution({
    required double lambda,
    required int k,
  }) {
    if (lambda <= 0) return {'error': 'Rate parameter λ must be strictly positive (> 0)'};
    if (k < 0) return {'error': 'Count k must be non-negative (≥ 0)'};

    double factorial(int n) {
      double f = 1;
      for (int i = 2; i <= n; i++) f *= i;
      return f;
    }

    final pmf = (math.pow(lambda, k) * math.exp(-lambda)) / factorial(k);

    double cdf = 0;
    for (int i = 0; i <= k; i++) {
      cdf += (math.pow(lambda, i) * math.exp(-lambda)) / factorial(i);
    }

    return {
      'lambda': lambda,
      'k': k,
      'pmf': pmf,
      'cdf': cdf,
      'mean': lambda,
      'variance': lambda,
      'stdDev': math.sqrt(lambda),
    };
  }
}
