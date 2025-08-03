import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class AudioWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF48BB78)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final waveformData = [0.3, 0.8, 0.4, 0.9, 0.2, 0.7, 0.5, 0.8, 0.3, 0.6, 0.4, 0.9, 0.2, 0.7];
    final barWidth = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight = size.height * waveformData[i];
      final startY = (size.height - barHeight) / 2;
      final endY = startY + barHeight;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}