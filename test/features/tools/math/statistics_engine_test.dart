import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/math/domain/statistics_engine.dart';

void main() {
  group('StatisticsEngine - Mean / Median / Mode', () {
    test('Calculates Mean, Median, and Mode for dataset with unique mode', () {
      final dataset = StatisticsEngine.parseDataset('1, 2, 2, 3, 4, 7, 9');
      final res = StatisticsEngine.calculateMeanMedianMode(dataset);

      expect(res['count'], 7);
      expect(res['sum'], 28.0);
      expect(res['mean'], 4.0);
      expect(res['median'], 3.0);
      expect(res['modes'], [2.0]);
      expect(res['modeText'], '2');
      expect(res['min'], 1.0);
      expect(res['max'], 9.0);
    });

    test('Calculates Median correctly for even count dataset', () {
      final dataset = StatisticsEngine.parseDataset('10 20 30 40');
      final res = StatisticsEngine.calculateMeanMedianMode(dataset);
      expect(res['median'], 25.0);
      expect(res['modeText'], 'No unique mode');
    });

    test('Throws ArgumentError on empty dataset', () {
      expect(
        () => StatisticsEngine.calculateMeanMedianMode([]),
        throwsArgumentError,
      );
    });
  });

  group('StatisticsEngine - Variance & Standard Deviation', () {
    test('Calculates Sample Variance and StdDev (N-1)', () {
      final dataset = StatisticsEngine.parseDataset('2, 4, 4, 4, 5, 5, 7, 9');
      final res = StatisticsEngine.calculateVarianceStdDev(
        dataset,
        isSample: true,
      );

      expect(res['mean'], 5.0);
      expect(res['variance'], 4.571428571428571);
      expect(res['stdDev'], closeTo(2.138, 0.001));
      expect(res['isSample'], isTrue);
    });

    test('Calculates Population Variance and StdDev (N)', () {
      final dataset = StatisticsEngine.parseDataset('2, 4, 4, 4, 5, 5, 7, 9');
      final res = StatisticsEngine.calculateVarianceStdDev(
        dataset,
        isSample: false,
      );

      expect(res['mean'], 5.0);
      expect(res['variance'], 4.0);
      expect(res['stdDev'], 2.0);
      expect(res['isSample'], isFalse);
    });

    test('Throws on single element for sample variance', () {
      expect(
        () => StatisticsEngine.calculateVarianceStdDev([5.0], isSample: true),
        throwsArgumentError,
      );
    });
  });

  group('StatisticsEngine - Range & IQR', () {
    test('Calculates Range, Q1, Median, Q3, and IQR', () {
      final dataset = StatisticsEngine.parseDataset(
        '4, 6, 7, 8, 10, 12, 14, 15, 18, 20',
      );
      final res = StatisticsEngine.calculateRangeIQR(dataset);

      expect(res['min'], 4.0);
      expect(res['max'], 20.0);
      expect(res['range'], 16.0);
      expect(res['median'], 11.0);
      expect(res['q1'], 7.0);
      expect(res['q3'], 15.0);
      expect(res['iqr'], 8.0);
      expect(res['lowerOutlierBound'], -5.0);
      expect(res['upperOutlierBound'], 27.0);
    });

    test('Throws on dataset smaller than 4 values', () {
      expect(
        () => StatisticsEngine.calculateRangeIQR([1, 2, 3]),
        throwsArgumentError,
      );
    });
  });

  group('StatisticsEngine - Percentile', () {
    test('Calculates percentiles with linear interpolation', () {
      final dataset = StatisticsEngine.parseDataset('15, 20, 35, 40, 50');
      expect(StatisticsEngine.calculatePercentile(dataset, 0), 15.0);
      expect(StatisticsEngine.calculatePercentile(dataset, 50), 35.0);
      expect(StatisticsEngine.calculatePercentile(dataset, 100), 50.0);
      expect(
        StatisticsEngine.calculatePercentile(dataset, 40),
        29.0,
      ); // 20 + 0.6*(35-20) = 29
    });

    test('Throws on invalid percentile', () {
      expect(
        () => StatisticsEngine.calculatePercentile([1, 2], -5),
        throwsArgumentError,
      );
      expect(
        () => StatisticsEngine.calculatePercentile([1, 2], 105),
        throwsArgumentError,
      );
    });
  });

  group('StatisticsEngine - Permutations & Combinations', () {
    test('Calculates Permutations nPr safely', () {
      expect(StatisticsEngine.permutations(5, 2), 20);
      expect(StatisticsEngine.permutations(6, 0), 1);
      expect(StatisticsEngine.permutations(7, 7), 5040);
    });

    test('Calculates Combinations nCr safely without overflow', () {
      expect(StatisticsEngine.combinations(5, 2), 10);
      expect(StatisticsEngine.combinations(10, 3), 120);
      expect(StatisticsEngine.combinations(52, 5), 2598960);
      expect(StatisticsEngine.combinations(6, 0), 1);
    });

    test('Throws on invalid n or r', () {
      expect(() => StatisticsEngine.permutations(4, 5), throwsArgumentError);
      expect(() => StatisticsEngine.combinations(4, -1), throwsArgumentError);
    });
  });

  group('StatisticsEngine - Basic & Binomial Probability', () {
    test('Calculates Basic Probability and Complement', () {
      final res = StatisticsEngine.calculateProbability(3, 12);
      expect(res['probability'], 0.25);
      expect(res['percentage'], 25.0);
      expect(res['complement'], 0.75);
      expect(res['complementPercentage'], 75.0);
      expect(res['oddsInFavor'], '3 : 9');
    });

    test('Calculates Binomial Distribution exact and cumulative', () {
      final res = StatisticsEngine.calculateBinomialDistribution(
        n: 10,
        k: 5,
        p: 0.5,
      );
      expect(res['exactProbability'], closeTo(0.24609, 0.0001));
      expect(res['expectedValue'], 5.0);
      expect(res['variance'], 2.5);
      expect(res['stdDev'], closeTo(1.5811, 0.0001));
    });

    test('Throws on invalid binomial arguments', () {
      expect(
        () =>
            StatisticsEngine.calculateBinomialDistribution(n: 5, k: 6, p: 0.5),
        throwsArgumentError,
      );
      expect(
        () =>
            StatisticsEngine.calculateBinomialDistribution(n: 5, k: 2, p: 1.5),
        throwsArgumentError,
      );
    });
  });
}
