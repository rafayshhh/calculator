import 'dart:math' as math;

enum AngleMode { degrees, radians, gradians }

class MathFunctionDefinition {
  final String name;
  final List<String> aliases;
  final int argumentCount;
  final String description;
  final double Function(double arg, AngleMode angleMode) evaluate;
  final void Function(double arg)? validate;

  const MathFunctionDefinition({
    required this.name,
    this.aliases = const [],
    this.argumentCount = 1,
    required this.description,
    required this.evaluate,
    this.validate,
  });
}

class FunctionsRegistry {
  static final Map<String, MathFunctionDefinition> _functions = {
    'sin': MathFunctionDefinition(
      name: 'sin',
      description: 'Sine of angle',
      evaluate: (arg, mode) => math.sin(_toRadians(arg, mode)),
    ),
    'cos': MathFunctionDefinition(
      name: 'cos',
      description: 'Cosine of angle',
      evaluate: (arg, mode) => math.cos(_toRadians(arg, mode)),
    ),
    'tan': MathFunctionDefinition(
      name: 'tan',
      description: 'Tangent of angle',
      validate: (arg) {
        // Validation handled during eval or checked
      },
      evaluate: (arg, mode) {
        final rad = _toRadians(arg, mode);
        final cosVal = math.cos(rad);
        if (cosVal.abs() < 1e-15) {
          throw ArgumentError('Undefined tangent (asymptote at angle)');
        }
        return math.tan(rad);
      },
    ),
    'asin': MathFunctionDefinition(
      name: 'asin',
      aliases: ['arcsin', 'sin_inv'],
      description: 'Arcsine (inverse sine)',
      validate: (arg) {
        if (arg < -1.0 || arg > 1.0) {
          throw ArgumentError('Arcsine argument must be in range [-1, 1]');
        }
      },
      evaluate: (arg, mode) => _fromRadians(math.asin(arg), mode),
    ),
    'acos': MathFunctionDefinition(
      name: 'acos',
      aliases: ['arccos', 'cos_inv'],
      description: 'Arccosine (inverse cosine)',
      validate: (arg) {
        if (arg < -1.0 || arg > 1.0) {
          throw ArgumentError('Arccosine argument must be in range [-1, 1]');
        }
      },
      evaluate: (arg, mode) => _fromRadians(math.acos(arg), mode),
    ),
    'atan': MathFunctionDefinition(
      name: 'atan',
      aliases: ['arctan', 'tan_inv'],
      description: 'Arctangent (inverse tangent)',
      evaluate: (arg, mode) => _fromRadians(math.atan(arg), mode),
    ),
    'sinh': MathFunctionDefinition(
      name: 'sinh',
      description: 'Hyperbolic sine',
      evaluate: (arg, _) => (math.exp(arg) - math.exp(-arg)) / 2.0,
    ),
    'cosh': MathFunctionDefinition(
      name: 'cosh',
      description: 'Hyperbolic cosine',
      evaluate: (arg, _) => (math.exp(arg) + math.exp(-arg)) / 2.0,
    ),
    'tanh': MathFunctionDefinition(
      name: 'tanh',
      description: 'Hyperbolic tangent',
      evaluate: (arg, _) {
        // Numerically stable: avoid exp(large) = Infinity -> NaN
        // tanh approaches ±1 asymptotically for |arg| > ~20
        if (arg > 20.0) return 1.0;
        if (arg < -20.0) return -1.0;
        final eX = math.exp(arg);
        final eMinusX = math.exp(-arg);
        return (eX - eMinusX) / (eX + eMinusX);
      },
    ),
    'log': MathFunctionDefinition(
      name: 'log',
      aliases: ['log10'],
      description: 'Common Logarithm (base 10)',
      validate: (arg) {
        if (arg <= 0) {
          throw ArgumentError('Logarithm requires a positive value');
        }
      },
      evaluate: (arg, _) => math.log(arg) / math.ln10,
    ),
    'ln': MathFunctionDefinition(
      name: 'ln',
      aliases: ['log_e'],
      description: 'Natural Logarithm (base e)',
      validate: (arg) {
        if (arg <= 0) {
          throw ArgumentError('Logarithm requires a positive value');
        }
      },
      evaluate: (arg, _) => math.log(arg),
    ),
    'sqrt': MathFunctionDefinition(
      name: 'sqrt',
      aliases: ['√'],
      description: 'Square Root',
      validate: (arg) {
        if (arg < 0) {
          throw ArgumentError('Square root of negative number');
        }
      },
      evaluate: (arg, _) => math.sqrt(arg),
    ),
    'cbrt': MathFunctionDefinition(
      name: 'cbrt',
      description: 'Cube Root',
      evaluate: (arg, _) {
        if (arg < 0) return -math.pow(-arg, 1.0 / 3.0).toDouble();
        return math.pow(arg, 1.0 / 3.0).toDouble();
      },
    ),
    'abs': MathFunctionDefinition(
      name: 'abs',
      description: 'Absolute value',
      evaluate: (arg, _) => arg.abs(),
    ),
    'floor': MathFunctionDefinition(
      name: 'floor',
      description: 'Floor integer',
      evaluate: (arg, _) => arg.floorToDouble(),
    ),
    'ceil': MathFunctionDefinition(
      name: 'ceil',
      description: 'Ceiling integer',
      evaluate: (arg, _) => arg.ceilToDouble(),
    ),
    'round': MathFunctionDefinition(
      name: 'round',
      description: 'Nearest integer',
      evaluate: (arg, _) => arg.roundToDouble(),
    ),
    'exp': MathFunctionDefinition(
      name: 'exp',
      description: 'Exponential e^x',
      evaluate: (arg, _) => math.exp(arg),
    ),
  };

  static MathFunctionDefinition? get(String nameOrAlias) {
    final lower = nameOrAlias.toLowerCase();
    if (_functions.containsKey(lower)) {
      return _functions[lower];
    }
    for (final func in _functions.values) {
      if (func.aliases.contains(lower)) {
        return func;
      }
    }
    return null;
  }

  static bool contains(String name) => get(name) != null;

  static double _toRadians(double value, AngleMode mode) {
    switch (mode) {
      case AngleMode.radians:
        return value;
      case AngleMode.gradians:
        return value * (math.pi / 200.0);
      case AngleMode.degrees:
        return value * (math.pi / 180.0);
    }
  }

  static double _fromRadians(double value, AngleMode mode) {
    switch (mode) {
      case AngleMode.radians:
        return value;
      case AngleMode.gradians:
        return value * (200.0 / math.pi);
      case AngleMode.degrees:
        return value * (180.0 / math.pi);
    }
  }
}
