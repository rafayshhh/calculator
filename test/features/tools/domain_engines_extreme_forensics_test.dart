import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/physics/domain/physics_engine.dart';
import 'package:calculator/features/tools/engineering/domain/engineering_engine.dart';
import 'package:calculator/features/tools/chemistry/domain/chemistry_engine.dart';
import 'package:calculator/features/tools/unit_converter/domain/unit_converter_engine.dart';
import 'package:calculator/features/tools/unit_converter/domain/conversion_category.dart';
import 'package:calculator/features/tools/unit_converter/data/unit_registry.dart';
import 'package:calculator/features/tools/finance/domain/finance_engine.dart';

void main() {
  group('Domain Engines Forensic & Extreme Boundary Tests', () {
    // ----------------------------------------------------
    // 1. Physics Engine Forward/Inverse Symmetry & Extremes
    // ----------------------------------------------------
    group('Physics Engine Symmetries & Scale Invariance', () {
      test('Force (F = ma) forward and inverse consistency across scales', () {
        final scales = [1e-12, 1e-6, 1.0, 100.0, 1e6, 1e12];
        for (final m in scales) {
          for (final a in scales) {
            final f = PhysicsEngine.calculateForce(m, a);
            final derivedM = PhysicsEngine.calculateMassFromForce(f, a);
            final derivedA = PhysicsEngine.calculateAccelerationFromForce(f, m);
            expect(
              (derivedM - m).abs() / m < 1e-9,
              isTrue,
              reason: 'Failed mass inversion at scale m=$m, a=$a',
            );
            expect(
              (derivedA - a).abs() / a < 1e-9,
              isTrue,
              reason: 'Failed accel inversion at scale m=$m, a=$a',
            );
          }
        }
      });

      test('Ohm\'s Law (V = IR) forward and inverse consistency', () {
        const current = 0.025; // 25 mA
        const resistance = 4700.0; // 4.7 kΩ
        final v = PhysicsEngine.calculateVoltage(current, resistance);
        expect(v, closeTo(117.5, 1e-6));
        expect(
          PhysicsEngine.calculateCurrent(v, resistance),
          closeTo(current, 1e-6),
        );
        expect(
          PhysicsEngine.calculateResistance(v, current),
          closeTo(resistance, 1e-6),
        );
      });

      test('Wave equation (v = fλ) inversion across audio and RF spectrum', () {
        // Sound in air at 440 Hz (A4)
        const speed = 343.2;
        const freq = 440.0;
        final wavelength = PhysicsEngine.calculateWavelength(speed, freq);
        expect(
          PhysicsEngine.calculateWaveSpeed(freq, wavelength),
          closeTo(speed, 1e-6),
        );
        expect(
          PhysicsEngine.calculateFrequency(speed, wavelength),
          closeTo(freq, 1e-6),
        );
      });

      test('Density (ρ = m/V) boundary validation against negative and zero volume', () {
        expect(
          () => PhysicsEngine.calculateDensity(10, 0),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => PhysicsEngine.calculateDensity(10, -5),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => PhysicsEngine.calculateDensity(-10, 5),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // ----------------------------------------------------
    // 2. Engineering Engine Symmetries
    // ----------------------------------------------------
    group('Engineering Engine Symmetries & Safety Boundaries', () {
      test('Torque (τ = F·r) forward and inverse consistency', () {
        const f = 250.0; // N
        const r = 0.45; // m
        final torque = EngineeringEngine.calculateTorque(f, r);
        expect(torque, closeTo(112.5, 1e-6));
        expect(
          EngineeringEngine.calculateForceFromTorque(torque, r),
          closeTo(f, 1e-6),
        );
        expect(
          EngineeringEngine.calculateRadiusFromTorque(torque, f),
          closeTo(r, 1e-6),
        );
      });

      test('Hooke\'s Law (F = kx) inversion', () {
        const k = 1500.0; // N/m
        const x = 0.08; // 8 cm
        final f = EngineeringEngine.calculateSpringForce(k, x);
        expect(f, closeTo(120.0, 1e-6));
        expect(
          EngineeringEngine.calculateSpringConstant(f, x),
          closeTo(k, 1e-6),
        );
        expect(
          EngineeringEngine.calculateSpringDisplacement(f, k),
          closeTo(x, 1e-6),
        );
      });

      test('Stress and Strain Hookean elasticity (E = σ / ε)', () {
        const stress = 200e6; // 200 MPa
        const strain = 0.001; // 0.1% elongation
        final e = EngineeringEngine.calculateYoungsModulus(stress, strain);
        expect(e, closeTo(200e9, 1.0)); // 200 GPa (Structural Steel)
      });
    });

    // ----------------------------------------------------
    // 3. Chemistry Engine Dilution and Gas Law Invariance
    // ----------------------------------------------------
    group('Chemistry Engine Invariance & Gas Laws', () {
      test('Dilution (M1V1 = M2V2) conservation of solute moles', () {
        const m1 = 12.0; // 12 M HCl stock
        const v2 = 500.0; // 500 mL target
        const m2 = 0.5; // 0.5 M working solution
        final v1 = ChemistryEngine.calculateDilutionV1(m1, m2, v2);
        // M1 * V1 must equal M2 * V2
        expect(m1 * v1, closeTo(m2 * v2, 1e-6));
      });

      test(
        'Ideal Gas Law (PV = nRT) at Standard Temperature & Pressure (STP)',
        () {
          // 1 mole of ideal gas at STP (101.325 kPa, 273.15 K) should be approx 22.414 L
          const p = 101.325; // kPa
          const n = 1.0; // mol
          const t = 273.15; // K
          final v = ChemistryEngine.calculateIdealGasVolume(p, n, t);
          expect(v, closeTo(22.414, 0.05));
        },
      );

      test('pH and pOH aqueous equilibrium at 25°C', () {
        const ph = 3.5;
        final poh = ChemistryEngine.calculatePohFromPh(ph);
        expect(ph + poh, closeTo(14.0, 1e-6));
        final hConc = ChemistryEngine.calculateHFromPh(ph);
        expect(hConc, closeTo(math.pow(10, -3.5).toDouble(), 1e-9));
      });
    });

    // ----------------------------------------------------
    // 4. Finance Engine Calculations
    // ----------------------------------------------------
    group('Finance Engine Forward and Inverse Calculations', () {
      test('Compound Interest forward calculation matches exact formula', () {
        const p = 10000.0;
        const r = 0.06; // 6%
        const n = 12; // monthly
        const t = 5.0; // 5 years
        final res = FinanceEngine.calculateCompoundInterest(
          principal: p,
          annualRatePercent: r * 100,
          compoundsPerYear: n,
          timeYears: t,
        );
        // Formula: P * (1 + r/n)^(n*t) = 10000 * (1 + 0.06/12)^60 = 13488.5015
        expect(res['futureValue'], closeTo(13488.50, 0.05));
        expect(res['totalInterest'], closeTo(3488.50, 0.05));
      });

      test('Profit Margin vs Markup consistency', () {
        const cost = 80.0;
        const revenue = 100.0;
        final res = FinanceEngine.calculateMarginMarkup(
          cost: cost,
          revenue: revenue,
        );
        expect(res['marginPercent'], closeTo(20.0, 1e-6)); // 20 / 100 = 20%
        expect(res['markupPercent'], closeTo(25.0, 1e-6)); // 20 / 80 = 25%
      });
    });

    // ----------------------------------------------------
    // 5. Unit Conversion Round-Trip Symmetries
    // ----------------------------------------------------
    group('Unit Conversion Round-Trip Precision', () {
      test('All supported categories maintain strict round-trip accuracy (A → B → A)', () {
        for (final category in ConversionCategory.values) {
          final units = UnitRegistry.getUnitsByCategory(category);
          for (int i = 0; i < units.length - 1; i++) {
            final u1 = units[i];
            final u2 = units[i + 1];
            const originalVal = 42.5;

            final converted = UnitConverterEngine.convert(
              value: originalVal,
              source: u1,
              target: u2,
            );

            final roundTripped = UnitConverterEngine.convert(
              value: converted,
              source: u2,
              target: u1,
            );

            expect(
              (roundTripped - originalVal).abs() < 1e-4,
              isTrue,
              reason:
                  'Round trip failed for category ${category.name} between ${u1.id} and ${u2.id}',
            );
          }
        }
      });
    });
  });
}
