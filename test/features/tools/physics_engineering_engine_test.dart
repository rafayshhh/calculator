import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/physics/domain/physics_engine.dart';
import 'package:calculator/features/tools/engineering/domain/engineering_engine.dart';

void main() {
  group('PhysicsEngine', () {
    test('Calculates Force F = ma', () {
      expect(PhysicsEngine.calculateForce(10, 9.8), 98.0);
      expect(() => PhysicsEngine.calculateForce(-5, 10), throwsArgumentError);
    });

    test('Calculates Kinetic & Potential Energy', () {
      // KE = 0.5 * 2 * 3^2 = 9
      expect(PhysicsEngine.calculateKineticEnergy(2, 3), 9.0);
      // PE = 2 * 9.80665 * 10
      expect(
        PhysicsEngine.calculatePotentialEnergy(2, 10),
        closeTo(196.133, 0.001),
      );
    });

    test('Calculates Ohm\'s Law and Electrical Power', () {
      // V = I * R = 2 * 10 = 20
      expect(PhysicsEngine.calculateVoltage(2, 10), 20.0);
      expect(PhysicsEngine.calculateCurrent(20, 10), 2.0);
      expect(PhysicsEngine.calculateResistance(20, 2), 10.0);
      expect(PhysicsEngine.calculateElectricalPower(120, 2), 240.0);
    });

    test('Calculates Pressure and Density', () {
      expect(PhysicsEngine.calculatePressure(100, 2), 50.0);
      expect(PhysicsEngine.calculateDensity(100, 5), 20.0);
    });

    test('Calculates Wave Speed', () {
      expect(PhysicsEngine.calculateWaveSpeed(440, 0.77), closeTo(338.8, 0.01));
    });
  });

  group('EngineeringEngine', () {
    test('Calculates Torque with angle', () {
      expect(
        EngineeringEngine.calculateTorque(50, 0.5, angleDegrees: 90),
        25.0,
      );
    });

    test('Calculates Mechanical Advantage and Gear Ratio', () {
      expect(EngineeringEngine.calculateMechanicalAdvantage(500, 100), 5.0);
      expect(EngineeringEngine.calculateGearRatio(10, 40), 4.0);
    });

    test('Calculates Stress and Strain', () {
      expect(EngineeringEngine.calculateStress(1000, 0.05), 20000.0);
      expect(EngineeringEngine.calculateStrain(0.002, 1.0), 0.002);
    });
  });
}
