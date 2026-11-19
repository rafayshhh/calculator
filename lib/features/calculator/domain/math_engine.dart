import 'dart:math' as math;

enum AngleMode {
  degrees,
  radians,
  gradians,
}

class MathEngine {
  MathEngine._();

  static String evaluate(
    String expression, {
    AngleMode angleMode = AngleMode.degrees,
    int? precision,
  }) {
    return CalculatorEngine.calculate(
      expression,
      angleMode: angleMode,
      precision: precision,
    );
  }
}

class CalculatorEngine {
  CalculatorEngine._();

  static double evaluateNumeric(
    String expression, {
    Map<String, double> variables = const {},
    AngleMode angleMode = AngleMode.degrees,
  }) {
    String expr = expression.trim();
    if (expr.isEmpty) return 0.0;

    for (final entry in variables.entries) {
      final valStr = '(${entry.value})';
      expr = expr.replaceAllMapped(
        RegExp(r'(\d)' + RegExp.escape(entry.key)),
        (m) => '${m[1]}*$valStr',
      );
      expr = expr.replaceAllMapped(
        RegExp(r'(\))' + RegExp.escape(entry.key)),
        (m) => '${m[1]}*$valStr',
      );
      expr = expr.replaceAll(entry.key, valStr);
    }

    final parser = _MathParser(expr, angleMode);
    return parser.parse();
  }

  static String calculate(
    String expression, {
    AngleMode angleMode = AngleMode.degrees,
    int? precision,
  }) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return '0';

    final parser = _MathParser(trimmed, angleMode);
    final val = parser.parse();

    // Clean formatting
    return _formatNumber(val, precision: precision);
  }

  static String _formatNumber(double val, {int? precision}) {
    if (val.isNaN) throw ArgumentError('Result is undefined (NaN)');
    if (val.isInfinite) throw ArgumentError('Division by zero');

    // Round very close to integer or zero
    if ((val - val.roundToDouble()).abs() < 1e-11) {
      val = val.roundToDouble();
    }

    if (val == 0.0 || val == -0.0) return '0';

    if (precision != null && precision >= 0) {
      return val.toStringAsFixed(precision);
    }

    if (val % 1 == 0 && val.abs() < 1e14) {
      return val.toInt().toString();
    }

    // Format float with up to 10 decimal places, stripping trailing zeros
    String str = val.toStringAsFixed(10);
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }
}

class _MathParser {
  final String text;
  final AngleMode angleMode;
  int pos = 0;

  _MathParser(this.text, this.angleMode);

  void _skipWhitespace() {
    while (pos < text.length && text[pos] == ' ') {
      pos++;
    }
  }

  double parse() {
    pos = 0;
    _skipWhitespace();
    if (pos >= text.length) return 0.0;

    final val = _parseAddSub();
    _skipWhitespace();
    if (pos < text.length) {
      throw FormatException('Unexpected character at index $pos: ${text[pos]}');
    }
    return val;
  }

  // Addition & Subtraction (+, -) with percentage semantics
  double _parseAddSub() {
    double left = _parseMulDiv();

    while (true) {
      _skipWhitespace();
      if (pos >= text.length) break;

      final ch = text[pos];
      if (ch == '+' || ch == '-') {
        pos++;
        _skipWhitespace();
        if (pos >= text.length) {
          throw FormatException('Expression ends with trailing operator');
        }

        // Lookahead to check if right operand is a percent
        final right = _parseMulDiv(baseForPercent: left, isAddSub: true);
        if (ch == '+') {
          left = left + right;
        } else {
          left = left - right;
        }
      } else {
        break;
      }
    }
    return left;
  }

  // Multiplication & Division (*, /, ×, ÷)
  double _parseMulDiv({double? baseForPercent, bool isAddSub = false}) {
    double left = _parsePower();

    while (true) {
      _skipWhitespace();
      if (pos >= text.length) break;

      final ch = text[pos];
      if (ch == '*' || ch == '×' || ch == '/' || ch == '÷') {
        pos++;
        _skipWhitespace();
        if (pos >= text.length || text[pos] == '*' || text[pos] == '/' || text[pos] == '×' || text[pos] == '÷') {
          throw FormatException('Invalid consecutive operator');
        }
        final right = _parsePower();
        if (ch == '*' || ch == '×') {
          left = left * right;
        } else {
          if (right == 0.0) throw ArgumentError('Division by zero');
          left = left / right;
        }
      } else if (ch == '%') {
        pos++;
        if (baseForPercent != null && isAddSub) {
          left = (baseForPercent * left) / 100.0;
        } else {
          left = left / 100.0;
        }
      } else if (_isImplicitMulStart(ch)) {
        // Implicit multiplication, e.g. 2(3+4), 2pi, (2+3)(4+5), 3sin(30)
        final right = _parsePower();
        left = left * right;
      } else {
        break;
      }
    }
    return left;
  }

  bool _isImplicitMulStart(String ch) {
    if (ch == '(') return true;
    if (ch == 'p' || ch == 'e') {
      if (pos + 1 < text.length && text[pos] == 'p' && text[pos + 1] == 'i') return true;
      if (ch == 'e') {
        // Check if scientific notation e.g. 1e3 or constant e
        if (pos + 1 < text.length) {
          final next = text[pos + 1];
          if (next == '+' || next == '-' || RegExp(r'[0-9]').hasMatch(next)) {
            return false;
          }
        }
        return true;
      }
    }
    if (RegExp(r'[a-zA-Z]').hasMatch(ch)) return true;
    return false;
  }

  // Power (^) - right-associative
  double _parsePower() {
    double base = _parseUnary();

    _skipWhitespace();
    if (pos < text.length && text[pos] == '^') {
      pos++;
      _skipWhitespace();
      if (pos < text.length && text[pos] == '^') {
        throw FormatException('Invalid double power operator ^^');
      }
      final exponent = _parsePower(); // Right-associative recursion

      return _computePower(base, exponent);
    }

    return base;
  }

  double _computePower(double base, double exponent) {
    if (base >= 0) {
      return math.pow(base, exponent).toDouble();
    }

    // Negative base
    // If exponent is integer
    if (exponent % 1 == 0) {
      final intExp = exponent.toInt();
      final res = math.pow(base.abs(), intExp).toDouble();
      return intExp % 2 != 0 ? -res : res;
    }

    // Fractional exponent with negative base
    // Try to find rational p/q where q is odd
    for (int q = 1; q <= 99; q += 2) {
      final p = (exponent * q).round();
      if ((exponent - (p / q)).abs() < 1e-6) {
        final root = math.pow(base.abs(), 1.0 / q).toDouble();
        final res = math.pow(root, p.abs()).toDouble();
        double signedRes = (p % 2 != 0) ? -res : res;
        if (exponent < 0) signedRes = 1.0 / signedRes;
        return signedRes;
      }
    }

    throw ArgumentError('Complex result for negative base with even root');
  }

  // Unary operators (+, -)
  double _parseUnary() {
    _skipWhitespace();
    if (pos >= text.length) throw FormatException('Unexpected end of expression');

    if (text[pos] == '+') {
      pos++;
      return _parseUnary();
    }
    if (text[pos] == '-') {
      pos++;
      // Unary minus has lower precedence than power in standard math: -2^2 = -(2^2) = -4
      final val = _parsePower();
      return -val;
    }

    return _parseFactorial();
  }

  // Factorial (!) postfix operator
  double _parseFactorial() {
    double val = _parseAtom();

    while (true) {
      _skipWhitespace();
      if (pos < text.length && text[pos] == '!') {
        pos++;
        if (val < 0 || val % 1 != 0) {
          throw ArgumentError('Factorial only defined for non-negative integers');
        }
        val = _factorial(val.toInt());
      } else {
        break;
      }
    }
    return val;
  }

  double _factorial(int n) {
    if (n > 170) return double.infinity;
    double result = 1.0;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // Atoms: Numbers, Parentheses, Functions, Constants
  double _parseAtom() {
    _skipWhitespace();
    if (pos >= text.length) throw FormatException('Unexpected end of expression');

    final ch = text[pos];

    if (ch == '(') {
      pos++;
      final val = _parseAddSub();
      _skipWhitespace();
      if (pos >= text.length || text[pos] != ')') {
        throw FormatException('Missing closing parenthesis');
      }
      pos++;
      return val;
    }

    if (ch == ')') {
      throw FormatException('Unexpected closing parenthesis');
    }

    if (RegExp(r'[0-9.]').hasMatch(ch)) {
      return _parseNumber();
    }

    if (RegExp(r'[a-zA-Z]').hasMatch(ch)) {
      return _parseIdentifier();
    }

    throw FormatException('Unexpected character: $ch');
  }

  double _parseNumber() {
    final start = pos;
    bool hasDot = false;

    while (pos < text.length) {
      final c = text[pos];
      if (c == '.') {
        if (hasDot) throw FormatException('Multiple decimal points in number');
        hasDot = true;
        pos++;
      } else if (RegExp(r'[0-9]').hasMatch(c)) {
        pos++;
      } else if (c == 'e' || c == 'E') {
        // Check if scientific notation
        if (pos + 1 < text.length) {
          final next = text[pos + 1];
          if (next == '+' || next == '-' || RegExp(r'[0-9]').hasMatch(next)) {
            pos++; // consume 'e'
            if (pos < text.length && (text[pos] == '+' || text[pos] == '-')) {
              pos++; // consume sign
            }
            if (pos >= text.length || !RegExp(r'[0-9]').hasMatch(text[pos])) {
              throw FormatException('Invalid exponent in scientific notation');
            }
            while (pos < text.length && RegExp(r'[0-9]').hasMatch(text[pos])) {
              pos++;
            }
            break;
          }
        }
        break; // regular 'e' constant or identifier
      } else {
        break;
      }
    }

    final numStr = text.substring(start, pos);
    final val = double.tryParse(numStr);
    if (val == null) {
      throw FormatException('Invalid number format: $numStr');
    }
    return val;
  }

  double _parseIdentifier() {
    final start = pos;
    while (pos < text.length && RegExp(r'[a-zA-Z]').hasMatch(text[pos])) {
      pos++;
    }
    final name = text.substring(start, pos);

    // Constants
    if (name == 'pi') return math.pi;
    if (name == 'e') return math.e;

    _skipWhitespace();
    if (pos >= text.length || text[pos] != '(') {
      throw FormatException('Expected ( after function name $name');
    }

    pos++; // consume '('
    _skipWhitespace();
    if (pos < text.length && text[pos] == ')') {
      throw FormatException('Function $name requires arguments');
    }

    final arg = _parseAddSub();
    _skipWhitespace();
    if (pos >= text.length || text[pos] != ')') {
      throw FormatException('Missing closing ) for function $name');
    }
    pos++; // consume ')'

    return _evaluateFunction(name, arg);
  }

  double _evaluateFunction(String name, double x) {
    switch (name) {
      case 'sin':
        final rad = _toRad(x);
        final s = math.sin(rad);
        return (s.abs() < 1e-15) ? 0.0 : s;
      case 'cos':
        final rad = _toRad(x);
        final c = math.cos(rad);
        return (c.abs() < 1e-15) ? 0.0 : c;
      case 'tan':
        final rad = _toRad(x);
        return math.tan(rad);
      case 'asin':
        if (x < -1.0 || x > 1.0) throw ArgumentError('asin domain is [-1, 1]');
        return _fromRad(math.asin(x));
      case 'acos':
        if (x < -1.0 || x > 1.0) throw ArgumentError('acos domain is [-1, 1]');
        return _fromRad(math.acos(x));
      case 'atan':
        return _fromRad(math.atan(x));
      case 'sqrt':
        if (x < 0) throw ArgumentError('sqrt of negative number');
        return math.sqrt(x);
      case 'cbrt':
        return x < 0 ? -math.pow(-x, 1.0 / 3.0).toDouble() : math.pow(x, 1.0 / 3.0).toDouble();
      case 'log':
        if (x <= 0) throw ArgumentError('log of non-positive number');
        return math.log(x) / math.ln10;
      case 'ln':
        if (x <= 0) throw ArgumentError('ln of non-positive number');
        return math.log(x);
      case 'abs':
        return x.abs();
      default:
        throw FormatException('Unknown function: $name');
    }
  }

  double _toRad(double angle) {
    switch (angleMode) {
      case AngleMode.degrees:
        return angle * (math.pi / 180.0);
      case AngleMode.radians:
        return angle;
      case AngleMode.gradians:
        return angle * (math.pi / 200.0);
    }
  }

  double _fromRad(double rad) {
    switch (angleMode) {
      case AngleMode.degrees:
        return rad * (180.0 / math.pi);
      case AngleMode.radians:
        return rad;
      case AngleMode.gradians:
        return rad * (200.0 / math.pi);
    }
  }
}
