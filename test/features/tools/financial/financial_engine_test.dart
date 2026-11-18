import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/financial/domain/financial_engine.dart';

void main() {
  group('FinancialEngine Tests', () {
    test('Loan calculation works (normal)', () {
      final res = FinancialEngine.calculateLoan(
        principal: 10000,
        annualRate: 5,
        durationInPeriods: 60,
        paymentsPerYear: 12,
      );
      expect(res.periodicPayment, closeTo(188.71, 0.01));
      expect(res.totalPayment, closeTo(11322.74, 0.01));
      expect(res.totalInterest, closeTo(1322.74, 0.01));
    });

    test('Loan calculation works (0% interest)', () {
      final res = FinancialEngine.calculateLoan(
        principal: 10000,
        annualRate: 0,
        durationInPeriods: 60,
        paymentsPerYear: 12,
      );
      expect(res.periodicPayment, closeTo(166.66, 0.01));
      expect(res.totalInterest, 0);
    });

    test('Compound interest works', () {
      final res = FinancialEngine.calculateCompoundInterest(
        principal: 1000,
        annualRate: 5,
        years: 10,
        compoundsPerYear: 12,
        additionalContribution: 0,
      );
      expect(res.finalAmount, closeTo(1647.00, 0.01));
    });

    test('Tax addition works', () {
      final res = FinancialEngine.calculateTax(
        amount: 100,
        taxRate: 10,
        isTaxIncluded: false,
      );
      expect(res['subtotal'], 100);
      expect(res['tax'], 10);
      expect(res['total'], 110);
    });

    test('Tax removal (VAT) works', () {
      final res = FinancialEngine.calculateTax(
        amount: 110,
        taxRate: 10,
        isTaxIncluded: true,
      );
      expect(res['subtotal'], closeTo(100, 0.01));
      expect(res['tax'], closeTo(10, 0.01));
      expect(res['total'], 110);
    });

    test('Discount and Tax works', () {
      final res = FinancialEngine.calculateDiscount(
        originalPrice: 100,
        discountPercent: 20,
        taxPercent: 10,
      );
      expect(res['priceAfterDiscount'], 80);
      expect(res['taxAmount'], 8);
      expect(res['finalPrice'], 88);
    });
  });
}
