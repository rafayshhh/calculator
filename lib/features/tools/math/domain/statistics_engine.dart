import 'dart:math' as math;

class StatisticsEngine {
  StatisticsEngine._();

  /// Parse comma or whitespace delimited string into a list of numbers
  static List<double> parseDataset(String text) {
    if (text.trim().isEmpty) return const [];
    final tokens = text.split(RegExp(r'[\s,]+')).where((t) => t.isNotEmpty);
    final numbers = <double>[];
    for (final token in tokens) {
      final val = double.tryParse(token);
      if (val != null) {
        numbers.add(val);
      }
    }
    return numbers;
  }

  /// Mean, Median, Mode, Min, Max
  static Map<String, dynamic> calculateMeanMedianMode(List<num> dataset) {
    if (dataset.isEmpty) {
      throw ArgumentError('Dataset cannot be empty');
    }

    final sorted = dataset.map((e) => e.toDouble()).toList()..sort();
    final count = sorted.length;
    final double sum = sorted.reduce((a, b) => a + b);
    final double mean = sum / count;

    double median;
    if (count % 2 == 1) {
      median = sorted[count ~/ 2];
    } else {
      median = (sorted[(count ~/ 2) - 1] + sorted[count ~/ 2]) / 2.0;
    }

    // Modes calculation
    final frequency = <double, int>{};
    for (final val in sorted) {
      frequency[val] = (frequency[val] ?? 0) + 1;
    }

    int maxFreq = 0;
    frequency.forEach((_, freq) {
      if (freq > maxFreq) maxFreq = freq;
    });

    List<double> modes = [];
    String modeText;
    if (maxFreq > 1) {
      modes = frequency.entries
          .where((e) => e.value == maxFreq)
          .map((e) => e.key)
          .toList()
        ..sort();
      if (modes.length == frequency.length) {
        // Every element has equal frequency > 1
        modes = [];
        modeText = 'No unique mode';
      } else {
        modeText = modes
            .map((m) => m % 1 == 0 ? m.toInt().toString() : m.toString())
            .join(', ');
      }
    } else {
      modeText = 'No unique mode';
    }

    return {
      'count': count,
      'sum': sum,
      'mean': mean,
      'median': median,
      'modes': modes,
      'modeText': modeText,
      'min': sorted.first,
      'max': sorted.last,
    };
  }

  /// Sample or Population Variance & Standard Deviation
  static Map<String, dynamic> calculateVarianceStdDev(
    List<num> dataset, {
    required bool isSample,
  }) {
    if (dataset.isEmpty) {
      throw ArgumentError('Dataset cannot be empty');
    }
    if (isSample && dataset.length < 2) {
      throw ArgumentError('Sample variance requires at least 2 data points');
    }

    final n = dataset.length;
    final double sum = dataset.fold(0.0, (prev, elem) => prev + elem);
    final double mean = sum / n;

    double sumSquaredDiff = 0.0;
    for (final x in dataset) {
      final diff = x - mean;
      sumSquaredDiff += diff * diff;
    }

    final double variance = isSample
        ? sumSquaredDiff / (n - 1)
        : sumSquaredDiff / n;
    final double stdDev = math.sqrt(variance);

    return {
      'mean': mean,
      'variance': variance,
      'stdDev': stdDev,
      'isSample': isSample,
    };
  }

  /// Range, Quartiles (Q1, Median, Q3), and IQR
  static Map<String, dynamic> calculateRangeIQR(List<num> dataset) {
    if (dataset.length < 4) {
      throw ArgumentError('Range & IQR analysis requires at least 4 data points');
    }

    final sorted = dataset.map((e) => e.toDouble()).toList()..sort();
    final min = sorted.first;
    final max = sorted.last;
    final range = max - min;

    final median = calculatePercentile(sorted, 50);
    final q1 = calculatePercentile(sorted, 25);
    final q3 = calculatePercentile(sorted, 75);
    final iqr = q3 - q1;

    final lowerOutlierBound = q1 - 1.5 * iqr;
    final upperOutlierBound = q3 + 1.5 * iqr;

    return {
      'min': min,
      'max': max,
      'range': range,
      'median': median,
      'q1': q1,
      'q3': q3,
      'iqr': iqr,
      'lowerOutlierBound': lowerOutlierBound,
      'upperOutlierBound': upperOutlierBound,
    };
  }

  /// Percentile using linear interpolation
  static double calculatePercentile(List<num> dataset, num percentile) {
    if (dataset.isEmpty) {
      throw ArgumentError('Dataset cannot be empty');
    }
    if (percentile < 0 || percentile > 100) {
      throw ArgumentError('Percentile must be between 0 and 100');
    }

    final sorted = dataset.map((e) => e.toDouble()).toList()..sort();
    if (sorted.length == 1) return sorted.first;

    final double rank = (percentile / 100.0) * (sorted.length - 1);
    final int lowerIndex = rank.floor();
    final int upperIndex = rank.ceil();

    if (lowerIndex == upperIndex) {
      return sorted[lowerIndex];
    }

    final double fraction = rank - lowerIndex;
    return sorted[lowerIndex] + fraction * (sorted[upperIndex] - sorted[lowerIndex]);
  }

  /// Permutations: nPr = n! / (n - r)!
  static int permutations(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw ArgumentError('Invalid arguments for permutations: n=$n, r=$r');
    }
    int result = 1;
    for (int i = 0; i < r; i++) {
      result *= (n - i);
    }
    return result;
  }

  /// Combinations: nCr = n! / (r! * (n - r)!)
  static int combinations(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw ArgumentError('Invalid arguments for combinations: n=$n, r=$r');
    }
    if (r == 0 || r == n) return 1;
    if (r > n - r) r = n - r; // Symmetry optimization

    int result = 1;
    for (int i = 1; i <= r; i++) {
      result = (result * (n - i + 1)) ~/ i;
    }
    return result;
  }

  /// Basic Probability
  static Map<String, dynamic> calculateProbability(num favorable, num total) {
    if (total <= 0 || favorable < 0 || favorable > total) {
      throw ArgumentError('Invalid arguments for probability: favorable=$favorable, total=$total');
    }

    final double prob = favorable / total;
    final double pct = prob * 100.0;
    final double comp = 1.0 - prob;
    final double compPct = comp * 100.0;
    final String odds = '$favorable : ${total - favorable}';

    return {
      'probability': prob,
      'percentage': pct,
      'complement': comp,
      'complementPercentage': compPct,
      'oddsInFavor': odds,
    };
  }

  /// Binomial Distribution
  static Map<String, dynamic> calculateBinomialDistribution({
    required int n,
    required int k,
    required double p,
  }) {
    if (n < 0 || k < 0 || k > n || p < 0 || p > 1) {
      throw ArgumentError('Invalid parameters for binomial distribution: n=$n, k=$k, p=$p');
    }

    final nCk = combinations(n, k);
    final exact = nCk * math.pow(p, k) * math.pow(1.0 - p, n - k);
    final expected = n * p;
    final variance = n * p * (1.0 - p);
    final stdDev = math.sqrt(variance);

    return {
      'exactProbability': exact,
      'expectedValue': expected,
      'variance': variance,
      'stdDev': stdDev,
    };
  }
}
