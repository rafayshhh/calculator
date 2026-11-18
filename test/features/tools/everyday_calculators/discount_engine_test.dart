import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/everyday_calculators/domain/everyday_engine.dart';

void main() {
  group('DiscountCalculatorEngine', () {
    test('valid discount', () {
      final res = EverydayEngine.calculateDiscount(100, 20);
      expect(res.discountAmount, 20);
      expect(res.finalPrice, 80);
    });

    test('100% discount', () {
      final res = EverydayEngine.calculateDiscount(250, 100);
      expect(res.discountAmount, 250);
      expect(res.finalPrice, 0);
    });

    test('0% discount', () {
      final res = EverydayEngine.calculateDiscount(250, 0);
      expect(res.discountAmount, 0);
      expect(res.finalPrice, 250);
    });

    test('invalid price', () {
      expect(
        () => EverydayEngine.calculateDiscount(-100, 20),
        throwsArgumentError,
      );
    });

    test('invalid discount percentage', () {
      expect(
        () => EverydayEngine.calculateDiscount(100, 120),
        throwsArgumentError,
      );
      expect(
        () => EverydayEngine.calculateDiscount(100, -10),
        throwsArgumentError,
      );
    });
  });
}
