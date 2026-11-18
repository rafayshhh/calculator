import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/everyday_calculators/domain/everyday_engine.dart';

void main() {
  group('PercentageCalculatorEngine', () {
    test('percentOf', () {
      expect(EverydayEngine.calculatePercentOf(20, 500), 100);
      expect(EverydayEngine.calculatePercentOf(10, 200), 20);
      expect(EverydayEngine.calculatePercentOf(0, 500), 0);
    });

    test('isWhatPercent', () {
      expect(EverydayEngine.calculateIsWhatPercent(100, 500), 20);
      expect(EverydayEngine.calculateIsWhatPercent(50, 100), 50);
      expect(EverydayEngine.calculateIsWhatPercent(100, 0).isNaN, true);
    });

    test('percentageChange', () {
      expect(EverydayEngine.calculatePercentageChange(100, 125), 25);
      expect(EverydayEngine.calculatePercentageChange(125, 100), -20);
      expect(EverydayEngine.calculatePercentageChange(0, 100).isNaN, true);
    });

    test('percentageDifference', () {
      expect(
        EverydayEngine.calculatePercentageDifference(10, 20),
        closeTo(66.666, 0.001),
      );
      expect(EverydayEngine.calculatePercentageDifference(0, 0).isNaN, true);
    });
  });
}
