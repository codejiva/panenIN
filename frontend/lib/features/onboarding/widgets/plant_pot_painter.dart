// lib/features/onboarding/widgets/plant_pot_painter.dart
import 'package:flutter/material.dart';

class PlantPotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw pot
    final pot = Path()
      ..moveTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.95)
      ..lineTo(size.width * 0.6, size.height * 0.95)
      ..lineTo(size.width * 0.8, size.height * 0.6)
      ..close();

    canvas.drawPath(pot, paint);

    // Draw plant
    final plant = Path()
      ..moveTo(size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.2);

    canvas.drawPath(plant, paint);

    final plant2 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.3);

    canvas.drawPath(plant2, paint);

    final plant3 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.45)
      ..lineTo(size.width * 0.3, size.height * 0.35);

    canvas.drawPath(plant3, paint);

    final plant4 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.7, size.height * 0.4);

    canvas.drawPath(plant4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}