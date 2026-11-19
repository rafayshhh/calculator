class SmartFormatter {
  static String format(
    num value, {
    int precision = 8,
    bool thousandsSeparator = false,
  }) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-Infinity' : 'Infinity';

    if (value == value.roundToDouble() && value.abs() < 1e15) {
      final intVal = value.toInt();
      if (!thousandsSeparator) return intVal.toString();
      final str = intVal.toString();
      final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
      return str.replaceAll(regex, ',');
    }

    String formatted = value.toStringAsFixed(precision);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }
}
