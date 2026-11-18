import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/calculator/domain/math_engine.dart';

import 'dart:math' as math;

void main() {
  group('MathEngine - Basic Arithmetic', () {
    test('Addition', () => expect(CalculatorEngine.calculate('2+2'), '4'));
    test(
      'Multiplication',
      () => expect(CalculatorEngine.calculate('10*5'), '50'),
    );
    test('Division', () => expect(CalculatorEngine.calculate('100/4'), '25'));
    test(
      'Parentheses',
      () => expect(CalculatorEngine.calculate('(10+5)*2'), '30'),
    );
  });

  group('MathEngine - Percentage Semantics', () {
    test(
      'Percent value',
      () => expect(CalculatorEngine.calculate('50%'), '0.5'),
    );
    test(
      'Percent add',
      () => expect(CalculatorEngine.calculate('200+10%'), '220'),
    );
    test(
      'Percent sub',
      () => expect(CalculatorEngine.calculate('200-10%'), '180'),
    );
    test(
      'Percent mult',
      () => expect(CalculatorEngine.calculate('200*10%'), '20'),
    );
  });

  group('MathEngine - Trigonometry', () {
    test(
      'DEG: sin(30) = 0.5',
      () => expect(CalculatorEngine.calculate('sin(30)'), '0.5'),
    );
    test('DEG: cos(60) = 0.5', () {
      // Due to float math, might be 0.5000000000000001, handled by formatter
      String res = CalculatorEngine.calculate('cos(60)');
      expect(double.parse(res), closeTo(0.5, 1e-10));
    });
    test('DEG: tan(45) = 1', () {
      String res = CalculatorEngine.calculate('tan(45)');
      expect(double.parse(res), closeTo(1, 1e-10));
    });

    test('RAD: sin(pi/2) = 1', () {
      String res = CalculatorEngine.calculate(
        'sin(pi/2)',
        angleMode: AngleMode.radians,
      );
      expect(double.parse(res), closeTo(1, 1e-10));
    });
    test('RAD: cos(pi) = -1', () {
      String res = CalculatorEngine.calculate(
        'cos(pi)',
        angleMode: AngleMode.radians,
      );
      expect(double.parse(res), closeTo(-1, 1e-10));
    });
  });

  group('MathEngine - Inverse Trig', () {
    test('asin(1) = pi/2 RAD', () {
      String res = CalculatorEngine.calculate(
        'asin(1)',
        angleMode: AngleMode.radians,
      );
      expect(double.parse(res), closeTo(math.pi / 2, 1e-10));
    });
    test(
      'acos(1) = 0',
      () => expect(CalculatorEngine.calculate('acos(1)'), '0'),
    );
    test('atan(1) = pi/4 RAD', () {
      String res = CalculatorEngine.calculate(
        'atan(1)',
        angleMode: AngleMode.radians,
      );
      expect(double.parse(res), closeTo(math.pi / 4, 1e-10));
    });
  });

  group('MathEngine - Logarithmic', () {
    test(
      'log(100) = 2',
      () => expect(CalculatorEngine.calculate('log(100)'), '2'),
    );
    test('log(1000) = 3', () {
      String res = CalculatorEngine.calculate('log(1000)');
      expect(double.parse(res), closeTo(3, 1e-10));
    });
    test('ln(e) = 1', () => expect(CalculatorEngine.calculate('ln(e)'), '1'));
    test('ln(1) = 0', () => expect(CalculatorEngine.calculate('ln(1)'), '0'));
  });

  group('MathEngine - Roots', () {
    test(
      'sqrt(9) = 3',
      () => expect(CalculatorEngine.calculate('sqrt(9)'), '3'),
    );
    test(
      'sqrt(16) = 4',
      () => expect(CalculatorEngine.calculate('sqrt(16)'), '4'),
    );
    test(
      'cbrt(27) = 3',
      () => expect(CalculatorEngine.calculate('cbrt(27)'), '3'),
    );
    test(
      'cbrt(-8) = -2',
      () => expect(CalculatorEngine.calculate('cbrt(-8)'), '-2'),
    );
  });

  group('MathEngine - Powers', () {
    test('2^3 = 8', () => expect(CalculatorEngine.calculate('2^3'), '8'));
    test(
      '2^10 = 1024',
      () => expect(CalculatorEngine.calculate('2^10'), '1024'),
    );
    test(
      '9^(1/2) = 3',
      () => expect(CalculatorEngine.calculate('9^(1/2)'), '3'),
    );
    test('-2^2', () => expect(CalculatorEngine.calculate('-2^2'), '-4')); // unary evaluated after power usually, wait, unary has higher precedence? If -2^2 is -(2^2)
    test('(-2)^2', () => expect(CalculatorEngine.calculate('(-2)^2'), '4'));

    // Negative-base fractional exponent regression tests
    test(
      '(-8)^(1/3) = -2',
      () => expect(CalculatorEngine.calculate('(-8)^(1/3)'), '-2'),
    );
    test(
      '(-8)^(2/3) = 4',
      () => expect(CalculatorEngine.calculate('(-8)^(2/3)'), '4'),
    );
    test(
      '(-27)^(1/3) = -3',
      () => expect(CalculatorEngine.calculate('(-27)^(1/3)'), '-3'),
    );
    test(
      '(-32)^(1/5) = -2',
      () => expect(CalculatorEngine.calculate('(-32)^(1/5)'), '-2'),
    );
    test(
      '(-32)^(2/5) = 4',
      () => expect(CalculatorEngine.calculate('(-32)^(2/5)'), '4'),
    );
    test(
      '(-16)^(1/2) is error',
      () => expect(
        () => CalculatorEngine.calculate('(-16)^(1/2)'),
        throwsArgumentError,
      ),
    );
    test(
      '(-8)^(1/2) is error',
      () => expect(
        () => CalculatorEngine.calculate('(-8)^(1/2)'),
        throwsArgumentError,
      ),
    );
  });

  group('MathEngine - Factorial', () {
    test('0! = 1', () => expect(CalculatorEngine.calculate('0!'), '1'));
    test('1! = 1', () => expect(CalculatorEngine.calculate('1!'), '1'));
    test('5! = 120', () => expect(CalculatorEngine.calculate('5!'), '120'));
    test(
      '10! = 3628800',
      () => expect(CalculatorEngine.calculate('10!'), '3628800'),
    );
  });

  group('MathEngine - Constants', () {
    test(
      'pi',
      () => expect(
        double.parse(CalculatorEngine.calculate('pi')),
        closeTo(math.pi, 1e-10),
      ),
    );
    test(
      '2pi',
      () => expect(
        double.parse(CalculatorEngine.calculate('2pi')),
        closeTo(2 * math.pi, 1e-10),
      ),
    );
    test(
      'e',
      () => expect(
        double.parse(CalculatorEngine.calculate('e')),
        closeTo(math.e, 1e-10),
      ),
    );
    test(
      '2e',
      () => expect(
        double.parse(CalculatorEngine.calculate('2e')),
        closeTo(2 * math.e, 1e-10),
      ),
    );
  });

  group('MathEngine - Abs', () {
    test(
      'abs(-5) = 5',
      () => expect(CalculatorEngine.calculate('abs(-5)'), '5'),
    );
    test('abs(5) = 5', () => expect(CalculatorEngine.calculate('abs(5)'), '5'));
  });

  group('MathEngine - Errors', () {
    test(
      '1 / 0',
      () =>
          expect(() => CalculatorEngine.calculate('1/0'), throwsArgumentError),
    );
    test(
      'sqrt(-1)',
      () => expect(
        () => CalculatorEngine.calculate('sqrt(-1)'),
        throwsArgumentError,
      ),
    );
    test(
      'log(0)',
      () => expect(
        () => CalculatorEngine.calculate('log(0)'),
        throwsArgumentError,
      ),
    );
    test(
      'ln(0)',
      () => expect(
        () => CalculatorEngine.calculate('ln(0)'),
        throwsArgumentError,
      ),
    );
    test(
      'log(-1)',
      () => expect(
        () => CalculatorEngine.calculate('log(-1)'),
        throwsArgumentError,
      ),
    );
    test(
      '(-1)!',
      () => expect(
        () => CalculatorEngine.calculate('(-1)!'),
        throwsArgumentError,
      ),
    );
    test(
      '2.5!',
      () =>
          expect(() => CalculatorEngine.calculate('2.5!'), throwsArgumentError),
    );
    test(
      'unknownFunction(5)',
      () => expect(
        () => CalculatorEngine.calculate('unknownFunction(5)'),
        throwsFormatException,
      ),
    );
  });

  group('MathEngine - Parser Implicit & Complex', () {
    test(
      '2pi',
      () => expect(
        double.parse(CalculatorEngine.calculate('2pi')),
        closeTo(2 * math.pi, 1e-10),
      ),
    );
    test('2(3+4)', () => expect(CalculatorEngine.calculate('2(3+4)'), '14'));
    test(
      '(2+3)(4+5)',
      () => expect(CalculatorEngine.calculate('(2+3)(4+5)'), '45'),
    );
    test(
      '3sin(30)',
      () => expect(
        double.parse(CalculatorEngine.calculate('3sin(30)')),
        closeTo(1.5, 1e-10),
      ),
    );
    test(
      'sqrt(9+7)',
      () => expect(CalculatorEngine.calculate('sqrt(9+7)'), '4'),
    );
    test(
      '2^3^2',
      () => expect(CalculatorEngine.calculate('2^3^2'), '512'),
    ); // right associative 3^2=9 -> 2^9=512
  });

  group('MathEngine - Scientific Notation', () {
    test('1e3', () => expect(CalculatorEngine.calculate('1e3'), '1000'));
    test('1e-3', () => expect(CalculatorEngine.calculate('1e-3'), '0.001'));
    test('1.5e4', () => expect(CalculatorEngine.calculate('1.5e4'), '15000'));
    test('2.5e+3', () => expect(CalculatorEngine.calculate('2.5e+3'), '2500'));
    test('1E3', () => expect(CalculatorEngine.calculate('1E3'), '1000'));
  });

  group('MathEngine - Parser Edge Tests', () {
    test('-2', () => expect(CalculatorEngine.calculate('-2'), '-2'));
    test('(-2)', () => expect(CalculatorEngine.calculate('(-2)'), '-2'));
    test('-2^2', () => expect(CalculatorEngine.calculate('-2^2'), '-4'));
    test('(-2)^2', () => expect(CalculatorEngine.calculate('(-2)^2'), '4'));
    test('2^-3', () => expect(CalculatorEngine.calculate('2^-3'), '0.125'));
    test('2^(-3)', () => expect(CalculatorEngine.calculate('2^(-3)'), '0.125'));
    test(
      '2e',
      () => expect(
        double.parse(CalculatorEngine.calculate('2e')),
        closeTo(2 * math.e, 1e-10),
      ),
    );
    test(
      'sin(-30)',
      () => expect(CalculatorEngine.calculate('sin(-30)'), '-0.5'),
    );
    test(
      'sqrt(abs(-16))',
      () => expect(CalculatorEngine.calculate('sqrt(abs(-16))'), '4'),
    );
    test(
      'log(sqrt(10000))',
      () => expect(CalculatorEngine.calculate('log(sqrt(10000))'), '2'),
    );
    test('sin(30 + 15)', () {
      expect(
        double.parse(CalculatorEngine.calculate('sin(30+15)')),
        closeTo(math.sin(45 * math.pi / 180), 1e-10),
      );
    });
  });

  group('MathEngine - Malformed Input Tests', () {
    test('empty string', () => expect(CalculatorEngine.calculate(''), '0'));
    test(
      '(',
      () =>
          expect(() => CalculatorEngine.calculate('('), throwsFormatException),
    );
    test(
      ')',
      () =>
          expect(() => CalculatorEngine.calculate(')'), throwsFormatException),
    );
    test(
      '((',
      () =>
          expect(() => CalculatorEngine.calculate('(('), throwsFormatException),
    );
    test(
      '2+',
      () =>
          expect(() => CalculatorEngine.calculate('2+'), throwsFormatException),
    );
    test('+2', () => expect(CalculatorEngine.calculate('+2'), '2'));
    test(
      '2**',
      () => expect(
        () => CalculatorEngine.calculate('2**'),
        throwsFormatException,
      ),
    );
    test(
      '2//',
      () => expect(
        () => CalculatorEngine.calculate('2//'),
        throwsFormatException,
      ),
    );
    test(
      '2^^3',
      () => expect(
        () => CalculatorEngine.calculate('2^^3'),
        throwsFormatException,
      ),
    );
    test(
      'sin(',
      () => expect(
        () => CalculatorEngine.calculate('sin('),
        throwsFormatException,
      ),
    );
    test(
      'sin()',
      () => expect(
        () => CalculatorEngine.calculate('sin()'),
        throwsFormatException,
      ),
    );
    test(
      'unknown(5)',
      () => expect(
        () => CalculatorEngine.calculate('unknown(5)'),
        throwsFormatException,
      ),
    );

    // '1e' is validly parsed as 1 * e due to implicit multiplication.
    test(
      '1e',
      () => expect(
        double.parse(CalculatorEngine.calculate('1e')),
        closeTo(math.e, 1e-10),
      ),
    );

    test(
      '1e+',
      () => expect(
        () => CalculatorEngine.calculate('1e+'),
        throwsFormatException,
      ),
    );
    test(
      '1e-',
      () => expect(
        () => CalculatorEngine.calculate('1e-'),
        throwsFormatException,
      ),
    );
    test(
      '1.2.3',
      () => expect(
        () => CalculatorEngine.calculate('1.2.3'),
        throwsFormatException,
      ),
    );
    test('5!', () => expect(CalculatorEngine.calculate('5!'), '120'));
    test(
      '!',
      () =>
          expect(() => CalculatorEngine.calculate('!'), throwsFormatException),
    );
  });
}
