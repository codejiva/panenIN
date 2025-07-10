import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
          size.width * 0.25, size.height * 0.25,
          size.width * 0.5, size.height * 0.75,
          size.width, size.height * 0.5
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}