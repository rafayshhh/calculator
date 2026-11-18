import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/tools/unit_converter/domain/unit_converter_engine.dart';
import 'package:calculator/features/tools/unit_converter/data/unit_registry.dart';

void main() {
  group('UnitConverterEngine - 15 Category Conversion Precision Tests', () {
    // 1. Length
    test('Length conversions: mm, cm, m, km, in, ft, yd, mi, nmi', () {
      final m = UnitRegistry.findUnitById('l_m')!;
      final km = UnitRegistry.findUnitById('l_km')!;
      final cm = UnitRegistry.findUnitById('l_cm')!;
      final mi = UnitRegistry.findUnitById('l_mi')!;
      final ft = UnitRegistry.findUnitById('l_ft')!;
      final inU = UnitRegistry.findUnitById('l_in')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: km, target: m),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: m, target: cm),
        100.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: mi, target: m),
        1609.344,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: ft, target: inU),
        12.0,
      );
    });

    // 2. Area
    test('Area conversions: m², cm², acre, ha, km²', () {
      final sqM = UnitRegistry.findUnitById('a_sqm')!;
      final sqCm = UnitRegistry.findUnitById('a_sqcm')!;
      final ha = UnitRegistry.findUnitById('a_ha')!;
      final sqKm = UnitRegistry.findUnitById('a_sqkm')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: sqM, target: sqCm),
        10000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: ha, target: sqM),
        10000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: sqKm, target: ha),
        100.0,
      );
    });

    // 3. Volume
    test('Volume conversions: L, mL, m³, gallon, cup, tsp, tbsp', () {
      final l = UnitRegistry.findUnitById('v_l')!;
      final ml = UnitRegistry.findUnitById('v_ml')!;
      final cuM = UnitRegistry.findUnitById('v_cum')!;
      final gal = UnitRegistry.findUnitById('v_gal')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: l, target: ml),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: cuM, target: l),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: gal, target: l),
        closeTo(3.78541, 0.001),
      );
    });

    // 4. Mass
    test('Mass conversions: kg, g, lb, oz, t, st', () {
      final kg = UnitRegistry.findUnitById('m_kg')!;
      final g = UnitRegistry.findUnitById('m_g')!;
      final lb = UnitRegistry.findUnitById('m_lb')!;
      final t = UnitRegistry.findUnitById('m_t')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: kg, target: g),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: t, target: kg),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: lb, target: kg),
        closeTo(0.45359237, 0.00001),
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: kg, target: lb),
        closeTo(2.20462, 0.001),
      );
    });

    // 5. Temperature
    test('Temperature conversions: Celsius, Fahrenheit, Kelvin', () {
      final c = UnitRegistry.findUnitById('temp_c')!;
      final f = UnitRegistry.findUnitById('temp_f')!;
      final k = UnitRegistry.findUnitById('temp_k')!;

      // 0 °C = 32 °F
      expect(UnitConverterEngine.convert(value: 0, source: c, target: f), 32.0);
      // 100 °C = 212 °F
      expect(
        UnitConverterEngine.convert(value: 100, source: c, target: f),
        212.0,
      );
      // 32 °F = 0 °C
      expect(UnitConverterEngine.convert(value: 32, source: f, target: c), 0.0);
      // 212 °F = 100 °C
      expect(
        UnitConverterEngine.convert(value: 212, source: f, target: c),
        100.0,
      );
      // 0 °C = 273.15 K
      expect(
        UnitConverterEngine.convert(value: 0, source: c, target: k),
        273.15,
      );
      // 273.15 K = 0 °C
      expect(
        UnitConverterEngine.convert(value: 273.15, source: k, target: c),
        0.0,
      );
      // -40 °C = -40 °F
      expect(
        UnitConverterEngine.convert(value: -40, source: c, target: f),
        -40.0,
      );
    });

    test('Temperature absolute zero validations', () {
      final c = UnitRegistry.findUnitById('temp_c')!;
      final k = UnitRegistry.findUnitById('temp_k')!;

      expect(
        () => UnitConverterEngine.convert(value: -1, source: k, target: c),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => UnitConverterEngine.convert(value: -300, source: c, target: k),
        throwsA(isA<ArgumentError>()),
      );
    });

    // 6. Time
    test('Time conversions: s, min, h, d, wk, mo, yr', () {
      final s = UnitRegistry.findUnitById('time_s')!;
      final min = UnitRegistry.findUnitById('time_min')!;
      final h = UnitRegistry.findUnitById('time_h')!;
      final d = UnitRegistry.findUnitById('time_d')!;

      expect(
        UnitConverterEngine.convert(value: 60, source: s, target: min),
        1.0,
      );
      expect(
        UnitConverterEngine.convert(value: 3600, source: s, target: h),
        1.0,
      );
      expect(UnitConverterEngine.convert(value: 24, source: h, target: d), 1.0);
    });

    // 7. Speed
    test('Speed conversions: m/s, km/h, mph, ft/s, kn', () {
      final ms = UnitRegistry.findUnitById('s_ms')!;
      final kmh = UnitRegistry.findUnitById('s_kmh')!;
      final mph = UnitRegistry.findUnitById('s_mph')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: ms, target: kmh),
        closeTo(3.6, 0.0001),
      );
      expect(
        UnitConverterEngine.convert(value: 3.6, source: kmh, target: ms),
        closeTo(1.0, 0.0001),
      );
      expect(
        UnitConverterEngine.convert(value: 60, source: mph, target: kmh),
        closeTo(96.5606, 0.01),
      );
    });

    // 8. Pressure
    test('Pressure conversions: Pa, kPa, bar, atm, psi, mmHg', () {
      final pa = UnitRegistry.findUnitById('p_pa')!;
      final kpa = UnitRegistry.findUnitById('p_kpa')!;
      final atm = UnitRegistry.findUnitById('p_atm')!;
      final psi = UnitRegistry.findUnitById('p_psi')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: atm, target: pa),
        101325.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1000, source: pa, target: kpa),
        1.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: atm, target: psi),
        closeTo(14.6959, 0.01),
      );
    });

    // 9. Energy
    test('Energy conversions: J, kJ, MJ, Wh, kWh, cal, kcal, BTU, eV', () {
      final j = UnitRegistry.findUnitById('e_j')!;
      final kj = UnitRegistry.findUnitById('e_kj')!;
      final kwh = UnitRegistry.findUnitById('e_kwh')!;
      final cal = UnitRegistry.findUnitById('e_cal')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: kwh, target: j),
        3600000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1000, source: j, target: kj),
        1.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: cal, target: j),
        4.184,
      );
    });

    // 10. Power
    test('Power conversions: W, kW, MW, GW, hp', () {
      final w = UnitRegistry.findUnitById('pw_w')!;
      final kw = UnitRegistry.findUnitById('pw_kw')!;
      final hp = UnitRegistry.findUnitById('pw_hp')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: kw, target: w),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: hp, target: w),
        closeTo(745.7, 0.1),
      );
    });

    // 11. Digital Storage
    test('Digital storage: Decimal vs Binary IEC distinction (KB vs KiB)', () {
      final b = UnitRegistry.findUnitById('d_b')!;
      final kb = UnitRegistry.findUnitById('d_kb')!;
      final kib = UnitRegistry.findUnitById('d_kib')!;
      final mb = UnitRegistry.findUnitById('d_mb')!;
      final mib = UnitRegistry.findUnitById('d_mib')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: kb, target: b),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: kib, target: b),
        1024.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: mb, target: b),
        1000000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: mib, target: b),
        1048576.0,
      );
    });

    // 12. Frequency
    test('Frequency conversions: Hz, kHz, MHz, GHz', () {
      final hz = UnitRegistry.findUnitById('f_hz')!;
      final mhz = UnitRegistry.findUnitById('f_mhz')!;
      final ghz = UnitRegistry.findUnitById('f_ghz')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: mhz, target: hz),
        1000000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: ghz, target: mhz),
        1000.0,
      );
    });

    // 13. Angle
    test('Angle conversions: rad, deg, grad', () {
      final rad = UnitRegistry.findUnitById('ang_rad')!;
      final deg = UnitRegistry.findUnitById('ang_deg')!;
      final grad = UnitRegistry.findUnitById('ang_grad')!;

      expect(
        UnitConverterEngine.convert(value: 180, source: deg, target: rad),
        closeTo(math.pi, 0.0001),
      );
      expect(
        UnitConverterEngine.convert(value: 200, source: grad, target: rad),
        closeTo(math.pi, 0.0001),
      );
      expect(
        UnitConverterEngine.convert(value: -90, source: deg, target: rad),
        closeTo(-math.pi / 2, 0.0001),
      );
    });

    // 14. Force
    test('Force conversions: N, kN, lbf, kgf', () {
      final n = UnitRegistry.findUnitById('frc_n')!;
      final kn = UnitRegistry.findUnitById('frc_kn')!;
      final lbf = UnitRegistry.findUnitById('frc_lbf')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: kn, target: n),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: lbf, target: n),
        closeTo(4.44822, 0.001),
      );
    });

    // 15. Torque
    test('Torque conversions: N·m, kN·m, lbf·ft, lbf·in', () {
      final nm = UnitRegistry.findUnitById('tq_nm')!;
      final knm = UnitRegistry.findUnitById('tq_knm')!;
      final lbfft = UnitRegistry.findUnitById('tq_lbfft')!;

      expect(
        UnitConverterEngine.convert(value: 1, source: knm, target: nm),
        1000.0,
      );
      expect(
        UnitConverterEngine.convert(value: 1, source: lbfft, target: nm),
        closeTo(1.3558, 0.001),
      );
    });
  });

  group('UnitConverterEngine - Edge Cases & Physical Bounds', () {
    test('Negative length, mass, volume, area throws ArgumentError', () {
      final m = UnitRegistry.findUnitById('l_m')!;
      final km = UnitRegistry.findUnitById('l_km')!;
      final kg = UnitRegistry.findUnitById('m_kg')!;
      final g = UnitRegistry.findUnitById('m_g')!;

      expect(
        () => UnitConverterEngine.convert(value: -5, source: m, target: km),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => UnitConverterEngine.convert(value: -10, source: kg, target: g),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Cross category conversion throws ArgumentError', () {
      final m = UnitRegistry.findUnitById('l_m')!;
      final kg = UnitRegistry.findUnitById('m_kg')!;

      expect(
        () => UnitConverterEngine.convert(value: 10, source: m, target: kg),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Same unit conversion returns exact value', () {
      final km = UnitRegistry.findUnitById('l_km')!;
      expect(
        UnitConverterEngine.convert(value: 42.5, source: km, target: km),
        42.5,
      );
    });

    test('Zero converts cleanly to zero', () {
      final m = UnitRegistry.findUnitById('l_m')!;
      final ft = UnitRegistry.findUnitById('l_ft')!;
      expect(UnitConverterEngine.convert(value: 0, source: m, target: ft), 0.0);
    });

    test('Detailed conversion returns formula and quick siblings', () {
      final km = UnitRegistry.findUnitById('l_km')!;
      final m = UnitRegistry.findUnitById('l_m')!;

      final res = UnitConverterEngine.convertDetailed(
        value: 5,
        source: km,
        target: m,
      );
      expect(res.inputValue, 5);
      expect(res.outputValue, 5000);
      expect(res.formattedOutput, '5000');
      expect(res.formulaDescription, contains('1 km = 1000 m'));
      expect(res.quickConversions.isNotEmpty, true);
    });

    test('Precision and clean formatting', () {
      expect(UnitConverterEngine.formatResult(0.3), '0.3');
      expect(UnitConverterEngine.formatResult(0.0), '0');
      expect(UnitConverterEngine.formatResult(1234567890123), contains('e'));
    });

    test('UnitRegistry search matches name, symbol, and aliases', () {
      final resultsKm = UnitRegistry.searchUnits('kilometer');
      expect(resultsKm.any((u) => u.symbol == 'km'), true);

      final resultsPsi = UnitRegistry.searchUnits('psi');
      expect(resultsPsi.any((u) => u.id == 'p_psi'), true);

      final resultsKib = UnitRegistry.searchUnits('kib');
      expect(resultsKib.any((u) => u.symbol == 'KiB'), true);
    });
  });
}
