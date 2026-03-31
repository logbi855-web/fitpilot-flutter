import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

const _ringGradientColors = [
  Color(0xFF4DD0E1), // cyan
  Color(0xFF818CF8), // blue-purple
  Color(0xFFA78BFA), // purple
  Color(0xFF4DD0E1), // back to cyan (seamless loop)
];

/// Animated circular ring progress chart for the water tracker.
class WaterRing extends StatefulWidget {
  final int totalMl;
  final int goalMl;

  const WaterRing({super.key, required this.totalMl, required this.goalMl});

  @override
  State<WaterRing> createState() => _WaterRingState();
}

class _WaterRingState extends State<WaterRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;
  double _prevProgress = 0;

  double get _targetProgress =>
      widget.goalMl > 0
          ? (widget.totalMl / widget.goalMl).clamp(0.0, 1.0)
          : 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _animation = Tween<double>(begin: 0, end: _targetProgress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _prevProgress = _targetProgress;
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(WaterRing old) {
    super.didUpdateWidget(old);
    final newProgress = _targetProgress;
    if ((newProgress - _prevProgress).abs() > 0.001) {
      _animation = Tween<double>(begin: _prevProgress, end: newProgress)
          .animate(
              CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
      _prevProgress = newProgress;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final progress = _animation.value;
          return CustomPaint(
            painter: _RingPainter(progress: progress),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.totalMl} ml',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16,
    );

    // Progress arc (gradient cyan → purple)
    if (progress > 0) {
      final arcRect = Rect.fromCircle(center: center, radius: radius);
      final shader = const SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: _ringGradientColors,
        stops: [0.0, 0.33, 0.66, 1.0],
      ).createShader(arcRect);

      canvas.drawArc(
        arcRect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}
