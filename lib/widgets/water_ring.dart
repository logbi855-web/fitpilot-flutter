import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

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

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = AppColors.primary
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
