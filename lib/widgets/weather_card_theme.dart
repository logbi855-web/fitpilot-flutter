import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Condition enum ─────────────────────────────────────────────────────────────

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  drizzle,
  stormy,
  snowy,
  foggy,
  nightClear,
  nightCloudy,
}

// ── Theme data ─────────────────────────────────────────────────────────────────

class WeatherTheme {
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final Color glowColor;
  final String emoji;
  final WeatherCondition condition;

  const WeatherTheme({
    required this.gradientColors,
    required this.gradientStops,
    required this.glowColor,
    required this.emoji,
    required this.condition,
  });
}

// ── Mapper ─────────────────────────────────────────────────────────────────────

class WeatherThemeMapper {
  WeatherThemeMapper._();

  /// Returns the [WeatherTheme] for the given OWM [code].
  /// Pass [isNight] true when the OWM icon string ends with 'n'.
  static WeatherTheme fromCode(int? code, {bool isNight = false}) {
    final condition = code == null
        ? WeatherCondition.cloudy
        : _condition(code, isNight: isNight);
    return _themes[condition] ?? _themes[WeatherCondition.cloudy]!;
  }

  static WeatherCondition _condition(int code, {bool isNight = false}) {
    if (isNight) {
      if (code == 800) return WeatherCondition.nightClear;
      if (code <= 802) return WeatherCondition.nightCloudy;
    }
    if (code >= 200 && code < 300) return WeatherCondition.stormy;
    if (code >= 300 && code < 400) return WeatherCondition.drizzle;
    if (code >= 500 && code < 600) return WeatherCondition.rainy;
    if (code >= 600 && code < 700) return WeatherCondition.snowy;
    if (code >= 700 && code < 800) return WeatherCondition.foggy;
    if (code == 800) return WeatherCondition.sunny;
    if (code <= 802) return WeatherCondition.partlyCloudy;
    return WeatherCondition.cloudy;
  }

  static const Map<WeatherCondition, WeatherTheme> _themes = {
    WeatherCondition.sunny: WeatherTheme(
      // Deep purple → warm amber
      gradientColors: [Color(0xFF221200), Color(0xFF3A2000), Color(0xFF160A00)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFFFFB74D),
      emoji: '☀️',
      condition: WeatherCondition.sunny,
    ),
    WeatherCondition.partlyCloudy: WeatherTheme(
      // Warm purple tint
      gradientColors: [Color(0xFF1F1840), Color(0xFF2D2050), Color(0xFF130E20)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFFFFCC80),
      emoji: '🌤',
      condition: WeatherCondition.partlyCloudy,
    ),
    WeatherCondition.cloudy: WeatherTheme(
      // Cool blue-grey
      gradientColors: [Color(0xFF101520), Color(0xFF1A2032), Color(0xFF080C14)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFF90A4AE),
      emoji: '☁️',
      condition: WeatherCondition.cloudy,
    ),
    WeatherCondition.rainy: WeatherTheme(
      // Deep ocean blue
      gradientColors: [Color(0xFF051525), Color(0xFF0A2040), Color(0xFF03101E)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFF4FC3F7),
      emoji: '🌧',
      condition: WeatherCondition.rainy,
    ),
    WeatherCondition.drizzle: WeatherTheme(
      // Muted blue
      gradientColors: [Color(0xFF081828), Color(0xFF102438), Color(0xFF05101C)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFF81D4FA),
      emoji: '🌦',
      condition: WeatherCondition.drizzle,
    ),
    WeatherCondition.stormy: WeatherTheme(
      // Near-black with a purple tinge
      gradientColors: [Color(0xFF08080F), Color(0xFF10101C), Color(0xFF050508)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFFCE93D8),
      emoji: '⛈',
      condition: WeatherCondition.stormy,
    ),
    WeatherCondition.snowy: WeatherTheme(
      // Cool ice-blue
      gradientColors: [Color(0xFF0D1525), Color(0xFF162030), Color(0xFF080F1A)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFFB2EBF2),
      emoji: '❄️',
      condition: WeatherCondition.snowy,
    ),
    WeatherCondition.foggy: WeatherTheme(
      // Muted grey-purple
      gradientColors: [Color(0xFF0E1218), Color(0xFF181E24), Color(0xFF08090E)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFF78909C),
      emoji: '🌫',
      condition: WeatherCondition.foggy,
    ),
    WeatherCondition.nightClear: WeatherTheme(
      // Deep indigo-black
      gradientColors: [Color(0xFF050010), Color(0xFF0A0025), Color(0xFF020008)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFFB39DDB),
      emoji: '🌙',
      condition: WeatherCondition.nightClear,
    ),
    WeatherCondition.nightCloudy: WeatherTheme(
      // Deep purple-black
      gradientColors: [Color(0xFF07001A), Color(0xFF0C0525), Color(0xFF030008)],
      gradientStops: [0.0, 0.5, 1.0],
      glowColor: Color(0xFF7E57C2),
      emoji: '🌙',
      condition: WeatherCondition.nightCloudy,
    ),
  };
}

// ── WeatherIconWidget ──────────────────────────────────────────────────────────

/// Renders a weather emoji inside a glowing rounded container.
class WeatherIconWidget extends StatelessWidget {
  final WeatherTheme theme;

  /// Overall container size in logical pixels.
  final double size;

  const WeatherIconWidget({super.key, required this.theme, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: RadialGradient(
          colors: [
            theme.glowColor.withValues(alpha: 0.28),
            theme.glowColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: theme.glowColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          theme.emoji,
          style: TextStyle(fontSize: size * 0.52),
        ),
      ),
    );
  }
}

// ── WeatherParticles ───────────────────────────────────────────────────────────

/// Subtle looping particle overlay — rain drops, snowflakes, or twinkling stars.
/// Intended to fill a clipped container (e.g. [ClipRRect] or [clipBehavior]).
class WeatherParticles extends StatefulWidget {
  final WeatherCondition condition;

  const WeatherParticles({super.key, required this.condition});

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.condition) {
      case WeatherCondition.rainy:
      case WeatherCondition.drizzle:
      case WeatherCondition.stormy:
        final drops =
            widget.condition == WeatherCondition.rainy ? 22 : 11;
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _RainPainter(progress: _ctrl.value, drops: drops),
            size: Size.infinite,
          ),
        );
      case WeatherCondition.snowy:
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _SnowPainter(progress: _ctrl.value),
            size: Size.infinite,
          ),
        );
      case WeatherCondition.nightClear:
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _StarsPainter(progress: _ctrl.value),
            size: Size.infinite,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Particle painters ──────────────────────────────────────────────────────────

class _RainPainter extends CustomPainter {
  final double progress;
  final int drops;

  const _RainPainter({required this.progress, required this.drops});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.14)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < drops; i++) {
      final x = (i * 47.3 + 11.7) % size.width;
      final baseY = (i * 71.1 + 5.3) % size.height;
      final y = (baseY + progress * size.height) % size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 1.5, y + 9.0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter old) => old.progress != progress;
}

class _SnowPainter extends CustomPainter {
  final double progress;

  const _SnowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.20);

    for (int i = 0; i < 15; i++) {
      final x = (i * 51.7 + 7.3) % size.width;
      final baseY = (i * 63.1 + 3.9) % size.height;
      final y = (baseY + progress * 0.35 * size.height) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter old) => old.progress != progress;
}

class _StarsPainter extends CustomPainter {
  final double progress;

  const _StarsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 15; i++) {
      final x = (i * 73.9 + 13.7) % size.width;
      final y = (i * 59.3 + 9.1) % (size.height * 0.70);
      final phase = (i * 0.37) % 1.0;
      final twinkle =
          math.sin((progress + phase) * 2 * math.pi) * 0.5 + 0.5;
      canvas.drawCircle(
        Offset(x, y),
        0.8 + twinkle * 0.8,
        Paint()..color = Colors.white.withValues(alpha: 0.06 + twinkle * 0.14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => old.progress != progress;
}
