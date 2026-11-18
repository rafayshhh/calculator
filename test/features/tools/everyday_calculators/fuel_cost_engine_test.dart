import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/everyday_calculators/domain/everyday_engine.dart';

void main() {
  group('EverydayEngine - Fuel Cost', () {
    test('Calculates fuel cost with L/100km', () {
      final result = EverydayEngine.calculateFuelCost(
        distance: 500,
        efficiency: 8.5,
        fuelPrice: 1.5,
        isVolumePerDistance: true,
      );

      expect(result.fuelNeeded, closeTo(42.5, 0.01));
      expect(result.totalCost, closeTo(63.75, 0.01));
    });

    test('Calculates fuel cost with km/L', () {
      final result = EverydayEngine.calculateFuelCost(
        distance: 500,
        efficiency: 15,
        fuelPrice: 1.5,
        isVolumePerDistance: false,
      );

      expect(result.fuelNeeded, closeTo(33.333, 0.001));
      expect(result.totalCost, closeTo(50.0, 0.01));
    });

    test('Throws on negative distance', () {
      expect(
        () => EverydayEngine.calculateFuelCost(
          distance: -10,
          efficiency: 10,
          fuelPrice: 2.0,
          isVolumePerDistance: true,
        ),
        throwsArgumentError,
      );
    });
  });
}
