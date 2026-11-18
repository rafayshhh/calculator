import 'dart:math' as math;

/// Pure-Dart Geometry Engine for 2D polygons, conic sections, and 3D solids.
class Geometry3DEngine {
  Geometry3DEngine._();

  /// Solves a triangle from 3 known sides (SSS):
  static Map<String, dynamic> solveTriangleSSS(double a, double b, double c) {
    if (a + b <= c || a + c <= b || b + c <= a) {
      return {'isValid': false, 'error': 'Triangle Inequality violated: sum of any 2 sides must be greater than third side.'};
    }

    final s = (a + b + c) / 2.0;
    final area = math.sqrt(s * (s - a) * (s - b) * (s - c));

    // Law of cosines: cos(A) = (b^2 + c^2 - a^2) / (2bc)
    final cosA = ((b * b + c * c - a * a) / (2 * b * c)).clamp(-1.0, 1.0);
    final cosB = ((a * a + c * c - b * b) / (2 * a * c)).clamp(-1.0, 1.0);
    final cosC = ((a * a + b * b - c * c) / (2 * a * b)).clamp(-1.0, 1.0);

    final angleADeg = math.acos(cosA) * (180.0 / math.pi);
    final angleBDeg = math.acos(cosB) * (180.0 / math.pi);
    final angleCDeg = math.acos(cosC) * (180.0 / math.pi);

    final inradius = area / s;
    final circumradius = (a * b * c) / (4.0 * area);

    return {
      'isValid': true,
      'a': a,
      'b': b,
      'c': c,
      'angleA': angleADeg,
      'angleB': angleBDeg,
      'angleC': angleCDeg,
      'perimeter': a + b + c,
      'semiperimeter': s,
      'area': area,
      'inradius': inradius,
      'circumradius': circumradius,
    };
  }

  /// Circle geometry metrics:
  static Map<String, dynamic> circleMetrics(double radius, {double angleDeg = 360.0}) {
    final diameter = 2 * radius;
    final circumference = 2 * math.pi * radius;
    final area = math.pi * radius * radius;
    final fraction = angleDeg / 360.0;
    final arcLength = 2 * math.pi * radius * fraction;
    final sectorArea = area * fraction;

    return {
      'radius': radius,
      'diameter': diameter,
      'circumference': circumference,
      'area': area,
      'arcLength': arcLength,
      'sectorArea': sectorArea,
      'angleDeg': angleDeg,
    };
  }

  /// Regular n-sided polygon:
  static Map<String, dynamic> regularPolygon(int n, double sideLength) {
    if (n < 3) return {'error': 'Polygon must have at least 3 sides'};
    final perimeter = n * sideLength;
    final interiorAngle = (n - 2) * 180.0 / n;
    final exteriorAngle = 360.0 / n;
    final apothem = sideLength / (2 * math.tan(math.pi / n));
    final area = (perimeter * apothem) / 2.0;

    return {
      'n': n,
      'sideLength': sideLength,
      'perimeter': perimeter,
      'interiorAngleDeg': interiorAngle,
      'exteriorAngleDeg': exteriorAngle,
      'apothem': apothem,
      'area': area,
    };
  }

  /// Sphere & Hemisphere:
  static Map<String, dynamic> sphere(double radius) {
    final surfaceArea = 4 * math.pi * radius * radius;
    final volume = (4.0 / 3.0) * math.pi * math.pow(radius, 3);
    final hemisphereVol = volume / 2.0;
    final hemisphereArea = 3 * math.pi * radius * radius; // including circular base

    return {
      'radius': radius,
      'surfaceArea': surfaceArea,
      'volume': volume,
      'hemisphereVolume': hemisphereVol,
      'hemisphereSurfaceArea': hemisphereArea,
    };
  }

  /// Right circular cylinder:
  static Map<String, dynamic> cylinder(double radius, double height) {
    final baseArea = math.pi * radius * radius;
    final lateralArea = 2 * math.pi * radius * height;
    final totalArea = 2 * baseArea + lateralArea;
    final volume = baseArea * height;

    return {
      'radius': radius,
      'height': height,
      'baseArea': baseArea,
      'lateralArea': lateralArea,
      'totalArea': totalArea,
      'volume': volume,
    };
  }

  /// Right circular cone:
  static Map<String, dynamic> cone(double radius, double height) {
    final slantHeight = math.sqrt(radius * radius + height * height);
    final baseArea = math.pi * radius * radius;
    final lateralArea = math.pi * radius * slantHeight;
    final totalArea = baseArea + lateralArea;
    final volume = (1.0 / 3.0) * math.pi * radius * radius * height;

    return {
      'radius': radius,
      'height': height,
      'slantHeight': slantHeight,
      'baseArea': baseArea,
      'lateralArea': lateralArea,
      'totalArea': totalArea,
      'volume': volume,
    };
  }

  /// Rectangular pyramid:
  static Map<String, dynamic> pyramid(double baseLength, double baseWidth, double height) {
    final baseArea = baseLength * baseWidth;
    final slantLength = math.sqrt(height * height + math.pow(baseWidth / 2.0, 2));
    final slantWidth = math.sqrt(height * height + math.pow(baseLength / 2.0, 2));
    final lateralArea = baseLength * slantLength + baseWidth * slantWidth;
    final totalArea = baseArea + lateralArea;
    final volume = (1.0 / 3.0) * baseArea * height;

    return {
      'baseLength': baseLength,
      'baseWidth': baseWidth,
      'height': height,
      'baseArea': baseArea,
      'lateralArea': lateralArea,
      'totalArea': totalArea,
      'volume': volume,
    };
  }

  /// Rectangular prism:
  static Map<String, dynamic> prism(double length, double width, double height) {
    final surfaceArea = 2 * (length * width + length * height + width * height);
    final volume = length * width * height;
    final spaceDiagonal = math.sqrt(length * length + width * width + height * height);

    return {
      'length': length,
      'width': width,
      'height': height,
      'surfaceArea': surfaceArea,
      'volume': volume,
      'spaceDiagonal': spaceDiagonal,
    };
  }

  /// Ellipse geometry:
  static Map<String, dynamic> ellipse(double semiMajor, double semiMinor) {
    final a = math.max(semiMajor, semiMinor);
    final b = math.min(semiMajor, semiMinor);
    final area = math.pi * a * b;

    // Ramanujan second approximation for perimeter:
    final h = math.pow((a - b) / (a + b), 2);
    final perimeter = math.pi * (a + b) * (1 + (3 * h) / (10 + math.sqrt(4 - 3 * h)));

    final c = math.sqrt(a * a - b * b); // Linear eccentricity (focal distance)
    final eccentricity = a > 0 ? c / a : 0.0;

    return {
      'semiMajor': a,
      'semiMinor': b,
      'area': area,
      'perimeter': perimeter,
      'focalDistance': c,
      'eccentricity': eccentricity,
      'foci': '(-${c.toStringAsFixed(3)}, 0) and (${c.toStringAsFixed(3)}, 0)',
    };
  }

  /// Parabola: y = a*x^2 + b*x + c
  static Map<String, dynamic> parabola(double a, double b, double c) {
    if (a.abs() < 1e-12) return {'error': 'Coefficient "a" cannot be 0 in a parabola.'};

    final h = -b / (2 * a);
    final k = c - (b * b) / (4 * a);
    final focalLength = 1.0 / (4 * a);
    final focusY = k + focalLength;
    final directrixY = k - focalLength;

    return {
      'a': a,
      'b': b,
      'c': c,
      'vertex': '($h, $k)',
      'vertexX': h,
      'vertexY': k,
      'focus': '($h, $focusY)',
      'focusY': focusY,
      'directrix': 'y = $directrixY',
      'axisOfSymmetry': 'x = $h',
      'direction': a > 0 ? 'Opens Upward' : 'Opens Downward',
    };
  }

  /// Hyperbola: (x^2 / a^2) - (y^2 / b^2) = 1
  static Map<String, dynamic> hyperbola(double a, double b) {
    final c = math.sqrt(a * a + b * b);
    final eccentricity = c / a;
    final slope = b / a;

    return {
      'a': a,
      'b': b,
      'focalDistance': c,
      'eccentricity': eccentricity,
      'foci': '(-${c.toStringAsFixed(3)}, 0) and (${c.toStringAsFixed(3)}, 0)',
      'asymptotes': 'y = ±${slope.toStringAsFixed(3)}x',
    };
  }

  /// Torus: major radius R (center to tube center), minor radius r (tube radius)
  static Map<String, dynamic> torus(double majorR, double minorR) {
    if (minorR > majorR) return {'error': 'Minor radius r cannot be greater than major radius R for ring torus'};
    final surfaceArea = 4 * math.pi * math.pi * majorR * minorR;
    final volume = 2 * math.pi * math.pi * majorR * minorR * minorR;

    return {
      'majorRadius': majorR,
      'minorRadius': minorR,
      'surfaceArea': surfaceArea,
      'volume': volume,
    };
  }
}
