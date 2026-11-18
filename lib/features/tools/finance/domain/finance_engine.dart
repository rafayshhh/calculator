import 'dart:math' as math;

class FinanceEngine {
  FinanceEngine._();

  /// Compound Interest
  static Map<String, dynamic> calculateCompoundInterest({
    double? principal,
    double? annualRatePercent,
    double? timeYears,
    int compoundsPerYear = 12,
    double? futureValue,
    String solveFor = 'futureValue',
  }) {
    final n = compoundsPerYear.toDouble();

    if (solveFor == 'principal' && futureValue != null && annualRatePercent != null && timeYears != null) {
      final r = (annualRatePercent / 100.0) / n;
      final nt = n * timeYears;
      final p = futureValue / math.pow(1.0 + r, nt);
      return {
        'principal': p,
        'futureValue': futureValue,
        'totalInterest': futureValue - p,
        'annualRatePercent': annualRatePercent,
        'timeYears': timeYears,
      };
    } else if (solveFor == 'rate' && futureValue != null && principal != null && timeYears != null) {
      final nt = n * timeYears;
      final r = n * (math.pow(futureValue / principal, 1.0 / nt) - 1.0);
      final ratePercent = r * 100.0;
      return {
        'principal': principal,
        'futureValue': futureValue,
        'totalInterest': futureValue - principal,
        'annualRatePercent': ratePercent,
        'timeYears': timeYears,
      };
    } else if (solveFor == 'time' && futureValue != null && principal != null && annualRatePercent != null) {
      final r = (annualRatePercent / 100.0) / n;
      final t = math.log(futureValue / principal) / (n * math.log(1.0 + r));
      return {
        'principal': principal,
        'futureValue': futureValue,
        'totalInterest': futureValue - principal,
        'annualRatePercent': annualRatePercent,
        'timeYears': t,
      };
    } else {
      // Default: solve for futureValue
      final p = principal ?? 0.0;
      final ratePct = annualRatePercent ?? 0.0;
      final t = timeYears ?? 0.0;
      final r = (ratePct / 100.0) / n;
      final nt = n * t;
      final fv = p * math.pow(1.0 + r, nt);
      return {
        'principal': p,
        'futureValue': fv,
        'totalInterest': fv - p,
        'annualRatePercent': ratePct,
        'timeYears': t,
      };
    }
  }

  /// Simple Interest
  static Map<String, dynamic> calculateSimpleInterest({
    double? principal,
    double? annualRatePercent,
    double? timeYears,
    double? interestAmount,
    String solveFor = 'interest',
  }) {
    if (solveFor == 'principal' && interestAmount != null && annualRatePercent != null && timeYears != null) {
      final r = annualRatePercent / 100.0;
      final p = interestAmount / (r * timeYears);
      return {
        'principal': p,
        'interest': interestAmount,
        'finalAmount': p + interestAmount,
      };
    } else {
      final p = principal ?? 0.0;
      final r = (annualRatePercent ?? 0.0) / 100.0;
      final t = timeYears ?? 0.0;
      final i = p * r * t;
      return {
        'principal': p,
        'interest': i,
        'finalAmount': p + i,
      };
    }
  }

  /// Loan / EMI
  static Map<String, dynamic> calculateLoan({
    required double principal,
    required double annualRatePercent,
    required double termYears,
    int paymentsPerYear = 12,
  }) {
    final n = termYears * paymentsPerYear;
    if (annualRatePercent == 0) {
      final pmt = n > 0 ? principal / n : 0.0;
      return {
        'periodicPayment': pmt,
        'totalPayment': principal,
        'totalInterest': 0.0,
      };
    }
    final r = (annualRatePercent / 100.0) / paymentsPerYear;
    final factor = math.pow(1.0 + r, n);
    final pmt = principal * (r * factor) / (factor - 1.0);
    final totalPayment = pmt * n;
    final totalInterest = totalPayment - principal;

    return {
      'periodicPayment': pmt,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
    };
  }

  /// Mortgage
  static Map<String, dynamic> calculateMortgage({
    required double homePrice,
    required double downPaymentPercent,
    required double annualRatePercent,
    required double termYears,
    double annualPropertyTax = 0,
    double annualHomeInsurance = 0,
    double monthlyHoa = 0,
  }) {
    final loanAmount = homePrice * (1.0 - (downPaymentPercent / 100.0));
    final loanRes = calculateLoan(
      principal: loanAmount,
      annualRatePercent: annualRatePercent,
      termYears: termYears,
      paymentsPerYear: 12,
    );
    final monthlyPI = loanRes['periodicPayment'] as double;
    final monthlyTax = annualPropertyTax / 12.0;
    final monthlyInsurance = annualHomeInsurance / 12.0;
    final totalMonthly = monthlyPI + monthlyTax + monthlyInsurance + monthlyHoa;

    return {
      'loanAmount': loanAmount,
      'monthlyPrincipalAndInterest': monthlyPI,
      'monthlyTax': monthlyTax,
      'monthlyInsurance': monthlyInsurance,
      'totalMonthlyPayment': totalMonthly,
    };
  }

  /// Multi-mode Percentage
  static Map<String, dynamic> calculatePercentage({
    required String mode,
    required double val1,
    required double val2,
  }) {
    double res;
    switch (mode) {
      case 'percentOf':
        res = (val1 / 100.0) * val2;
        break;
      case 'isWhatPercent':
        res = val2 != 0 ? (val1 / val2) * 100.0 : double.nan;
        break;
      case 'percentageChange':
        res = val1 != 0 ? ((val2 - val1) / val1) * 100.0 : double.nan;
        break;
      case 'percentageDifference':
        final avg = (val1 + val2) / 2.0;
        res = avg != 0 ? ((val1 - val2).abs() / avg) * 100.0 : double.nan;
        break;
      case 'reversePercent':
        res = val2 / (1.0 + (val1 / 100.0));
        break;
      default:
        res = 0.0;
    }
    return {'result': res};
  }

  /// Profit Margin & Markup
  static Map<String, dynamic> calculateMarginMarkup({
    required double cost,
    required double revenue,
    String solveMode = 'fromCostAndRevenue',
  }) {
    final profit = revenue - cost;
    final marginPercent = revenue != 0 ? (profit / revenue) * 100.0 : 0.0;
    final markupPercent = cost != 0 ? (profit / cost) * 100.0 : 0.0;
    return {
      'profit': profit,
      'marginPercent': marginPercent,
      'markupPercent': markupPercent,
    };
  }

  /// Break-even
  static Map<String, dynamic> calculateBreakEven({
    required double fixedCosts,
    required double variableCostPerUnit,
    required double unitPrice,
  }) {
    final contributionMargin = unitPrice - variableCostPerUnit;
    final breakEvenUnits = contributionMargin > 0 ? fixedCosts / contributionMargin : 0.0;
    final breakEvenRevenue = breakEvenUnits * unitPrice;
    final contributionMarginRatio = unitPrice > 0 ? (contributionMargin / unitPrice) * 100.0 : 0.0;

    return {
      'contributionMargin': contributionMargin,
      'breakEvenUnits': breakEvenUnits,
      'breakEvenRevenue': breakEvenRevenue,
      'contributionMarginRatio': contributionMarginRatio,
    };
  }

  /// Discount and Sale
  static Map<String, dynamic> calculateDiscountAndSale({
    required double originalPrice,
    required double discountPercent,
    double taxPercent = 0,
  }) {
    final discountAmount = originalPrice * (discountPercent / 100.0);
    final salePrice = originalPrice - discountAmount;
    final taxAmount = salePrice * (taxPercent / 100.0);
    final finalPrice = salePrice + taxAmount;

    return {
      'discountAmount': discountAmount,
      'salePrice': salePrice,
      'taxAmount': taxAmount,
      'finalPrice': finalPrice,
    };
  }

  /// CAGR
  static Map<String, dynamic> calculateCagr({
    required double beginningValue,
    required double endingValue,
    required double years,
  }) {
    if (beginningValue <= 0 || years <= 0) {
      throw ArgumentError('Beginning value and years must be positive');
    }
    final cagr = (math.pow(endingValue / beginningValue, 1.0 / years) - 1.0) * 100.0;
    final totalGrowth = ((endingValue - beginningValue) / beginningValue) * 100.0;
    return {
      'cagrPercent': cagr,
      'totalGrowthPercent': totalGrowth,
    };
  }

  /// ROI
  static Map<String, dynamic> calculateRoi({
    required double totalCost,
    required double totalGain,
    required double investmentYears,
  }) {
    if (totalCost <= 0) throw ArgumentError('Total cost must be positive');
    final netReturn = totalGain - totalCost;
    final roiPercent = (netReturn / totalCost) * 100.0;
    final annualizedRoiPercent = investmentYears > 0
        ? (math.pow(totalGain / totalCost, 1.0 / investmentYears) - 1.0) * 100.0
        : roiPercent;

    return {
      'netReturn': netReturn,
      'roiPercent': roiPercent,
      'annualizedRoiPercent': annualizedRoiPercent,
    };
  }

  /// Tip and Split
  static Map<String, dynamic> calculateTipAndSplit({
    required double billAmount,
    required double tipPercent,
    int numberOfPeople = 1,
    double taxPercent = 0,
  }) {
    final tipAmount = (billAmount * tipPercent) / 100.0;
    final taxAmount = (billAmount * taxPercent) / 100.0;
    final totalBill = billAmount + tipAmount + taxAmount;
    final perPerson = numberOfPeople > 0 ? totalBill / numberOfPeople : totalBill;

    return {
      'tipAmount': tipAmount,
      'taxAmount': taxAmount,
      'totalBill': totalBill,
      'perPersonAmount': perPerson,
    };
  }

  /// Currency
  static Map<String, dynamic> convertCurrency({
    required double amount,
    required double sourceToTargetRate,
    String sourceCode = 'USD',
    String targetCode = 'EUR',
  }) {
    final converted = amount * sourceToTargetRate;
    final inverse = sourceToTargetRate != 0 ? 1.0 / sourceToTargetRate : 0.0;
    return {
      'convertedAmount': converted,
      'inverseRate': inverse,
    };
  }
}
