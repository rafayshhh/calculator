import 'dart:math' as math;
import '../domain/conversion_category.dart';
import '../domain/unit_definition.dart';

class UnitRegistry {
  UnitRegistry._();

  static final List<UnitDefinition> allUnits = [
    // 1. Length
    const UnitDefinition(id: 'l_m', name: 'Meter', symbol: 'm', category: ConversionCategory.length, baseConversionFactor: 1.0, aliases: ['meter', 'metre', 'm']),
    const UnitDefinition(id: 'l_km', name: 'Kilometer', symbol: 'km', category: ConversionCategory.length, baseConversionFactor: 1000.0, aliases: ['kilometer', 'kilometre', 'km']),
    const UnitDefinition(id: 'l_cm', name: 'Centimeter', symbol: 'cm', category: ConversionCategory.length, baseConversionFactor: 0.01, aliases: ['centimeter', 'centimetre', 'cm']),
    const UnitDefinition(id: 'l_mm', name: 'Millimeter', symbol: 'mm', category: ConversionCategory.length, baseConversionFactor: 0.001, aliases: ['millimeter', 'millimetre', 'mm']),
    const UnitDefinition(id: 'l_in', name: 'Inch', symbol: 'in', category: ConversionCategory.length, baseConversionFactor: 0.0254, aliases: ['inch', 'inches', 'in']),
    const UnitDefinition(id: 'l_ft', name: 'Foot', symbol: 'ft', category: ConversionCategory.length, baseConversionFactor: 0.3048, aliases: ['foot', 'feet', 'ft']),
    const UnitDefinition(id: 'l_yd', name: 'Yard', symbol: 'yd', category: ConversionCategory.length, baseConversionFactor: 0.9144, aliases: ['yard', 'yards', 'yd']),
    const UnitDefinition(id: 'l_mi', name: 'Mile', symbol: 'mi', category: ConversionCategory.length, baseConversionFactor: 1609.344, aliases: ['mile', 'miles', 'mi']),
    const UnitDefinition(id: 'l_nmi', name: 'Nautical Mile', symbol: 'nmi', category: ConversionCategory.length, baseConversionFactor: 1852.0, aliases: ['nautical mile', 'nmi']),

    // 2. Area
    const UnitDefinition(id: 'a_sqm', name: 'Square Meter', symbol: 'm²', category: ConversionCategory.area, baseConversionFactor: 1.0, aliases: ['square meter', 'm2']),
    const UnitDefinition(id: 'a_sqcm', name: 'Square Centimeter', symbol: 'cm²', category: ConversionCategory.area, baseConversionFactor: 0.0001, aliases: ['square centimeter', 'cm2']),
    const UnitDefinition(id: 'a_ha', name: 'Hectare', symbol: 'ha', category: ConversionCategory.area, baseConversionFactor: 10000.0, aliases: ['hectare', 'ha']),
    const UnitDefinition(id: 'a_sqkm', name: 'Square Kilometer', symbol: 'km²', category: ConversionCategory.area, baseConversionFactor: 1000000.0, aliases: ['square kilometer', 'km2']),
    const UnitDefinition(id: 'a_acre', name: 'Acre', symbol: 'acre', category: ConversionCategory.area, baseConversionFactor: 4046.8564224, aliases: ['acre', 'acres']),

    // 3. Volume
    const UnitDefinition(id: 'v_l', name: 'Liter', symbol: 'L', category: ConversionCategory.volume, baseConversionFactor: 1.0, aliases: ['liter', 'litre', 'l']),
    const UnitDefinition(id: 'v_ml', name: 'Milliliter', symbol: 'mL', category: ConversionCategory.volume, baseConversionFactor: 0.001, aliases: ['milliliter', 'millilitre', 'ml']),
    const UnitDefinition(id: 'v_cum', name: 'Cubic Meter', symbol: 'm³', category: ConversionCategory.volume, baseConversionFactor: 1000.0, aliases: ['cubic meter', 'm3']),
    const UnitDefinition(id: 'v_gal', name: 'US Gallon', symbol: 'gal', category: ConversionCategory.volume, baseConversionFactor: 3.785411784, aliases: ['gallon', 'gal']),
    const UnitDefinition(id: 'v_cup', name: 'US Cup', symbol: 'cup', category: ConversionCategory.volume, baseConversionFactor: 0.2365882365, aliases: ['cup', 'cups']),
    const UnitDefinition(id: 'v_tbsp', name: 'Tablespoon', symbol: 'tbsp', category: ConversionCategory.volume, baseConversionFactor: 0.01478676478, aliases: ['tablespoon', 'tbsp']),
    const UnitDefinition(id: 'v_tsp', name: 'Teaspoon', symbol: 'tsp', category: ConversionCategory.volume, baseConversionFactor: 0.00492892159, aliases: ['teaspoon', 'tsp']),

    // 4. Mass
    const UnitDefinition(id: 'm_kg', name: 'Kilogram', symbol: 'kg', category: ConversionCategory.mass, baseConversionFactor: 1.0, aliases: ['kilogram', 'kg', 'kilo']),
    const UnitDefinition(id: 'm_g', name: 'Gram', symbol: 'g', category: ConversionCategory.mass, baseConversionFactor: 0.001, aliases: ['gram', 'g']),
    const UnitDefinition(id: 'm_lb', name: 'Pound', symbol: 'lb', category: ConversionCategory.mass, baseConversionFactor: 0.45359237, aliases: ['pound', 'lbs', 'lb']),
    const UnitDefinition(id: 'm_oz', name: 'Ounce', symbol: 'oz', category: ConversionCategory.mass, baseConversionFactor: 0.028349523125, aliases: ['ounce', 'oz']),
    const UnitDefinition(id: 'm_t', name: 'Metric Ton', symbol: 't', category: ConversionCategory.mass, baseConversionFactor: 1000.0, aliases: ['ton', 'tonne', 't']),
    const UnitDefinition(id: 'm_st', name: 'Stone', symbol: 'st', category: ConversionCategory.mass, baseConversionFactor: 6.35029318, aliases: ['stone', 'st']),

    // 5. Temperature
    UnitDefinition(
      id: 'temp_c',
      name: 'Celsius',
      symbol: '°C',
      category: ConversionCategory.temperature,
      toBase: (v) => v,
      fromBase: (v) => v,
      aliases: const ['celsius', 'centigrade', 'c'],
      supportsNegative: true,
    ),
    UnitDefinition(
      id: 'temp_f',
      name: 'Fahrenheit',
      symbol: '°F',
      category: ConversionCategory.temperature,
      toBase: (v) => (v - 32.0) * 5.0 / 9.0,
      fromBase: (v) => (v * 9.0 / 5.0) + 32.0,
      aliases: const ['fahrenheit', 'f'],
      supportsNegative: true,
    ),
    UnitDefinition(
      id: 'temp_k',
      name: 'Kelvin',
      symbol: 'K',
      category: ConversionCategory.temperature,
      toBase: (v) => v - 273.15,
      fromBase: (v) => v + 273.15,
      aliases: const ['kelvin', 'k'],
      supportsNegative: true,
    ),

    // 6. Time
    const UnitDefinition(id: 't_s', name: 'Second', symbol: 's', category: ConversionCategory.time, baseConversionFactor: 1.0, aliases: ['second', 'sec', 's']),
    const UnitDefinition(id: 't_min', name: 'Minute', symbol: 'min', category: ConversionCategory.time, baseConversionFactor: 60.0, aliases: ['minute', 'min']),
    const UnitDefinition(id: 't_h', name: 'Hour', symbol: 'h', category: ConversionCategory.time, baseConversionFactor: 3600.0, aliases: ['hour', 'hr', 'h']),
    const UnitDefinition(id: 't_d', name: 'Day', symbol: 'd', category: ConversionCategory.time, baseConversionFactor: 86400.0, aliases: ['day', 'days', 'd']),
    const UnitDefinition(id: 't_wk', name: 'Week', symbol: 'wk', category: ConversionCategory.time, baseConversionFactor: 604800.0, aliases: ['week', 'weeks', 'wk']),
    const UnitDefinition(id: 't_mo', name: 'Month (30 d)', symbol: 'mo', category: ConversionCategory.time, baseConversionFactor: 2592000.0, aliases: ['month', 'mo']),
    const UnitDefinition(id: 't_yr', name: 'Year (365 d)', symbol: 'yr', category: ConversionCategory.time, baseConversionFactor: 31536000.0, aliases: ['year', 'yr']),

    // 7. Speed
    const UnitDefinition(id: 's_mps', name: 'Meter per second', symbol: 'm/s', category: ConversionCategory.speed, baseConversionFactor: 1.0, aliases: ['m/s', 'mps']),
    const UnitDefinition(id: 's_kmh', name: 'Kilometer per hour', symbol: 'km/h', category: ConversionCategory.speed, baseConversionFactor: 1.0 / 3.6, aliases: ['km/h', 'kmh', 'kph']),
    const UnitDefinition(id: 's_mph', name: 'Mile per hour', symbol: 'mph', category: ConversionCategory.speed, baseConversionFactor: 0.44704, aliases: ['mph']),
    const UnitDefinition(id: 's_fps', name: 'Foot per second', symbol: 'ft/s', category: ConversionCategory.speed, baseConversionFactor: 0.3048, aliases: ['ft/s', 'fps']),
    const UnitDefinition(id: 's_kn', name: 'Knot', symbol: 'kn', category: ConversionCategory.speed, baseConversionFactor: 1852.0 / 3600.0, aliases: ['knot', 'knots', 'kn']),

    // 8. Pressure
    const UnitDefinition(id: 'p_pa', name: 'Pascal', symbol: 'Pa', category: ConversionCategory.pressure, baseConversionFactor: 1.0, aliases: ['pascal', 'pa']),
    const UnitDefinition(id: 'p_kpa', name: 'Kilopascal', symbol: 'kPa', category: ConversionCategory.pressure, baseConversionFactor: 1000.0, aliases: ['kilopascal', 'kpa']),
    const UnitDefinition(id: 'p_bar', name: 'Bar', symbol: 'bar', category: ConversionCategory.pressure, baseConversionFactor: 100000.0, aliases: ['bar']),
    const UnitDefinition(id: 'p_atm', name: 'Atmosphere', symbol: 'atm', category: ConversionCategory.pressure, baseConversionFactor: 101325.0, aliases: ['atmosphere', 'atm']),
    const UnitDefinition(id: 'p_psi', name: 'Pounds per square inch', symbol: 'psi', category: ConversionCategory.pressure, baseConversionFactor: 6894.757293168, aliases: ['psi']),
    const UnitDefinition(id: 'p_mmhg', name: 'Millimeter of mercury', symbol: 'mmHg', category: ConversionCategory.pressure, baseConversionFactor: 133.322387415, aliases: ['mmhg', 'torr']),

    // 9. Energy
    const UnitDefinition(id: 'e_j', name: 'Joule', symbol: 'J', category: ConversionCategory.energy, baseConversionFactor: 1.0, aliases: ['joule', 'j']),
    const UnitDefinition(id: 'e_kj', name: 'Kilojoule', symbol: 'kJ', category: ConversionCategory.energy, baseConversionFactor: 1000.0, aliases: ['kilojoule', 'kj']),
    const UnitDefinition(id: 'e_mj', name: 'Megajoule', symbol: 'MJ', category: ConversionCategory.energy, baseConversionFactor: 1000000.0, aliases: ['megajoule', 'mj']),
    const UnitDefinition(id: 'e_wh', name: 'Watt-hour', symbol: 'Wh', category: ConversionCategory.energy, baseConversionFactor: 3600.0, aliases: ['watt-hour', 'wh']),
    const UnitDefinition(id: 'e_kwh', name: 'Kilowatt-hour', symbol: 'kWh', category: ConversionCategory.energy, baseConversionFactor: 3600000.0, aliases: ['kilowatt-hour', 'kwh']),
    const UnitDefinition(id: 'e_cal', name: 'Calorie', symbol: 'cal', category: ConversionCategory.energy, baseConversionFactor: 4.184, aliases: ['calorie', 'cal']),
    const UnitDefinition(id: 'e_kcal', name: 'Kilocalorie', symbol: 'kcal', category: ConversionCategory.energy, baseConversionFactor: 4184.0, aliases: ['kilocalorie', 'kcal']),
    const UnitDefinition(id: 'e_btu', name: 'British Thermal Unit', symbol: 'BTU', category: ConversionCategory.energy, baseConversionFactor: 1055.05585262, aliases: ['btu']),
    const UnitDefinition(id: 'e_ev', name: 'Electronvolt', symbol: 'eV', category: ConversionCategory.energy, baseConversionFactor: 1.602176634e-19, aliases: ['electronvolt', 'ev']),

    // 10. Power
    const UnitDefinition(id: 'pow_w', name: 'Watt', symbol: 'W', category: ConversionCategory.power, baseConversionFactor: 1.0, aliases: ['watt', 'w']),
    const UnitDefinition(id: 'pow_kw', name: 'Kilowatt', symbol: 'kW', category: ConversionCategory.power, baseConversionFactor: 1000.0, aliases: ['kilowatt', 'kw']),
    const UnitDefinition(id: 'pow_mw', name: 'Megawatt', symbol: 'MW', category: ConversionCategory.power, baseConversionFactor: 1000000.0, aliases: ['megawatt', 'mw']),
    const UnitDefinition(id: 'pow_gw', name: 'Gigawatt', symbol: 'GW', category: ConversionCategory.power, baseConversionFactor: 1000000000.0, aliases: ['gigawatt', 'gw']),
    const UnitDefinition(id: 'pow_hp', name: 'Horsepower', symbol: 'hp', category: ConversionCategory.power, baseConversionFactor: 745.6998715822702, aliases: ['horsepower', 'hp']),

    // 11. Digital Storage
    const UnitDefinition(id: 'ds_b', name: 'Byte', symbol: 'B', category: ConversionCategory.digitalStorage, baseConversionFactor: 1.0, aliases: ['byte', 'b']),
    const UnitDefinition(id: 'ds_kb', name: 'Kilobyte', symbol: 'KB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1000.0, aliases: ['kilobyte', 'kb']),
    const UnitDefinition(id: 'ds_kib', name: 'Kibibyte', symbol: 'KiB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1024.0, aliases: ['kibibyte', 'kib']),
    const UnitDefinition(id: 'ds_mb', name: 'Megabyte', symbol: 'MB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1000000.0, aliases: ['megabyte', 'mb']),
    const UnitDefinition(id: 'ds_mib', name: 'Mebibyte', symbol: 'MiB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1048576.0, aliases: ['mebibyte', 'mib']),
    const UnitDefinition(id: 'ds_gb', name: 'Gigabyte', symbol: 'GB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1000000000.0, aliases: ['gigabyte', 'gb']),
    const UnitDefinition(id: 'ds_gib', name: 'Gibibyte', symbol: 'GiB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1073741824.0, aliases: ['gibibyte', 'gib']),
    const UnitDefinition(id: 'ds_tb', name: 'Terabyte', symbol: 'TB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1000000000000.0, aliases: ['terabyte', 'tb']),
    const UnitDefinition(id: 'ds_tib', name: 'Tebibyte', symbol: 'TiB', category: ConversionCategory.digitalStorage, baseConversionFactor: 1099511627776.0, aliases: ['tebibyte', 'tib']),

    // 12. Frequency
    const UnitDefinition(id: 'freq_hz', name: 'Hertz', symbol: 'Hz', category: ConversionCategory.frequency, baseConversionFactor: 1.0, aliases: ['hertz', 'hz']),
    const UnitDefinition(id: 'freq_khz', name: 'Kilohertz', symbol: 'kHz', category: ConversionCategory.frequency, baseConversionFactor: 1000.0, aliases: ['kilohertz', 'khz']),
    const UnitDefinition(id: 'freq_mhz', name: 'Megahertz', symbol: 'MHz', category: ConversionCategory.frequency, baseConversionFactor: 1000000.0, aliases: ['megahertz', 'mhz']),
    const UnitDefinition(id: 'freq_ghz', name: 'Gigahertz', symbol: 'GHz', category: ConversionCategory.frequency, baseConversionFactor: 1000000000.0, aliases: ['gigahertz', 'ghz']),

    // 13. Angle
    const UnitDefinition(id: 'ang_rad', name: 'Radian', symbol: 'rad', category: ConversionCategory.angle, baseConversionFactor: 1.0, aliases: ['radian', 'rad'], supportsNegative: true),
    const UnitDefinition(id: 'ang_deg', name: 'Degree', symbol: 'deg', category: ConversionCategory.angle, baseConversionFactor: math.pi / 180.0, aliases: ['degree', 'degrees', 'deg'], supportsNegative: true),
    const UnitDefinition(id: 'ang_grad', name: 'Gradian', symbol: 'grad', category: ConversionCategory.angle, baseConversionFactor: math.pi / 200.0, aliases: ['gradian', 'grad'], supportsNegative: true),

    // 14. Force
    const UnitDefinition(id: 'f_n', name: 'Newton', symbol: 'N', category: ConversionCategory.force, baseConversionFactor: 1.0, aliases: ['newton', 'n']),
    const UnitDefinition(id: 'f_kn', name: 'Kilonewton', symbol: 'kN', category: ConversionCategory.force, baseConversionFactor: 1000.0, aliases: ['kilonewton', 'kn']),
    const UnitDefinition(id: 'f_lbf', name: 'Pound-force', symbol: 'lbf', category: ConversionCategory.force, baseConversionFactor: 4.4482216152605, aliases: ['pound-force', 'lbf']),
    const UnitDefinition(id: 'f_kgf', name: 'Kilogram-force', symbol: 'kgf', category: ConversionCategory.force, baseConversionFactor: 9.80665, aliases: ['kilogram-force', 'kgf']),

    // 15. Torque
    const UnitDefinition(id: 'tq_nm', name: 'Newton-meter', symbol: 'N·m', category: ConversionCategory.torque, baseConversionFactor: 1.0, aliases: ['newton-meter', 'nm']),
    const UnitDefinition(id: 'tq_knm', name: 'Kilonewton-meter', symbol: 'kN·m', category: ConversionCategory.torque, baseConversionFactor: 1000.0, aliases: ['kilonewton-meter', 'knm']),
    const UnitDefinition(id: 'tq_lbfft', name: 'Pound-foot', symbol: 'lbf·ft', category: ConversionCategory.torque, baseConversionFactor: 1.3558179483314004, aliases: ['pound-foot', 'lbfft']),
    const UnitDefinition(id: 'tq_lbfin', name: 'Pound-inch', symbol: 'lbf·in', category: ConversionCategory.torque, baseConversionFactor: 0.1129848290276167, aliases: ['pound-inch', 'lbfin']),
  ];

  static UnitDefinition? findUnitById(String id) {
    for (final u in allUnits) {
      if (u.id == id) return u;
    }
    // Backward compatibility with legacy/alternative ID prefixes
    const aliasMap = {
      'time_s': 't_s',
      'time_min': 't_min',
      'time_h': 't_h',
      'time_d': 't_d',
      'time_wk': 't_wk',
      'time_mo': 't_mo',
      'time_yr': 't_yr',
      's_ms': 's_mps',
      'pw_w': 'pow_w',
      'pw_kw': 'pow_kw',
      'pw_mw': 'pow_mw',
      'pw_gw': 'pow_gw',
      'pw_hp': 'pow_hp',
      'p_w': 'pow_w',
      'p_kw': 'pow_kw',
      'p_mw': 'pow_mw',
      'p_gw': 'pow_gw',
      'p_hp': 'pow_hp',
      'd_b': 'ds_b',
      'd_kb': 'ds_kb',
      'd_kib': 'ds_kib',
      'd_mb': 'ds_mb',
      'd_mib': 'ds_mib',
      'd_gb': 'ds_gb',
      'd_gib': 'ds_gib',
      'd_tb': 'ds_tb',
      'd_tib': 'ds_tib',
      'f_hz': 'freq_hz',
      'f_khz': 'freq_khz',
      'f_mhz': 'freq_mhz',
      'f_ghz': 'freq_ghz',
      'frc_n': 'f_n',
      'frc_kn': 'f_kn',
      'frc_lbf': 'f_lbf',
      'frc_kgf': 'f_kgf',
      'force_n': 'f_n',
      'force_kn': 'f_kn',
      'force_lbf': 'f_lbf',
      'force_kgf': 'f_kgf',
    };
    final resolvedId = aliasMap[id];
    if (resolvedId != null) {
      for (final u in allUnits) {
        if (u.id == resolvedId) return u;
      }
    }
    return null;
  }

  static List<UnitDefinition> getUnitsByCategory(ConversionCategory category) {
    return allUnits.where((u) => u.category == category).toList();
  }

  static List<UnitDefinition> searchUnits(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return allUnits.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.symbol.toLowerCase().contains(q) ||
          u.aliases.any((a) => a.toLowerCase().contains(q));
    }).toList();
  }
}
