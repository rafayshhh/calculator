class DiscountResult {
  final double discountAmount;
  final double finalPrice;

  const DiscountResult({
    required this.discountAmount,
    required this.finalPrice,
  });
}

class FuelCostResult {
  final double fuelNeeded;
  final double totalCost;

  const FuelCostResult({
    required this.fuelNeeded,
    required this.totalCost,
  });
}

class EverydayEngine {
  EverydayEngine._();

  /// Calculates discount amount and final price
  static DiscountResult calculateDiscount(double price, double discountPercent) {
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    if (discountPercent < 0 || discountPercent > 100) {
      throw ArgumentError('Discount percentage must be between 0 and 100');
    }
    final discountAmount = (price * discountPercent) / 100.0;
    final finalPrice = price - discountAmount;
    return DiscountResult(
      discountAmount: discountAmount,
      finalPrice: finalPrice,
    );
  }

  /// Calculates fuel needed and total fuel cost
  static FuelCostResult calculateFuelCost({
    required double distance,
    required double efficiency,
    required double fuelPrice,
    required bool isVolumePerDistance,
  }) {
    if (distance < 0) {
      throw ArgumentError('Distance cannot be negative');
    }
    if (efficiency <= 0) {
      throw ArgumentError('Fuel efficiency must be positive');
    }
    if (fuelPrice < 0) {
      throw ArgumentError('Fuel price cannot be negative');
    }

    final double fuelNeeded = isVolumePerDistance
        ? (distance / 100.0) * efficiency
        : distance / efficiency;
    final double totalCost = fuelNeeded * fuelPrice;

    return FuelCostResult(
      fuelNeeded: fuelNeeded,
      totalCost: totalCost,
    );
  }

  /// What is P% of T?
  static double calculatePercentOf(double percent, double total) {
    return (percent / 100.0) * total;
  }

  /// Part is what percent of Whole?
  static double calculateIsWhatPercent(double part, double whole) {
    if (whole == 0) return double.nan;
    return (part / whole) * 100.0;
  }

  /// Percentage Change from Old to New
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return double.nan;
    return ((newValue - oldValue) / oldValue) * 100.0;
  }

  /// Percentage Difference between two values
  static double calculatePercentageDifference(double val1, double val2) {
    final denom = (val1 + val2) / 2.0;
    if (denom == 0) return double.nan;
    return ((val1 - val2).abs() / denom) * 100.0;
  }

  /// Tip and Bill Splitting
  static Map<String, double> calculateTip({
    required double billAmount,
    required double tipPercent,
    int splitCount = 1,
    double taxPercent = 0.0,
  }) {
    if (billAmount < 0) throw ArgumentError('Bill amount cannot be negative');
    if (tipPercent < 0) throw ArgumentError('Tip percent cannot be negative');
    if (splitCount <= 0) throw ArgumentError('Split count must be positive');

    final tipAmount = (billAmount * tipPercent) / 100.0;
    final taxAmount = (billAmount * taxPercent) / 100.0;
    final totalBill = billAmount + tipAmount + taxAmount;
    final perPerson = totalBill / splitCount;

    return {
      'tipAmount': tipAmount,
      'taxAmount': taxAmount,
      'totalBill': totalBill,
      'perPerson': perPerson,
    };
  }

  /// Unit price
  static double calculateUnitPrice({
    required double price,
    required double quantity,
  }) {
    if (quantity <= 0) throw ArgumentError('Quantity must be positive');
    if (price < 0) throw ArgumentError('Price cannot be negative');
    return price / quantity;
  }
}
