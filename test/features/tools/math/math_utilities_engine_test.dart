import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/math/domain/math_utilities_engine.dart';

void main() {
  group('MathUtilitiesEngine', () {
    test('calculateAverage handles normal list', () {
      final numbers = [10.0, 20.0, 30.0, 40.0, 50.0];
      final result = MathUtilitiesEngine.calculateAverage(numbers);

      expect(result.sum, 150);
      expect(result.mean, 30);
      expect(result.median, 30);
      expect(result.min, 10);
      expect(result.max, 50);
    });

    test('calculateAverage handles unsorted even list', () {
      final numbers = [4.0, 1.0, 3.0, 2.0];
      final result = MathUtilitiesEngine.calculateAverage(numbers);

      expect(result.mean, 2.5);
      expect(result.median, 2.5); // 2 and 3 are middle
    });

    test('simplifyFraction handles normal fraction', () {
      final result = MathUtilitiesEngine.simplifyFraction(10, 4);

      expect(result.numerator, 1);
      expect(result.denominator, 2);
      expect(result.wholeNumber, 2);
      expect(result.mixedFraction, '2 1/2');
      expect(result.decimal, 2.5);
    });

    test('simplifyFraction handles whole numbers', () {
      final result = MathUtilitiesEngine.simplifyFraction(10, 5);

      expect(result.wholeNumber, 2);
      expect(result.numerator, 0);
      expect(result.mixedFraction, '2');
    });

    test('simplifyFraction throws on zero denominator', () {
      expect(
        () => MathUtilitiesEngine.simplifyFraction(10, 0),
        throwsArgumentError,
      );
    });
  });
}
