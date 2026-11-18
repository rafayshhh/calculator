import 'conversion_category.dart';
import 'unit_definition.dart';
import '../data/unit_registry.dart';

class ConversionDetail {
  final double result;
  final String formula;
  final List<SiblingConversion> siblings;

  const ConversionDetail({
    required this.result,
    required this.formula,
    required this.siblings,
  });
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
      result: res,
      formula: formulaText,
      siblings: siblings,
    );
  }
}
