import 'package:flutter/material.dart';

/// A premium icon widget with a gradient background, soft outer glow, and
/// an inner white Material icon. Drop-in replacement for flat [Icon] usage.
class GlowIcon extends StatelessWidget {
  final IconData icon;

  /// Width and height of the container.
  final double size;

  /// Two-stop gradient from lighter (top-left) to darker (bottom-right).
  final List<Color> colors;

  const GlowIcon({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 40,
  });

  // ── Named presets ──────────────────────────────────────────────────────────

  const GlowIcon.goal({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.flag_rounded,
          colors: const [Color(0xFFFFB74D), Color(0xFFEF6C00)],
          size: size,
        );

  const GlowIcon.bmi({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.monitor_weight_outlined,
          colors: const [Color(0xFF64B5F6), Color(0xFF1565C0)],
          size: size,
        );

  const GlowIcon.water({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.water_drop_rounded,
          colors: const [Color(0xFF4DD0E1), Color(0xFF00838F)],
          size: size,
        );

  const GlowIcon.weight({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.fitness_center_rounded,
          colors: const [Color(0xFFA78BFA), Color(0xFF5B21B6)],
          size: size,
        );

  const GlowIcon.streak({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.local_fire_department_rounded,
          colors: const [Color(0xFFFF7043), Color(0xFFBF360C)],
          size: size,
        );

  const GlowIcon.progress({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.trending_up_rounded,
          colors: const [Color(0xFF81C784), Color(0xFF2E7D32)],
          size: size,
        );

  const GlowIcon.workout({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.fitness_center_rounded,
          colors: const [Color(0xFFFFD54F), Color(0xFFFF8F00)],
          size: size,
        );

  const GlowIcon.diet({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.restaurant_rounded,
          colors: const [Color(0xFF66BB6A), Color(0xFF2E7D32)],
          size: size,
        );

  const GlowIcon.settings({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.tune_rounded,
          colors: const [Color(0xFF78909C), Color(0xFF37474F)],
          size: size,
        );

  const GlowIcon.profile({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.person_rounded,
          colors: const [Color(0xFFCE93D8), Color(0xFF6A1B9A)],
          size: size,
        );

  const GlowIcon.home({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.home_rounded,
          colors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
          size: size,
        );

  const GlowIcon.calendar({Key? key, double size = 40})
      : this(
          key: key,
          icon: Icons.calendar_month_rounded,
          colors: const [Color(0xFF7986CB), Color(0xFF283593)],
          size: size,
        );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final glowColor = colors.length > 1 ? colors.last : colors.first;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.42),
            blurRadius: size * 0.40,
            spreadRadius: 0,
            offset: Offset(0, size * 0.10),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.50,
      ),
    );
  }
}
