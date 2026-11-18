import 'conversion_category.dart';

typedef ConversionFunction = double Function(double value);

class UnitDefinition {
  final String id;
  final String name;
  final String symbol;
  final ConversionCategory category;

  /// Multiplier to convert THIS unit to the base unit.
  /// (e.g. if base is meter, kilometer factor is 1000.0).
  final double? baseConversionFactor;

  /// Explicit function to convert THIS unit to the base unit.
  final ConversionFunction? toBase;

  /// Explicit function to convert the base unit to THIS unit.
  final ConversionFunction? fromBase;

  /// List of alternative search terms and spellings.
  final List<String> aliases;

  /// Whether this unit physically or mathematically supports negative values.
  final bool supportsNegative;

  /// Optional SI prefix (e.g. 'kilo', 'milli', 'mega').
  final String? siPrefix;

  const UnitDefinition({
    required this.id,
    required this.name,
    required this.symbol,
    required this.category,
    this.baseConversionFactor,
    this.toBase,
    this.fromBase,
    this.aliases = const [],
    this.supportsNegative = false,
    this.siPrefix,
  }) : assert(
         (baseConversionFactor != null && toBase == null && fromBase == null) ||
             (baseConversionFactor == null &&
                 toBase != null &&
                 fromBase != null),
         'Provide either baseConversionFactor for linear units, or BOTH toBase and fromBase for non-linear units.',
       );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UnitDefinition($id, $symbol, $name)';
}
