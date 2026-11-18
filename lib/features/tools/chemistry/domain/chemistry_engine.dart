import 'dart:math' as math;

class ElementBreakdown {
  final String symbol;
  final String name;
  final int count;
  final double atomicMass;
  final double massPercentage;

  const ElementBreakdown({
    required this.symbol,
    required this.name,
    required this.count,
    required this.atomicMass,
    required this.massPercentage,
  });
}

class MolarMassResult {
  final String formula;
  final double totalMolarMass;
  final List<ElementBreakdown> elements;

  const MolarMassResult({
    required this.formula,
    required this.totalMolarMass,
    required this.elements,
  });
}

class ChemistryEngine {
  ChemistryEngine._();

  static const double rGasConstant = 8.314462618; // L·kPa / (mol·K)

  static const Map<String, (String name, double mass)> elementTable = {
    'H': ('Hydrogen', 1.008),
    'He': ('Helium', 4.0026),
    'Li': ('Lithium', 6.94),
    'Be': ('Beryllium', 9.0122),
    'B': ('Boron', 10.81),
    'C': ('Carbon', 12.011),
    'N': ('Nitrogen', 14.007),
    'O': ('Oxygen', 15.999),
    'F': ('Fluorine', 18.998),
    'Ne': ('Neon', 20.180),
    'Na': ('Sodium', 22.990),
    'Mg': ('Magnesium', 24.305),
    'Al': ('Aluminium', 26.982),
    'Si': ('Silicon', 28.085),
    'P': ('Phosphorus', 30.974),
    'S': ('Sulfur', 32.065),
    'Cl': ('Chlorine', 35.453),
    'Ar': ('Argon', 39.948),
    'K': ('Potassium', 39.098),
    'Ca': ('Calcium', 40.078),
    'Sc': ('Scandium', 44.956),
    'Ti': ('Titanium', 47.867),
    'V': ('Vanadium', 50.942),
    'Cr': ('Chromium', 51.996),
    'Mn': ('Manganese', 54.938),
    'Fe': ('Iron', 55.845),
    'Co': ('Cobalt', 58.933),
    'Ni': ('Nickel', 58.693),
    'Cu': ('Copper', 63.546),
    'Zn': ('Zinc', 65.38),
    'Ga': ('Gallium', 69.723),
    'Ge': ('Germanium', 72.630),
    'As': ('Arsenic', 74.922),
    'Se': ('Selenium', 78.971),
    'Br': ('Bromine', 79.904),
    'Kr': ('Krypton', 83.798),
    'Rb': ('Rubidium', 85.468),
    'Sr': ('Strontium', 87.62),
    'Y': ('Yttrium', 88.906),
    'Zr': ('Zirconium', 91.224),
    'Nb': ('Niobium', 92.906),
    'Mo': ('Molybdenum', 95.95),
    'Tc': ('Technetium', 98.0),
    'Ru': ('Ruthenium', 101.07),
    'Rh': ('Rhodium', 102.91),
    'Pd': ('Palladium', 106.42),
    'Ag': ('Silver', 107.87),
    'Cd': ('Cadmium', 112.41),
    'In': ('Indium', 114.82),
    'Sn': ('Tin', 118.71),
    'Sb': ('Antimony', 121.76),
    'Te': ('Tellurium', 127.60),
    'I': ('Iodine', 126.90),
    'Xe': ('Xenon', 131.29),
    'Cs': ('Caesium', 132.91),
    'Ba': ('Barium', 137.33),
    'La': ('Lanthanum', 138.91),
    'Pt': ('Platinum', 195.08),
    'Au': ('Gold', 196.97),
    'Hg': ('Mercury', 200.59),
    'Pb': ('Lead', 207.2),
    'Bi': ('Bismuth', 208.98),
    'U': ('Uranium', 238.03),
  };

  /// Parses formula and computes total molar mass and elemental breakdown
  static MolarMassResult calculateMolarMass(String formula) {
    final trimmed = formula.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Chemical formula cannot be empty');
    }

    final counts = _parseFormula(trimmed);
    double totalMass = 0;
    final breakdown = <ElementBreakdown>[];

    counts.forEach((sym, cnt) {
      final info = elementTable[sym];
      if (info == null) {
        throw ArgumentError('Unknown chemical element: $sym');
      }
      final elementTotal = info.$2 * cnt;
      totalMass += elementTotal;
    });

    counts.forEach((sym, cnt) {
      final info = elementTable[sym]!;
      final elementTotal = info.$2 * cnt;
      final pct = totalMass > 0 ? (elementTotal / totalMass) * 100.0 : 0.0;
      breakdown.add(
        ElementBreakdown(
          symbol: sym,
          name: info.$1,
          count: cnt,
          atomicMass: info.$2,
          massPercentage: pct,
        ),
      );
    });

    return MolarMassResult(
      formula: trimmed,
      totalMolarMass: totalMass,
      elements: breakdown,
    );
  }

  static Map<String, int> _parseFormula(String formula) {
    int index = 0;

    Map<String, int> parseGroup() {
      final groupCounts = <String, int>{};

      while (index < formula.length) {
        final ch = formula[index];

        if (ch == '(' || ch == '[' || ch == '{') {
          index++;
          final sub = parseGroup();
          int multiplier = 1;
          final numStart = index;
          while (index < formula.length && RegExp(r'[0-9]').hasMatch(formula[index])) {
            index++;
          }
          if (index > numStart) {
            multiplier = int.parse(formula.substring(numStart, index));
          }
          sub.forEach((k, v) {
            groupCounts[k] = (groupCounts[k] ?? 0) + v * multiplier;
          });
        } else if (ch == ')' || ch == ']' || ch == '}') {
          index++;
          return groupCounts;
        } else if (RegExp(r'[A-Z]').hasMatch(ch)) {
          final symStart = index;
          index++;
          while (index < formula.length && RegExp(r'[a-z]').hasMatch(formula[index])) {
            index++;
          }
          final symbol = formula.substring(symStart, index);
          int count = 1;
          final numStart = index;
          while (index < formula.length && RegExp(r'[0-9]').hasMatch(formula[index])) {
            index++;
          }
          if (index > numStart) {
            count = int.parse(formula.substring(numStart, index));
          }
          groupCounts[symbol] = (groupCounts[symbol] ?? 0) + count;
        } else {
          index++;
        }
      }

      return groupCounts;
    }

    return parseGroup();
  }

  /// Dilution: M1 * V1 = M2 * V2
  static double calculateDilutionV1(double m1, double m2, double v2) {
    if (m1 <= 0) throw ArgumentError('Stock concentration M1 must be positive');
    if (m2 <= 0) throw ArgumentError('Target concentration M2 must be positive');
    if (v2 <= 0) throw ArgumentError('Target volume V2 must be positive');
    return (m2 * v2) / m1;
  }

  /// Ideal Gas Volume (L) given pressure (kPa), moles (mol), and temperature (K)
  static double calculateIdealGasVolume(double pKpa, double nMol, double tKelvin) {
    if (pKpa <= 0) throw ArgumentError('Pressure must be positive');
    if (nMol <= 0) throw ArgumentError('Moles must be positive');
    if (tKelvin <= 0) throw ArgumentError('Temperature in Kelvin must be positive');
    return (nMol * rGasConstant * tKelvin) / pKpa;
  }

  /// Ideal Gas Pressure (kPa)
  static double calculateIdealGasPressure(double vLiters, double nMol, double tKelvin) {
    if (vLiters <= 0) throw ArgumentError('Volume must be positive');
    if (nMol <= 0) throw ArgumentError('Moles must be positive');
    if (tKelvin <= 0) throw ArgumentError('Temperature in Kelvin must be positive');
    return (nMol * rGasConstant * tKelvin) / vLiters;
  }

  /// pH & pOH
  static double calculatePohFromPh(double ph) => 14.0 - ph;

  static double calculateHFromPh(double ph) => math.pow(10, -ph).toDouble();

  static double calculatePhFromH(double hConc) {
    if (hConc <= 0) throw ArgumentError('H+ concentration must be positive');
    return -math.log(hConc) / math.ln10;
  }

  /// Molarity & Concentrations
  static double calculateMolesFromMolarity(double molarity, double volumeLiters) {
    if (molarity < 0 || volumeLiters < 0) throw ArgumentError('Values cannot be negative');
    return molarity * volumeLiters;
  }

  static double calculateVolumeFromMolarity(double moles, double molarity) {
    if (molarity <= 0) throw ArgumentError('Molarity must be positive');
    if (moles < 0) throw ArgumentError('Moles cannot be negative');
    return moles / molarity;
  }

  static double calculateMolarity(double moles, double volumeLiters) {
    if (volumeLiters <= 0) throw ArgumentError('Volume must be positive');
    if (moles < 0) throw ArgumentError('Moles cannot be negative');
    return moles / volumeLiters;
  }

  static double calculateMassPercentage(double soluteMass, double totalSolutionMass) {
    if (totalSolutionMass <= 0) throw ArgumentError('Total mass must be positive');
    if (soluteMass < 0) throw ArgumentError('Solute mass cannot be negative');
    return (soluteMass / totalSolutionMass) * 100.0;
  }
}
