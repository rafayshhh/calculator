import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/features/tools/unit_converter/domain/conversion_category.dart';
import 'package:calculator/features/tools/unit_converter/data/unit_registry.dart';
import 'package:calculator/features/tools/unit_converter/providers/unit_converter_provider.dart';

void main() {
  group('UnitConverter Swap Behavior', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Swap linear conversion (100 m -> ft -> swap -> m)', () {
      final notifier = container.read(unitConverterProvider.notifier);

      notifier.setCategory(ConversionCategory.length);
      final ft = UnitRegistry.findUnitById('l_ft');
      if (ft != null) notifier.setTargetUnit(ft);
      notifier.setInputValue('100');

      var state = container.read(unitConverterProvider);

      // 100 m to ft is approx 328.0839895
      final initialResult = state.resultValue;
      expect(state.sourceUnit.symbol, 'm');
      expect(state.targetUnit.symbol, 'ft');

      notifier.swapUnits();
      state = container.read(unitConverterProvider);

      expect(state.sourceUnit.symbol, 'ft');
      expect(state.targetUnit.symbol, 'm');

      // The new input value should be the old result value (unformatted)
      expect(state.inputValue, initialResult.replaceAll(',', ''));

      // Since it's a linear conversion, swapping back should yield approximately 100
      final resultNum =
          double.tryParse(state.resultValue.replaceAll(',', '')) ?? 0;
      expect(resultNum, closeTo(100.0, 0.0001));
    });

    test('Swap non-linear temperature conversion (0 C -> F -> swap -> C)', () {
      final notifier = container.read(unitConverterProvider.notifier);

      notifier.setCategory(ConversionCategory.temperature);
      notifier.setInputValue('0'); // 0 C = 32 F

      var state = container.read(unitConverterProvider);
      expect(state.sourceUnit.symbol, '°C');
      expect(state.targetUnit.symbol, '°F');
      expect(state.resultValue, '32');

      notifier.swapUnits();
      state = container.read(unitConverterProvider);

      expect(state.sourceUnit.symbol, '°F');
      expect(state.targetUnit.symbol, '°C');
      expect(state.inputValue, '32');
      expect(state.resultValue, '0');
    });

    test('Swap non-linear temperature conversion (32 F -> C -> swap -> F)', () {
      final notifier = container.read(unitConverterProvider.notifier);

      notifier.setCategory(ConversionCategory.temperature);

      // Ensure target is set up correctly for 32 F -> C
      final state1 = container.read(unitConverterProvider);
      notifier.setSourceUnit(state1.targetUnit);
      notifier.setTargetUnit(state1.sourceUnit);

      notifier.setInputValue('32'); // 32 F = 0 C

      var state = container.read(unitConverterProvider);
      expect(state.sourceUnit.symbol, '°F');
      expect(state.targetUnit.symbol, '°C');
      expect(state.resultValue, '0');

      notifier.swapUnits();
      state = container.read(unitConverterProvider);

      expect(state.sourceUnit.symbol, '°C');
      expect(state.targetUnit.symbol, '°F');
      expect(state.inputValue, '0');
      expect(state.resultValue, '32');
    });

    test('Swap empty values handles safely', () {
      final notifier = container.read(unitConverterProvider.notifier);

      notifier.setCategory(ConversionCategory.length);
      notifier.setInputValue('');

      var state = container.read(unitConverterProvider);
      expect(state.inputValue, isEmpty);
      expect(state.resultValue, isEmpty);

      notifier.swapUnits();
      state = container.read(unitConverterProvider);

      expect(state.inputValue, isEmpty);
      expect(state.resultValue, isEmpty);
    });
  });
}
