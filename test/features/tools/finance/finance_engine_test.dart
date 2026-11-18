import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/finance/domain/finance_engine.dart';

void main() {
  group('FinanceEngine — Unit Tests', () {
    test('Compound Interest - Solves future value correctly', () {
      final res = FinanceEngine.calculateCompoundInterest(
        principal: 10000,
        annualRatePercent: 8,
        timeYears: 5,
        compoundsPerYear: 12,
        solveFor: 'futureValue',
      );
      expect((res['futureValue'] as double).round(), equals(14898));
      expect((res['totalInterest'] as double).round(), equals(4898));
    });

    test('Compound Interest - Inverse solving for principal, rate, time', () {
      final pRes = FinanceEngine.calculateCompoundInterest(
        futureValue: 14898.457,
        annualRatePercent: 8,
        timeYears: 5,
        compoundsPerYear: 12,
        solveFor: 'principal',
      );
      expect((pRes['principal'] as double).round(), equals(10000));

      final rRes = FinanceEngine.calculateCompoundInterest(
        futureValue: 14898.457,
        principal: 10000,
        timeYears: 5,
        compoundsPerYear: 12,
        solveFor: 'rate',
      );
      expect((rRes['annualRatePercent'] as double).round(), equals(8));

      final tRes = FinanceEngine.calculateCompoundInterest(
        futureValue: 14898.457,
        principal: 10000,
        annualRatePercent: 8,
        compoundsPerYear: 12,
        solveFor: 'time',
      );
      expect((tRes['timeYears'] as double).round(), equals(5));
    });

    test('Simple Interest - Solves I = Prt and inverse modes', () {
      final res = FinanceEngine.calculateSimpleInterest(
        principal: 5000,
        annualRatePercent: 5,
        timeYears: 3,
        solveFor: 'interest',
      );
      expect(res['interest'], equals(750.0));
      expect(res['finalAmount'], equals(5750.0));

      final pRes = FinanceEngine.calculateSimpleInterest(
        interestAmount: 750,
        annualRatePercent: 5,
        timeYears: 3,
        solveFor: 'principal',
      );
      expect((pRes['principal'] as double).round(), equals(5000));
    });

    test('Loan Payment / EMI - Calculates periodic payment and totals', () {
      final res = FinanceEngine.calculateLoan(
        principal: 200000,
        annualRatePercent: 6,
        termYears: 30,
        paymentsPerYear: 12,
      );
      expect((res['periodicPayment'] as double).round(), equals(1199));
      expect((res['totalPayment'] as double).round(), equals(431676));
      expect((res['totalInterest'] as double).round(), equals(231676));
    });

    test(
      'Mortgage Calculator - Computes monthly P&I, taxes, insurance, HOA',
      () {
        final res = FinanceEngine.calculateMortgage(
          homePrice: 400000,
          downPaymentPercent: 20,
          annualRatePercent: 6.5,
          termYears: 30,
          annualPropertyTax: 4800,
          annualHomeInsurance: 1200,
          monthlyHoa: 150,
        );
        expect(res['loanAmount'], equals(320000.0));
        expect(
          (res['monthlyPrincipalAndInterest'] as double).round(),
          equals(2023),
        );
        expect(res['monthlyTax'], equals(400.0));
        expect(res['monthlyInsurance'], equals(100.0));
        expect((res['totalMonthlyPayment'] as double).round(), equals(2673));
      },
    );

    test('Percentage Calculator - Supports 5 main modes cleanly', () {
      final p1 = FinanceEngine.calculatePercentage(
        mode: 'percentOf',
        val1: 25,
        val2: 200,
      );
      expect(p1['result'], equals(50.0));

      final p2 = FinanceEngine.calculatePercentage(
        mode: 'isWhatPercent',
        val1: 50,
        val2: 200,
      );
      expect(p2['result'], equals(25.0));

      final p3 = FinanceEngine.calculatePercentage(
        mode: 'percentageChange',
        val1: 100,
        val2: 150,
      );
      expect(p3['result'], equals(50.0));

      final p4 = FinanceEngine.calculatePercentage(
        mode: 'percentageDifference',
        val1: 100,
        val2: 200,
      );
      expect((p4['result'] as double).toStringAsFixed(2), equals('66.67'));

      final p5 = FinanceEngine.calculatePercentage(
        mode: 'reversePercent',
        val1: 20,
        val2: 120,
      );
      expect(p5['result'], equals(100.0));
    });

    test(
      'Profit Margin & Markup - Strictly distinguishes margin and markup',
      () {
        final res = FinanceEngine.calculateMarginMarkup(
          cost: 60,
          revenue: 100,
          solveMode: 'fromCostAndRevenue',
        );
        expect(res['profit'], equals(40.0));
        expect(res['marginPercent'], equals(40.0)); // 40 / 100
        expect(
          (res['markupPercent'] as double).toStringAsFixed(2),
          equals('66.67'),
        ); // 40 / 60
      },
    );

    test('Break-Even Calculator - Computes break-even units and revenue', () {
      final res = FinanceEngine.calculateBreakEven(
        fixedCosts: 10000,
        variableCostPerUnit: 15,
        unitPrice: 25,
      );
      expect(res['contributionMargin'], equals(10.0));
      expect(res['breakEvenUnits'], equals(1000.0));
      expect(res['breakEvenRevenue'], equals(25000.0));
      expect(res['contributionMarginRatio'], equals(40.0));
    });

    test('Discount & Sale - Calculates multi-stage discounts and taxes', () {
      final res = FinanceEngine.calculateDiscountAndSale(
        originalPrice: 100,
        discountPercent: 20,
        taxPercent: 10,
      );
      expect(res['discountAmount'], equals(20.0));
      expect(res['salePrice'], equals(80.0));
      expect(res['taxAmount'], equals(8.0));
      expect(res['finalPrice'], equals(88.0));
    });

    test('CAGR - Computes compound annual growth rate', () {
      final res = FinanceEngine.calculateCagr(
        beginningValue: 10000,
        endingValue: 19500,
        years: 3,
      );
      expect(
        (res['cagrPercent'] as double).toStringAsFixed(2),
        equals('24.93'),
      );
      expect(res['totalGrowthPercent'], equals(95.0));
    });

    test('ROI - Computes net return and ROI %', () {
      final res = FinanceEngine.calculateRoi(
        totalCost: 5000,
        totalGain: 7500,
        investmentYears: 2,
      );
      expect(res['netReturn'], equals(2500.0));
      expect(res['roiPercent'], equals(50.0));
      expect(
        (res['annualizedRoiPercent'] as double).toStringAsFixed(2),
        equals('22.47'),
      );
    });

    test('Tip & Split - Calculates tip, total, and split amount', () {
      final res = FinanceEngine.calculateTipAndSplit(
        billAmount: 120,
        tipPercent: 18,
        numberOfPeople: 4,
        taxPercent: 8.5,
      );
      expect(res['tipAmount'], closeTo(21.6, 0.001));
      expect(res['taxAmount'], closeTo(10.2, 0.001));
      expect(res['totalBill'], closeTo(151.8, 0.001));
      expect(res['perPersonAmount'], closeTo(37.95, 0.001));
    });

    test('Currency Conversion Architecture - Computes converted amount & inverse rate', () {
      final res = FinanceEngine.convertCurrency(
        amount: 100,
        sourceToTargetRate: 1.25,
        sourceCode: 'USD',
        targetCode: 'EUR',
      );
      expect(res['convertedAmount'], equals(125.0));
      expect(res['inverseRate'], equals(0.8));
    });
  });
}
