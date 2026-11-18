import 'dart:math' as math;

/// Pure-Dart Linear Algebra engine for matrix inversion, eigenvalues,
/// Gaussian elimination, vector projections, and multivariable systems.
class LinearAlgebraEngine {
  LinearAlgebraEngine._();

  /// Computes eigenvalues and trace/determinant for 2x2 matrix:
  /// [ a  b ]
  /// [ c  d ]
  static Map<String, dynamic> eigenvalues2x2(
    double a,
    double b,
    double c,
    double d,
  ) {
    final trace = a + d;
    final det = a * d - b * c;

    // Characteristic equation: λ^2 - (trace)λ + det = 0
    final discriminant = trace * trace - 4 * det;

    if (discriminant >= 0) {
      final sqrtDisc = math.sqrt(discriminant);
      final lambda1 = (trace + sqrtDisc) / 2;
      final lambda2 = (trace - sqrtDisc) / 2;

      return {
        'isReal': true,
        'trace': trace,
        'determinant': det,
        'lambda1': lambda1,
        'lambda2': lambda2,
        'eigenvaluesString': 'λ₁ = ${lambda1.toStringAsFixed(4)}, λ₂ = ${lambda2.toStringAsFixed(4)}',
        'characteristicEq': 'λ² - (${trace.toStringAsFixed(2)})λ + (${det.toStringAsFixed(2)}) = 0',
      };
    } else {
      final realPart = trace / 2;
      final imagPart = math.sqrt(-discriminant) / 2;

      return {
        'isReal': false,
        'trace': trace,
        'determinant': det,
        'realPart': realPart,
        'imagPart': imagPart,
        'eigenvaluesString': 'λ = ${realPart.toStringAsFixed(4)} ± ${imagPart.toStringAsFixed(4)}i',
        'characteristicEq': 'λ² - (${trace.toStringAsFixed(2)})λ + (${det.toStringAsFixed(2)}) = 0',
      };
    }
  }

  /// Inverts 2x2 matrix:
  /// [ a  b ]^-1 = (1/det) * [  d  -b ]
  /// [ c  d ]                [ -c   a ]
  static Map<String, dynamic> inverse2x2(
    double a,
    double b,
    double c,
    double d,
  ) {
    final det = a * d - b * c;
    if (det.abs() < 1e-12) {
      return {
        'isInvertible': false,
        'determinant': det,
        'error': 'Matrix is singular (determinant is 0). Inverse does not exist.',
      };
    }

    final invDet = 1.0 / det;
    final iA = d * invDet;
    final iB = -b * invDet;
    final iC = -c * invDet;
    final iD = a * invDet;

    return {
      'isInvertible': true,
      'determinant': det,
      'invMatrix': [
        [iA, iB],
        [iC, iD]
      ],
      'matrixString': '[ ${iA.toStringAsFixed(3)}, ${iB.toStringAsFixed(3)} ]\n[ ${iC.toStringAsFixed(3)}, ${iD.toStringAsFixed(3)} ]',
    };
  }

  /// Solves 2x2 linear system using Cramer's rule:
  /// a1*x + b1*y = c1
  /// a2*x + b2*y = c2
  static Map<String, dynamic> solveLinear2x2(
    double a1,
    double b1,
    double c1,
    double a2,
    double b2,
    double c2,
  ) {
    final D = a1 * b2 - a2 * b1;
    final Dx = c1 * b2 - c2 * b1;
    final Dy = a1 * c2 - a2 * c1;

    if (D.abs() < 1e-12) {
      if (Dx.abs() < 1e-12 && Dy.abs() < 1e-12) {
        return {
          'hasUniqueSolution': false,
          'status': 'Infinitely Many Solutions (Dependent System)',
          'x': double.nan,
          'y': double.nan,
        };
      } else {
        return {
          'hasUniqueSolution': false,
          'status': 'No Solution (Inconsistent System)',
          'x': double.nan,
          'y': double.nan,
        };
      }
    }

    final x = Dx / D;
    final y = Dy / D;

    return {
      'hasUniqueSolution': true,
      'status': 'Unique Solution',
      'x': x,
      'y': y,
      'D': D,
      'Dx': Dx,
      'Dy': Dy,
      'solutionString': 'x = ${x.toStringAsFixed(4)}, y = ${y.toStringAsFixed(4)}',
    };
  }

  /// Solves 3x3 linear system using Gaussian Elimination with partial pivoting:
  /// A * X = B
  static Map<String, dynamic> solveLinear3x3(
    List<List<double>> A,
    List<double> B,
  ) {
    // Create augmented matrix [A | B]
    final mat = List.generate(3, (i) => [...A[i], B[i]]);

    for (int col = 0; col < 3; col++) {
      // Find pivot
      int maxRow = col;
      double maxVal = mat[col][col].abs();
      for (int r = col + 1; r < 3; r++) {
        if (mat[r][col].abs() > maxVal) {
          maxVal = mat[r][col].abs();
          maxRow = r;
        }
      }

      if (maxVal < 1e-12) {
        return {
          'hasUniqueSolution': false,
          'error': 'System has no unique solution (Singular coefficient matrix)',
        };
      }

      // Swap rows
      if (maxRow != col) {
        final temp = mat[col];
        mat[col] = mat[maxRow];
        mat[maxRow] = temp;
      }

      // Eliminate below
      for (int r = col + 1; r < 3; r++) {
        final factor = mat[r][col] / mat[col][col];
        for (int c = col; c <= 3; c++) {
          mat[r][c] -= factor * mat[col][c];
        }
      }
    }

    // Back substitution
    final X = List.filled(3, 0.0);
    for (int i = 2; i >= 0; i--) {
      double sum = mat[i][3];
      for (int j = i + 1; j < 3; j++) {
        sum -= mat[i][j] * X[j];
      }
      X[i] = sum / mat[i][i];
    }

    return {
      'hasUniqueSolution': true,
      'x': X[0],
      'y': X[1],
      'z': X[2],
      'solutionString': 'x = ${X[0].toStringAsFixed(4)}, y = ${X[1].toStringAsFixed(4)}, z = ${X[2].toStringAsFixed(4)}',
    };
  }

  /// Computes vector projection of v onto u, scalar projection, and angle:
  /// proj_u(v) = ((u · v) / ||u||^2) * u
  static Map<String, dynamic> vectorProjection({
    required List<double> u,
    required List<double> v,
  }) {
    double dot = 0;
    double normU2 = 0;
    double normV2 = 0;

    final n = math.min(u.length, v.length);
    for (int i = 0; i < n; i++) {
      dot += u[i] * v[i];
      normU2 += u[i] * u[i];
      normV2 += v[i] * v[i];
    }

    final normU = math.sqrt(normU2);
    final normV = math.sqrt(normV2);

    if (normU < 1e-12 || normV < 1e-12) {
      return {
        'error': 'One or both vectors have zero length',
        'proj': List.filled(n, 0.0),
        'scalarProj': 0.0,
        'angleDeg': 0.0,
      };
    }

    final scalarProj = dot / normU;
    final factor = dot / normU2;
    final proj = List.generate(n, (i) => factor * u[i]);

    final cosTheta = (dot / (normU * normV)).clamp(-1.0, 1.0);
    final angleRad = math.acos(cosTheta);
    final angleDeg = angleRad * (180.0 / math.pi);

    return {
      'u': u,
      'v': v,
      'dotProduct': dot,
      'normU': normU,
      'normV': normV,
      'scalarProjection': scalarProj,
      'projectionVector': proj,
      'angleDegrees': angleDeg,
      'angleRadians': angleRad,
    };
  }

  /// Cross and Dot product for 3D vectors:
  static Map<String, dynamic> crossAndDotProduct(
    List<double> u,
    List<double> v,
  ) {
    final ux = u.isNotEmpty ? u[0] : 0.0;
    final uy = u.length > 1 ? u[1] : 0.0;
    final uz = u.length > 2 ? u[2] : 0.0;

    final vx = v.isNotEmpty ? v[0] : 0.0;
    final vy = v.length > 1 ? v[1] : 0.0;
    final vz = v.length > 2 ? v[2] : 0.0;

    final dot = ux * vx + uy * vy + uz * vz;

    // Cross product: (uy*vz - uz*vy, uz*vx - ux*vz, ux*vy - uy*vx)
    final cx = uy * vz - uz * vy;
    final cy = uz * vx - ux * vz;
    final cz = ux * vy - uy * vx;

    final crossMag = math.sqrt(cx * cx + cy * cy + cz * cz);
    final magU = math.sqrt(ux * ux + uy * uy + uz * uz);
    final magV = math.sqrt(vx * vx + vy * vy + vz * vz);

    double angleDeg = 0;
    if (magU > 1e-12 && magV > 1e-12) {
      final cosTheta = (dot / (magU * magV)).clamp(-1.0, 1.0);
      angleDeg = math.acos(cosTheta) * (180.0 / math.pi);
    }

    return {
      'dotProduct': dot,
      'crossProduct': [cx, cy, cz],
      'crossMagnitude': crossMag,
      'magU': magU,
      'magV': magV,
      'angleDegrees': angleDeg,
      'parallelogramArea': crossMag,
      'triangleArea': crossMag / 2.0,
    };
  }
}
