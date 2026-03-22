import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/progress_entry.dart';

/// 7-bar mini bar chart for weekly workout progress.
class WeeklyChart extends StatelessWidget {
  final List<ProgressEntry> entries; // last 7 days

  const WeeklyChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _BarChartPainter(entries: entries),
        size: Size.infinite,
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ProgressEntry> entries;
  const _BarChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final maxVal = entries
        .map((e) => e.caloriesBurned)
        .fold<int>(1, (a, b) => b > a ? b : a);

    final barWidth = size.width / entries.length - 4;
    final paint = Paint()..color = AppColors.primary;

    for (int i = 0; i < entries.length; i++) {
      final frac = entries[i].caloriesBurned / maxVal;
      final barHeight = (size.height - 4) * frac;
      final x = i * (barWidth + 4);
      final y = size.height - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.entries != entries;
}
