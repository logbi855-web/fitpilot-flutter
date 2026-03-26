import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/body_profile.dart';
import '../models/meal_entry.dart';
import '../providers/meal_provider.dart';
import '../providers/profile_provider.dart';

// ── Public widget ─────────────────────────────────────────────────────────────

class WeeklyCalorieChart extends ConsumerWidget {
  const WeeklyCalorieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealProvider);
    final profile = ref.watch(profileProvider);
    final target = _estimateTarget(profile);
    final weekData = _buildWeekData(meals);
    final hasAnyData = weekData.any((d) => d.hasData);

    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Weekly Report',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Target: ${_fmtK(target)} kcal',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasAnyData)
              const _EmptyState()
            else ...[
              // Bar chart
              SizedBox(
                height: 130,
                child: _BarChart(weekData: weekData, target: target),
              ),
              const SizedBox(height: 6),
              // Day labels
              Row(
                children: weekData
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(
                              d.dayLabel,
                              style: TextStyle(
                                color: d.isToday
                                    ? AppColors.primary
                                    : AppColors.muted,
                                fontSize: 10,
                                fontWeight: d.isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              // Summary stats
              _SummaryRow(weekData: weekData, target: target),
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _fmtK(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  /// Mifflin-St Jeor (sex-neutral average) + moderate-activity multiplier.
  /// Clamps to [1200, 4000] and adjusts ±15 % for goal.
  static int _estimateTarget(BodyProfile profile) {
    final w = profile.weight;
    final h = profile.height;
    final a = profile.age;
    if (w == null || h == null || a == null) return 2000;

    final bmr = 10 * w + 6.25 * h - 5.0 * a - 78; // sex-neutral average
    final tdee = bmr * 1.55; // moderate activity
    double mult = 1.0;
    if (profile.goal == 'lose') mult = 0.85;
    if (profile.goal == 'gain') mult = 1.15;
    return (tdee * mult).clamp(1200.0, 4000.0).round();
  }

  /// Builds 7 [_DayData] entries from logged meals — index 0 = 6 days ago.
  static List<_DayData> _buildWeekData(List<MealEntry> meals) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final total =
          meals.where((m) => m.date == key).fold(0, (s, m) => s + m.calories);
      return _DayData(
        date: date,
        calories: total,
        hasData: total > 0,
        isToday: i == 6,
      );
    });
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

class _DayData {
  final DateTime date;
  final int calories;
  final bool hasData;
  final bool isToday;

  const _DayData({
    required this.date,
    required this.calories,
    required this.hasData,
    required this.isToday,
  });

  String get dayLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(date.weekday - 1) % 7];
  }
}

// ── Bar chart ─────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<_DayData> weekData;
  final int target;

  const _BarChart({required this.weekData, required this.target});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(weekData: weekData, target: target),
      size: Size.infinite,
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<_DayData> weekData;
  final int target;

  const _BarChartPainter({required this.weekData, required this.target});

  static const _green = Color(0xFF81C784);
  static const _orange = Color(0xFFFFB74D);
  static const _red = Color(0xFFEF5350);

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = math.max(
      target.toDouble() * 1.3,
      weekData.fold<double>(
          0, (m, d) => math.max(m, d.calories.toDouble())),
    );
    if (maxVal <= 0) return;

    final slotW = size.width / weekData.length;
    final barW = slotW * 0.55;

    for (int i = 0; i < weekData.length; i++) {
      final d = weekData[i];
      final cx = slotW * i + slotW / 2;
      final left = cx - barW / 2;

      if (!d.hasData) {
        // Ghost placeholder bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, size.height - size.height * 0.06,
                barW, size.height * 0.06),
            const Radius.circular(3),
          ),
          Paint()
            ..color = AppColors.border
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        continue;
      }

      final ratio = d.calories / maxVal;
      final barH = (size.height * ratio).clamp(4.0, size.height);
      final top = size.height - barH;

      final Color baseColor;
      if (d.calories <= target) {
        baseColor = _green;
      } else if (d.calories <= target * 1.15) {
        baseColor = _orange;
      } else {
        baseColor = _red;
      }

      final color = d.isToday ? baseColor : baseColor.withValues(alpha: 0.72);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barW, barH),
          const Radius.circular(4),
        ),
        Paint()..color = color,
      );

      // Value label above bar (only when bar is tall enough)
      if (barH > 22) {
        final label = d.calories >= 1000
            ? '${(d.calories / 1000).toStringAsFixed(1)}k'
            : '${d.calories}';
        _drawText(canvas, label, cx, top - 2, baseColor);
      }
    }

    // Dashed target line
    _drawDashedLine(canvas, size, maxVal);
  }

  void _drawDashedLine(Canvas canvas, Size size, double maxVal) {
    final y = size.height - (target / maxVal) * size.height;
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;

    const dashLen = 5.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dashLen, size.width), y),
        paint,
      );
      x += dashLen + gap;
    }
  }

  void _drawText(
      Canvas canvas, String text, double cx, double baselineY, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color, fontSize: 9, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, baselineY - tp.height));
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.weekData != weekData || old.target != target;
}

// ── Summary stats ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final List<_DayData> weekData;
  final int target;

  const _SummaryRow({required this.weekData, required this.target});

  static String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final data = weekData.where((d) => d.hasData).toList();
    final total = data.fold(0, (s, d) => s + d.calories);
    final avg = data.isEmpty ? 0 : total ~/ data.length;
    final onTarget = data.where((d) => d.calories <= target).length;
    final weekTarget = target * data.length;
    final balance = total - weekTarget;

    return Row(
      children: [
        _StatBox(
          label: 'Avg / day',
          value: '${_fmt(avg)} kcal',
          color: AppColors.primary,
        ),
        _StatBox(
          label: 'Total',
          value: '${_fmt(total)} kcal',
          color: AppColors.text,
        ),
        _StatBox(
          label: 'On target',
          value: '$onTarget/${data.length} days',
          color: const Color(0xFF81C784),
        ),
        _StatBox(
          label: balance >= 0 ? 'Surplus' : 'Deficit',
          value: '${_fmt(balance.abs())} kcal',
          color: balance > target * 0.1
              ? const Color(0xFFEF5350)
              : balance < 0
                  ? const Color(0xFF81C784)
                  : AppColors.muted,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(color: AppColors.muted, fontSize: 9),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, color: AppColors.border, size: 34),
            SizedBox(height: 8),
            Text(
              'No calorie data yet',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Log progress in the Progress card to see your weekly chart.',
              style: TextStyle(color: AppColors.muted2, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
