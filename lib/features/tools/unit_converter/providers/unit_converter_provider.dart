import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/conversion_category.dart';
import '../domain/unit_definition.dart';
import '../data/unit_registry.dart';
import '../domain/unit_converter_engine.dart';

class UnitConverterState {
  final ConversionCategory category;
  final UnitDefinition sourceUnit;
  final UnitDefinition targetUnit;
  final String inputValue;
  final String resultValue;
  final String? formula;
  final String? errorMessage;

  const UnitConverterState({
    required this.category,
    required this.sourceUnit,
    required this.targetUnit,
    required this.inputValue,
    required this.resultValue,
    this.formula,
    this.errorMessage,
  });

  UnitConverterState copyWith({
    ConversionCategory? category,
    UnitDefinition? sourceUnit,
    UnitDefinition? targetUnit,
    String? inputValue,
    String? resultValue,
    String? formula,
    String? errorMessage,
  }) {
    return UnitConverterState(
      category: category ?? this.category,
      sourceUnit: sourceUnit ?? this.sourceUnit,
      targetUnit: targetUnit ?? this.targetUnit,
      inputValue: inputValue ?? this.inputValue,
      resultValue: resultValue ?? this.resultValue,
      formula: formula ?? this.formula,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UnitConverterNotifier extends Notifier<UnitConverterState> {
  @override
  UnitConverterState build() {
    final defaultCat = ConversionCategory.length;
    final units = UnitRegistry.getUnitsByCategory(defaultCat);
    final source = units.isNotEmpty ? units[0] : UnitRegistry.allUnits[0];
    final target = units.length > 1 ? units[1] : source;

    return UnitConverterState(
      category: defaultCat,
      sourceUnit: source,
      targetUnit: target,
      inputValue: '1',
      resultValue: '1',
    );
  }

  void setCategory(ConversionCategory category) {
    final units = UnitRegistry.getUnitsByCategory(category);
    if (units.isEmpty) return;
    final source = units[0];
    final target = units.length > 1 ? units[1] : source;

    state = state.copyWith(
      category: category,
      sourceUnit: source,
      targetUnit: target,
    );
    _recalculate();
  }

  void setInputValue(String value) {
    state = state.copyWith(inputValue: value);
    _recalculate();
  }

  void setSourceUnit(UnitDefinition unit) {
    state = state.copyWith(sourceUnit: unit);
    _recalculate();
  }

  void setTargetUnit(UnitDefinition unit) {
    state = state.copyWith(targetUnit: unit);
    _recalculate();
  }

  void swapUnits() {
    final oldSource = state.sourceUnit;
    final oldTarget = state.targetUnit;
    final newInputValue = state.resultValue.replaceAll(',', '');

    state = state.copyWith(
      sourceUnit: oldTarget,
      targetUnit: oldSource,
      inputValue: newInputValue,
    );
    _recalculate();
  }

  void _recalculate() {
    final cleanInput = state.inputValue.replaceAll(',', '').trim();
    if (cleanInput.isEmpty) {
      state = state.copyWith(resultValue: '', formula: null, errorMessage: null);
      return;
    }

    final val = double.tryParse(cleanInput);
    if (val == null) {
      state = state.copyWith(
        resultValue: '',
        errorMessage: 'Invalid number format',
      );
      return;
    }

    try {
      final res = UnitConverterEngine.convert(
        value: val,
        source: state.sourceUnit,
        target: state.targetUnit,
      );

      // Clean formatted representation
      String formatted;
      if (res % 1 == 0 && res.abs() < 1e12) {
        formatted = res.toInt().toString();
      } else {
        formatted = res.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
      }

      state = state.copyWith(
        resultValue: formatted,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        resultValue: '',
        errorMessage: e.toString().replaceAll('ArgumentError: ', ''),
      );
    }
  }
}

final unitConverterProvider =
    NotifierProvider<UnitConverterNotifier, UnitConverterState>(
      UnitConverterNotifier.new,
    );
