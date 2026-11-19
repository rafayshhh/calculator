import 'conversion_category.dart';
import 'unit_definition.dart';
import '../data/unit_registry.dart';

class ConversionDetail {
  final double inputValue;
  final double outputValue;
  final String formulaDescription;
  final List<SiblingConversion> quickConversions;

  const ConversionDetail({
    double? result,
    String? formula,
    List<SiblingConversion>? siblings,
    double? inputValue,
    double? outputValue,
    String? formulaDescription,
    List<SiblingConversion>? quickConversions,
  })  : inputValue = inputValue ?? 0.0,
        outputValue = outputValue ?? result ?? 0.0,
        formulaDescription = formulaDescription ?? formula ?? '',
        quickConversions = quickConversions ?? siblings ?? const [];

  double get result => outputValue;
  String get formula => formulaDescription;
  List<SiblingConversion> get siblings => quickConversions;
  String get formattedOutput => UnitConverterEngine.formatResult(outputValue);
}

class SiblingConversion {
  final UnitDefinition unit;
  final double value;

  const SiblingConversion({
    required this.unit,
    required this.value,
  });
}

class UnitConverterEngine {
  UnitConverterEngine._();

  /// Converts a value from source unit to target unit
  static double convert({
    required double value,
    required UnitDefinition source,
    required UnitDefinition target,
  }) {
    if (source.category != target.category) {
      throw ArgumentError(
        'Cross category conversion is not supported: ${source.category.displayName} vs ${target.category.displayName}',
      );
    }

    if (value < 0 && !source.supportsNegative) {
      throw ArgumentError('Negative values not supported for unit: ${source.name}');
    }

    if (source.id == target.id) {
      return value;
    }

    if (value == 0 && source.category != ConversionCategory.temperature) {
      return 0.0;
    }

    // Convert source to base
    final double baseVal;
    if (source.toBase != null) {
      baseVal = source.toBase!(value);
    } else {
      baseVal = value * (source.baseConversionFactor ?? 1.0);
    }

    // Convert base to target
    final double targetVal;
    if (target.fromBase != null) {
      targetVal = target.fromBase!(baseVal);
    } else {
      targetVal = baseVal / (target.baseConversionFactor ?? 1.0);
    }

    return targetVal;
  }

  /// Returns detailed conversion result including mathematical formula and sibling units
  static ConversionDetail convertDetailed({
    required double value,
    required UnitDefinition source,
    required UnitDefinition target,
  }) {
    final res = convert(value: value, source: source, target: target);

    String formulaText;
    if (source.category == ConversionCategory.temperature) {
      formulaText = '${source.symbol} → ${target.symbol}';
    } else {
      final sFactor = source.baseConversionFactor ?? 1.0;
      final tFactor = target.baseConversionFactor ?? 1.0;
      final factor = sFactor / tFactor;
      formulaText = '1 ${source.symbol} = $factor ${target.symbol}';
    }

    final categoryUnits = UnitRegistry.getUnitsByCategory(source.category);
    final siblings = <SiblingConversion>[];
    for (final u in categoryUnits) {
      if (u.id != source.id && u.id != target.id) {
        try {
          final sibVal = convert(value: value, source: source, target: u);
          siblings.add(SiblingConversion(unit: u, value: sibVal));
        } catch (_) {}
      }
    }

    return ConversionDetail(
      inputValue: value,
      outputValue: res,
      formulaDescription: formulaText,
      quickConversions: siblings,
    );
  }

  static String formatResult(double val) {
    if (val.isNaN) return 'NaN';
    if (val.isInfinite) return val.isNegative ? '-Infinity' : 'Infinity';
    if (val == 0.0 || val == -0.0) return '0';
    if (val.abs() >= 1e12 || (val.abs() < 1e-6 && val.abs() > 0)) {
      return val.toStringAsExponential(6).replaceAll(RegExp(r'\.?0+e'), 'e');
    }
    String s = val.toStringAsFixed(8);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}
