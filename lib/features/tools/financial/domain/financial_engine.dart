import 'dart:math' as math;

class LoanResult {
  final double periodicPayment;
  final double totalPayment;
  final double totalInterest;

  const LoanResult({
    required this.periodicPayment,
    required this.totalPayment,
    required this.totalInterest,
  });

  double get monthlyPayment => periodicPayment;
  double get emi => periodicPayment;
}

class CompoundInterestResult {
  final double finalAmount;
  final double totalPrincipal;
  final double totalInterest;

  const CompoundInterestResult({
    required this.finalAmount,
    required this.totalPrincipal,
    required this.totalInterest,
  });

  double get futureValue => finalAmount;
  double get interestEarned => totalInterest;
}

class SimpleInterestResult {
  final double principal;
  final double interestEarned;
  final double finalAmount;

  const SimpleInterestResult({
    required this.principal,
    required this.interestEarned,
    required this.finalAmount,
  });
}

class FinancialEngine {
  FinancialEngine._();

  static SimpleInterestResult calculateSimpleInterest({
    required double principal,
    required double annualRate,
    required double years,
  }) {
    if (principal < 0) throw ArgumentError('Principal cannot be negative');
    if (annualRate < 0) throw ArgumentError('Rate cannot be negative');
    if (years < 0) throw ArgumentError('Years cannot be negative');
    final interest = principal * (annualRate / 100.0) * years;
    return SimpleInterestResult(
      principal: principal,
      interestEarned: interest,
      finalAmount: principal + interest,
    );
  }

  /// Loan / Mortgage calculation
  static LoanResult calculateLoan({
    required double principal,
    required double annualRate,
    int? durationInPeriods,
    int? termMonths,
    int paymentsPerYear = 12,
  }) {
    final periods = (termMonths ?? durationInPeriods ?? 12).toInt();
    if (principal < 0) throw ArgumentError('Principal cannot be negative');
    if (periods <= 0) throw ArgumentError('Duration must be positive');

    if (annualRate == 0) {
      final pmt = principal / periods;
      return LoanResult(
        periodicPayment: pmt,
        totalPayment: principal,
        totalInterest: 0.0,
      );
    }

    final periodicRate = (annualRate / 100.0) / paymentsPerYear;
    final factor = math.pow(1.0 + periodicRate, periods);
    final pmt = principal * (periodicRate * factor) / (factor - 1.0);
    final totalPayment = pmt * periods;
    final totalInterest = totalPayment - principal;

    return LoanResult(
      periodicPayment: pmt,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
    );
  }

  static LoanResult calculateEmi({
    required double principal,
    required double annualRate,
    int? durationInPeriods,
    int? termMonths,
    int paymentsPerYear = 12,
  }) =>
      calculateLoan(
        principal: principal,
        annualRate: annualRate,
        durationInPeriods: durationInPeriods,
        termMonths: termMonths,
        paymentsPerYear: paymentsPerYear,
      );

  /// Compound Interest calculation
  static CompoundInterestResult calculateCompoundInterest({
    required double principal,
    required double annualRate,
    required num years,
    int? compoundsPerYear,
    int? compoundingFrequency,
    int? contributionsPerYear,
    double? additionalContribution,
    double? monthlyContribution,
  }) {
    if (principal < 0) throw ArgumentError('Principal cannot be negative');
    if (years < 0) throw ArgumentError('Years cannot be negative');

    final n = (compoundingFrequency ?? compoundsPerYear ?? 12).toDouble();
    final contrib = monthlyContribution ?? additionalContribution ?? 0.0;
    final r = (annualRate / 100.0) / n;
    final totalCompounds = n * years;

    double amount = principal * math.pow(1.0 + r, totalCompounds);

    if (contrib > 0 && r > 0) {
      final pmtFutureVal = contrib * ((math.pow(1.0 + r, totalCompounds) - 1.0) / r);
      amount += pmtFutureVal;
    }

    final totalPrincipal = principal + (contrib * totalCompounds);
    final totalInterest = amount - totalPrincipal;

    return CompoundInterestResult(
      finalAmount: amount,
      totalPrincipal: totalPrincipal,
      totalInterest: totalInterest,
    );
  }

  /// Sales Tax and VAT
  static Map<String, double> calculateTax({
    required double amount,
    double? taxRate,
    double? taxRatePercent,
    bool? isTaxIncluded,
    bool? isInclusive,
  }) {
    final effectiveTaxRate = taxRatePercent ?? taxRate ?? 0.0;
    final effectiveIsIncluded = isInclusive ?? isTaxIncluded ?? false;
    if (amount < 0) throw ArgumentError('Amount cannot be negative');
    if (effectiveTaxRate < 0) throw ArgumentError('Tax rate cannot be negative');

    if (effectiveIsIncluded) {
      // VAT reverse calculation
      final subtotal = amount / (1.0 + (effectiveTaxRate / 100.0));
      final tax = amount - subtotal;
      return {
        'subtotal': subtotal,
        'tax': tax,
        'total': amount,
      };
    } else {
      // Add tax to amount
      final tax = amount * (effectiveTaxRate / 100.0);
      final total = amount + tax;
      return {
        'subtotal': amount,
        'tax': tax,
        'total': total,
      };
    }
  }

  /// Discount and Tax
  static Map<String, double> calculateDiscount({
    required double originalPrice,
    required double discountPercent,
    double taxPercent = 0.0,
  }) {
    if (originalPrice < 0) throw ArgumentError('Price cannot be negative');
    final discountAmount = originalPrice * (discountPercent / 100.0);
    final priceAfterDiscount = originalPrice - discountAmount;
    final taxAmount = priceAfterDiscount * (taxPercent / 100.0);
    final finalPrice = priceAfterDiscount + taxAmount;

    return {
      'priceAfterDiscount': priceAfterDiscount,
      'taxAmount': taxAmount,
      'finalPrice': finalPrice,
    };
  }
}
