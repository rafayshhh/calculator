import 'dart:math' as math;

class PhysicsEngine {
  PhysicsEngine._();

  static const double standardGravity = 9.80665; // m/s²

  /// Force: F = ma
  static double calculateForce(double mass, double acceleration) {
    if (mass < 0) {
      throw ArgumentError('Mass cannot be negative');
    }
    return mass * acceleration;
  }

  static double calculateMassFromForce(double force, double acceleration) {
    if (acceleration == 0) throw ArgumentError('Acceleration cannot be zero');
    return force / acceleration;
  }

  static double calculateAccelerationFromForce(double force, double mass) {
    if (mass <= 0) throw ArgumentError('Mass must be positive');
    return force / mass;
  }

  /// Kinetic Energy: KE = 0.5 * m * v²
  static double calculateKineticEnergy(double mass, double velocity) {
    if (mass < 0) throw ArgumentError('Mass cannot be negative');
    return 0.5 * mass * velocity * velocity;
  }

  /// Potential Energy: PE = mgh
  static double calculatePotentialEnergy(
    double mass,
    double height, {
    double g = standardGravity,
  }) {
    if (mass < 0) throw ArgumentError('Mass cannot be negative');
    return mass * g * height;
  }

  /// Ohm's Law: V = IR
  static double calculateVoltage(double current, double resistance) {
    return current * resistance;
  }

  static double calculateCurrent(double voltage, double resistance) {
    if (resistance == 0) throw ArgumentError('Resistance cannot be zero');
    return voltage / resistance;
  }

  static double calculateResistance(double voltage, double current) {
    if (current == 0) throw ArgumentError('Current cannot be zero');
    return voltage / current;
  }

  /// Electrical Power: P = VI
  static double calculateElectricalPower(double voltage, double current) {
    return voltage * current;
  }

  /// Pressure: P = F / A
  static double calculatePressure(double force, double area) {
    if (area <= 0) throw ArgumentError('Area must be positive');
    return force / area;
  }

  /// Density: ρ = m / V
  static double calculateDensity(double mass, double volume) {
    if (volume <= 0) {
      throw ArgumentError('Volume must be positive');
    }
    if (mass < 0) {
      throw ArgumentError('Mass cannot be negative');
    }
    return mass / volume;
  }

  static double calculateMassFromDensity(double density, double volume) {
    if (density < 0 || volume < 0) {
      throw ArgumentError('Density and volume cannot be negative');
    }
    return density * volume;
  }

  static double calculateVolumeFromDensity(double mass, double density) {
    if (density <= 0) {
      throw ArgumentError('Density must be positive');
    }
    if (mass < 0) {
      throw ArgumentError('Mass cannot be negative');
    }
    return mass / density;
  }

  /// Wave Speed: v = fλ
  static double calculateWaveSpeed(double frequency, double wavelength) {
    if (frequency < 0 || wavelength < 0) {
      throw ArgumentError('Frequency and wavelength cannot be negative');
    }
    return frequency * wavelength;
  }

  static double calculateWavelength(double speed, double frequency) {
    if (frequency <= 0) throw ArgumentError('Frequency must be positive');
    return speed / frequency;
  }

  static double calculateFrequency(double speed, double wavelength) {
    if (wavelength <= 0) throw ArgumentError('Wavelength must be positive');
    return speed / wavelength;
  }

  /// Momentum: p = mv
  static double calculateMomentum(double mass, double velocity) {
    if (mass < 0) throw ArgumentError('Mass cannot be negative');
    return mass * velocity;
  }

  /// Velocity: v = d / t
  static double calculateVelocity(double distance, double time) {
    if (time <= 0) throw ArgumentError('Time must be positive');
    return distance / time;
  }

  /// Work: W = F * d * cos(θ)
  static double calculateWork(
    double force,
    double distance, {
    double angleDegrees = 0,
  }) {
    final rad = angleDegrees * (math.pi / 180.0);
    return force * distance * math.cos(rad);
  }

  /// Resistance Networks
  static double calculateSeriesResistance(List<double> resistances) {
    if (resistances.isEmpty) return 0.0;
    return resistances.reduce((a, b) => a + b);
  }

  static double calculateParallelResistance(List<double> resistances) {
    if (resistances.isEmpty) return 0.0;
    double invSum = 0.0;
    for (final r in resistances) {
      if (r <= 0) throw ArgumentError('Resistance must be positive');
      invSum += 1.0 / r;
    }
    return 1.0 / invSum;
  }
}
