import 'package:flutter/material.dart';
import '../../domain/math_engine.dart';

class GraphCanvas extends StatelessWidget {
  final String expression;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  const GraphCanvas({
    super.key,
    required this.expression,
    this.xMin = -10,
    this.xMax = 10,
    this.yMin = -10,
    this.yMax = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: CustomPaint(
        painter: _GraphPainter(
          expression: expression,
          xMin: xMin,
          xMax: xMax,
          yMin: yMin,
          yMax: yMax,
          isDark: isDark,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final String expression;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final bool isDark;

  _GraphPainter({
    required this.expression,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw background
    final bgPaint = Paint()..color = isDark ? const Color(0xFF16191F) : const Color(0xFFF0F4F8);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black12)
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = (isDark ? Colors.white38 : Colors.black38)
      ..strokeWidth = 1.5;

    final curvePaint = Paint()
      ..color = const Color(0xFF0091EA)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Coordinate mapping functions
    double toScreenX(double x) => ((x - xMin) / (xMax - xMin)) * w;
    double toScreenY(double y) => h - (((y - yMin) / (yMax - yMin)) * h);

    // Draw axes
    final screenOriginX = toScreenX(0);
    final screenOriginY = toScreenY(0);

    // Grid lines
    for (double x = xMin.ceilToDouble(); x <= xMax; x += 2) {
      final sx = toScreenX(x);
      canvas.drawLine(Offset(sx, 0), Offset(sx, h), gridPaint);
    }
    for (double y = yMin.ceilToDouble(); y <= yMax; y += 2) {
      final sy = toScreenY(y);
      canvas.drawLine(Offset(0, sy), Offset(w, sy), gridPaint);
    }

    if (screenOriginX >= 0 && screenOriginX <= w) {
      canvas.drawLine(Offset(screenOriginX, 0), Offset(screenOriginX, h), axisPaint);
    }
    if (screenOriginY >= 0 && screenOriginY <= h) {
      canvas.drawLine(Offset(0, screenOriginY), Offset(w, screenOriginY), axisPaint);
    }

    // Plot function curve
    if (expression.trim().isNotEmpty) {
      final path = Path();
      bool isFirst = true;
      final step = (xMax - xMin) / 200.0;

      for (double x = xMin; x <= xMax; x += step) {
        try {
          final substituted = expression
              .replaceAll('x', '($x)')
              .replaceAll('X', '($x)');
          final yStr = MathEngine.evaluate(substituted);
          final y = double.tryParse(yStr);

          if (y != null && !y.isNaN && !y.isInfinite && y >= yMin * 2 && y <= yMax * 2) {
            final sx = toScreenX(x);
            final sy = toScreenY(y);
            if (isFirst) {
              path.moveTo(sx, sy);
              isFirst = false;
            } else {
              path.lineTo(sx, sy);
            }
          } else {
            isFirst = true;
          }
        } catch (_) {
          isFirst = true;
        }
      }

      canvas.drawPath(path, curvePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.expression != expression ||
        oldDelegate.xMin != xMin ||
        oldDelegate.xMax != xMax ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.isDark != isDark;
  }
}
