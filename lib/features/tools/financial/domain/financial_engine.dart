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
}

class FinancialEngine {
  FinancialEngine._();

  /// Loan / Mortgage calculation
  static LoanResult calculateLoan({
    required double principal,
    required double annualRate,
    required int durationInPeriods,
    int paymentsPerYear = 12,
  }) {
    if (principal < 0) throw ArgumentError('Principal cannot be negative');
    if (durationInPeriods <= 0) throw ArgumentError('Duration must be positive');

    if (annualRate == 0) {
      final pmt = principal / durationInPeriods;
      return LoanResult(
        periodicPayment: pmt,
        totalPayment: principal,
        totalInterest: 0.0,
      );
    }

    final periodicRate = (annualRate / 100.0) / paymentsPerYear;
    final factor = math.pow(1.0 + periodicRate, durationInPeriods);
    final pmt = principal * (periodicRate * factor) / (factor - 1.0);
    final totalPayment = pmt * durationInPeriods;
    final totalInterest = totalPayment - principal;

    return LoanResult(
      periodicPayment: pmt,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
    );
  }

  /// Compound Interest calculation
  static CompoundInterestResult calculateCompoundInterest({
    required double principal,
    required double annualRate,
    required int years,
    int compoundsPerYear = 12,
    double additionalContribution = 0,
  }) {
    if (principal < 0) throw ArgumentError('Principal cannot be negative');
    if (years < 0) throw ArgumentError('Years cannot be negative');

    final n = compoundsPerYear.toDouble();
    final r = (annualRate / 100.0) / n;
    final totalCompounds = n * years;

    double amount = principal * math.pow(1.0 + r, totalCompounds);

    if (additionalContribution > 0 && r > 0) {
      final pmtFutureVal = additionalContribution * ((math.pow(1.0 + r, totalCompounds) - 1.0) / r);
      amount += pmtFutureVal;
    }

    final totalPrincipal = principal + (additionalContribution * totalCompounds);
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
    required double taxRate,
    required bool isTaxIncluded,
  }) {
    if (amount < 0) throw ArgumentError('Amount cannot be negative');
    if (taxRate < 0) throw ArgumentError('Tax rate cannot be negative');

    if (isTaxIncluded) {
      // VAT reverse calculation
      final subtotal = amount / (1.0 + (taxRate / 100.0));
      final tax = amount - subtotal;
      return {
        'subtotal': subtotal,
        'tax': tax,
        'total': amount,
      };
    } else {
      // Add tax to amount
      final tax = amount * (taxRate / 100.0);
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
