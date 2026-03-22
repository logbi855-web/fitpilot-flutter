import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Half-circle BMI gauge with animated needle, matching the JS SVG arc.
class BmiGauge extends StatelessWidget {
  final double? bmi;

  const BmiGauge({super.key, this.bmi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _BmiGaugePainter(bmi: bmi),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              bmi != null ? bmi!.toStringAsFixed(1) : '--',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  final double? bmi;
  const _BmiGaugePainter({this.bmi});

  static const _segments = [
    (max: 18.5, color: Color(0xFF818CF8)), // under
    (max: 25.0, color: Color(0xFF4ADE80)), // healthy
    (max: 30.0, color: Color(0xFFFBBF24)), // over
    (max: 45.0, color: Color(0xFFFF5C5C)), // obese
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final radius = size.width / 2 - 8;

    const totalRange = 45.0 - 10.0; // BMI 10–45
    double startAngle = pi;
    double prevMax = 10.0;

    final segPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;

    for (final seg in _segments) {
      final fraction = (seg.max - prevMax) / totalRange;
      final sweep = pi * fraction;
      segPaint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweep,
        false,
        segPaint,
      );
      startAngle += sweep;
      prevMax = seg.max;
    }

    // Needle
    if (bmi != null) {
      final clamped = bmi!.clamp(10.0, 45.0);
      final fraction = (clamped - 10) / totalRange;
      final angle = pi + pi * fraction;
      final needleLen = radius - 6;
      final nx = cx + needleLen * cos(angle);
      final ny = cy + needleLen * sin(angle);

      final needlePaint = Paint()
        ..color = AppColors.text
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, cy), Offset(nx, ny), needlePaint);

      canvas.drawCircle(
        Offset(cx, cy),
        5,
        Paint()..color = AppColors.text,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BmiGaugePainter old) => old.bmi != bmi;
}
