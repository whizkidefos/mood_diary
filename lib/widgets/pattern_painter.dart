import 'package:flutter/material.dart';
import 'dart:math' as math;

class PatternPainter extends CustomPainter {
  final Color color;
  final double spacing;

  PatternPainter({
    required this.color,
    this.spacing = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw dots pattern
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          1,
          paint,
        );
      }
    }

    // Draw subtle curved lines
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final startY = size.height / 5 * i;
      path.moveTo(0, startY);

      final controlPoint1 = Offset(
        size.width / 3,
        startY + math.sin(i * math.pi / 2) * 30,
      );

      final controlPoint2 = Offset(
        size.width * 2 / 3,
        startY - math.cos(i * math.pi / 2) * 30,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        size.width,
        startY,
      );
    }
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
