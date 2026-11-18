import 'dart:math' as math;

class EngineeringEngine {
  EngineeringEngine._();

  /// Torque: τ = F * r * sin(θ)
  static double calculateTorque(
    double force,
    double radius, {
    double angleDegrees = 90,
  }) {
    final rad = angleDegrees * (math.pi / 180.0);
    return force * radius * math.sin(rad);
  }

  static double calculateForceFromTorque(
    double torque,
    double radius, {
    double angleDegrees = 90,
  }) {
    final rad = angleDegrees * (math.pi / 180.0);
    final sinVal = math.sin(rad);
    if (radius == 0 || sinVal == 0) {
      throw ArgumentError('Radius and sin(angle) cannot be zero');
    }
    return torque / (radius * sinVal);
  }

  static double calculateRadiusFromTorque(
    double torque,
    double force, {
    double angleDegrees = 90,
  }) {
    final rad = angleDegrees * (math.pi / 180.0);
    final sinVal = math.sin(rad);
    if (force == 0 || sinVal == 0) {
      throw ArgumentError('Force and sin(angle) cannot be zero');
    }
    return torque / (force * sinVal);
  }

  /// Hooke's Law: F = kx
  static double calculateSpringForce(double k, double displacement) {
    return k * displacement;
  }

  static double calculateSpringConstant(double force, double displacement) {
    if (displacement == 0) throw ArgumentError('Displacement cannot be zero');
    return force / displacement;
  }

  static double calculateSpringDisplacement(double force, double k) {
    if (k == 0) throw ArgumentError('Spring constant k cannot be zero');
    return force / k;
  }

  /// Young's Modulus: E = stress / strain
  static double calculateYoungsModulus(double stress, double strain) {
    if (strain == 0) throw ArgumentError('Strain cannot be zero');
    return stress / strain;
  }

  /// Mechanical Advantage: MA = outputForce / inputForce
  static double calculateMechanicalAdvantage(
    double outputForce,
    double inputForce,
  ) {
    if (inputForce <= 0) throw ArgumentError('Input force must be positive');
    return outputForce / inputForce;
  }

  /// Gear Ratio: GR = outputTeeth / inputTeeth
  static double calculateGearRatio(double inputTeeth, double outputTeeth) {
    if (inputTeeth <= 0) throw ArgumentError('Input teeth must be positive');
    return outputTeeth / inputTeeth;
  }

  /// Stress: σ = F / A
  static double calculateStress(double force, double area) {
    if (area <= 0) throw ArgumentError('Area must be positive');
    return force / area;
  }

  /// Strain: ε = ΔL / L0
  static double calculateStrain(
    double changeInLength,
    double originalLength,
  ) {
    if (originalLength <= 0) {
      throw ArgumentError('Original length must be positive');
    }
    return changeInLength / originalLength;
  }

  /// RC Time Constant: τ = R * C
  static double calculateRcTimeConstant(
    double resistanceOhms,
    double capacitanceFarads,
  ) {
    if (resistanceOhms < 0 || capacitanceFarads < 0) {
      throw ArgumentError('Values cannot be negative');
    }
    return resistanceOhms * capacitanceFarads;
  }

  /// Gear RPM: outputRpm = inputRpm / gearRatio
  static double calculateRpmGear(double inputRpm, double gearRatio) {
    if (gearRatio == 0) throw ArgumentError('Gear ratio cannot be zero');
    return inputRpm / gearRatio;
  }

  /// Capacitance Series / Parallel
  static double calculateSeriesCapacitance(List<double> values) {
    if (values.isEmpty) return 0.0;
    double invSum = 0.0;
    for (final c in values) {
      if (c <= 0) throw ArgumentError('Capacitance must be positive');
      invSum += 1.0 / c;
    }
    return 1.0 / invSum;
  }

  static double calculateParallelCapacitance(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b);
  }

  /// Inductance Series / Parallel
  static double calculateSeriesInductance(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b);
  }

  static double calculateParallelInductance(List<double> values) {
    if (values.isEmpty) return 0.0;
    double invSum = 0.0;
    for (final l in values) {
      if (l <= 0) throw ArgumentError('Inductance must be positive');
      invSum += 1.0 / l;
    }
    return 1.0 / invSum;
  }
}
