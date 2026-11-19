
/// Pure-Dart Number Theory & Discrete Mathematics Engine.
class NumberTheoryEngine {
  NumberTheoryEngine._();

  /// Prime factorization with multiplicities:
  static Map<String, dynamic> primeFactorization(int n) {
    if (n <= 1) {
      return {
        'n': n,
        'isPrime': false,
        'factors': <int, int>{},
        'canonicalString': n.toString(),
        'factorCount': 0,
      };
    }

    final original = n;
    final Map<int, int> factors = {};
    int temp = n;

    // Check factor 2
    while (temp % 2 == 0) {
      factors[2] = (factors[2] ?? 0) + 1;
      temp ~/= 2;
    }

    // Check odd factors up to sqrt(temp)
    int d = 3;
    while (d * d <= temp) {
      while (temp % d == 0) {
        factors[d] = (factors[d] ?? 0) + 1;
        temp ~/= d;
      }
      d += 2;
    }

    if (temp > 1) {
      factors[temp] = (factors[temp] ?? 0) + 1;
    }

    final isPrime = factors.length == 1 && factors.values.first == 1;
    final terms = factors.entries.map((e) => e.value > 1 ? '${e.key}^${e.value}' : '${e.key}').toList();

    return {
      'n': original,
      'isPrime': isPrime,
      'factors': factors,
      'canonicalString': terms.join(' × '),
      'distinctPrimesCount': factors.length,
      'totalPrimeFactors': factors.values.fold(0, (a, b) => a + b),
    };
  }

  /// Extended Euclidean Algorithm returning [gcd, x, y] such that a*x + b*y = gcd
  static List<int> extendedGcd(int a, int b) {
    if (b == 0) return [a, 1, 0];
    final res = extendedGcd(b, a % b);
    final gcd = res[0];
    final x1 = res[1];
    final y1 = res[2];
    final x = y1;
    final y = x1 - (a ~/ b) * y1;
    return [gcd, x, y];
  }

  /// Modular operations: addition, multiplication, exponentiation, and modular inverse:
  static Map<String, dynamic> modularArithmetic(int a, int b, int m) {
    if (m <= 0) return {'error': 'Modulus m must be positive'};

    final addMod = (a + b) % m;
    final subMod = ((a - b) % m + m) % m;
    final mulMod = ((a % m) * (b % m)) % m;

    // Modular exponentiation: a^b mod m
    int powerMod(int base, int exp, int mod) {
      int res = 1;
      base %= mod;
      int e = exp;
      while (e > 0) {
        if (e % 2 == 1) res = (res * base) % mod;
        base = (base * base) % mod;
        e ~/= 2;
      }
      return res;
    }

    final expMod = b >= 0 ? powerMod(a, b, m) : null;

    // Modular inverse of a mod m: a*x ≡ 1 (mod m)
    final egcd = extendedGcd(a, m);
    final gcdVal = egcd[0];
    int? inverse;
    if (gcdVal == 1) {
      inverse = (egcd[1] % m + m) % m;
    }

    return {
      'a': a,
      'b': b,
      'm': m,
      'addMod': addMod,
      'subMod': subMod,
      'mulMod': mulMod,
      'expMod': expMod,
      'gcd': gcdVal,
      'modularInverseA': inverse,
      'inverseString': inverse != null ? '$inverse' : 'Undefined (gcd($a, $m) = $gcdVal ≠ 1)',
    };
  }

  /// Collatz 3n+1 sequence trajectory:
  static Map<String, dynamic> collatzSequence(int startNumber, {int maxTerms = 1000}) {
    if (startNumber <= 0) return {'error': 'Starting number must be a positive integer'};

    final List<int> sequence = [startNumber];
    int current = startNumber;
    int peak = startNumber;

    while (current != 1 && sequence.length < maxTerms) {
      if (current % 2 == 0) {
        current ~/= 2;
      } else {
        current = 3 * current + 1;
      }
      sequence.add(current);
      if (current > peak) peak = current;
    }

    return {
      'startNumber': startNumber,
      'sequence': sequence,
      'stoppingTime': sequence.length - 1,
      'peakValue': peak,
      'reachedOne': sequence.last == 1,
    };
  }

  /// Fibonacci number and Golden Ratio convergence:
  static Map<String, dynamic> fibonacciAndGolden(int n) {
    if (n < 0) return {'error': 'Index n must be non-negative'};
    if (n > 70) return {'error': 'Index n too large for 64-bit integer calculations (max 70)'};

    final List<int> fibs = [0, 1];
    for (int i = 2; i <= n; i++) {
      fibs.add(fibs[i - 1] + fibs[i - 2]);
    }

    final fn = fibs[n];
    final fnMinus1 = n >= 1 ? fibs[n - 1] : null;
    final ratio = (fnMinus1 != null && fnMinus1 > 0) ? (fn.toDouble() / fnMinus1.toDouble()) : null;
    const goldenRatio = 1.618033988749895;
    final diff = ratio != null ? (ratio - goldenRatio).abs() : null;

    return {
      'n': n,
      'fibonacciN': fn,
      'ratio': ratio,
      'goldenRatio': goldenRatio,
      'difference': diff,
      'sequenceSlice': fibs.take(15).toList(),
    };
  }

  /// Solves linear Diophantine equation: ax + by = c
  static Map<String, dynamic> solveDiophantine(int a, int b, int c) {
    final egcd = extendedGcd(a, b);
    final g = egcd[0];
    final x0 = egcd[1];
    final y0 = egcd[2];

    if (c % g != 0) {
      return {
        'hasSolution': false,
        'gcd': g,
        'error': 'No integer solution: gcd($a, $b) = $g does not divide $c',
      };
    }

    final scale = c ~/ g;
    final baseSolutionX = x0 * scale;
    final baseSolutionY = y0 * scale;
    final stepX = b ~/ g;
    final stepY = -(a ~/ g);

    return {
      'hasSolution': true,
      'gcd': g,
      'baseX': baseSolutionX,
      'baseY': baseSolutionY,
      'stepX': stepX,
      'stepY': stepY,
      'generalSolution': 'x = $baseSolutionX + ($stepX)k, y = $baseSolutionY + ($stepY)k (for integer k)',
    };
  }

  /// Euler's Totient function: count of integers k in 1..n coprime to n
  static Map<String, dynamic> eulerTotient(int n) {
    if (n <= 0) return {'error': 'n must be positive'};
    if (n == 1) return {'n': 1, 'totient': 1, 'coprimesCount': 1};

    final factors = primeFactorization(n)['factors'] as Map<int, int>;
    double result = n.toDouble();

    for (final p in factors.keys) {
      result *= (1.0 - 1.0 / p);
    }

    final totient = result.round();
    return {
      'n': n,
      'totient': totient,
      'coprimesFraction': totient / n,
      'distinctPrimes': factors.keys.toList(),
    };
  }

  /// Chinese Remainder Theorem:
  /// x ≡ r_i (mod m_i) for pairwise coprime moduli
  static Map<String, dynamic> chineseRemainderTheorem(List<int> remainders, List<int> moduli) {
    if (remainders.length != moduli.length || remainders.isEmpty) {
      return {'isValid': false, 'error': 'Remainders and moduli lists must have the same non-zero length'};
    }

    int M = 1;
    for (final m in moduli) {
      if (m <= 0) return {'isValid': false, 'error': 'All moduli must be positive'};
      M *= m;
    }

    int x = 0;
    for (int i = 0; i < moduli.length; i++) {
      final m = moduli[i];
      final r = remainders[i];
      final Mi = M ~/ m;

      final egcd = extendedGcd(Mi, m);
      if (egcd[0] != 1) {
        return {'isValid': false, 'error': 'Moduli are not pairwise coprime (gcd($Mi, $m) ≠ 1)'};
      }
      final yi = (egcd[1] % m + m) % m;
      x = (x + r * Mi * yi) % M;
    }

    return {
      'isValid': true,
      'solution': (x % M + M) % M,
      'modulo': M,
      'solutionString': 'x ≡ ${(x % M + M) % M} (mod $M)',
    };
  }
}
