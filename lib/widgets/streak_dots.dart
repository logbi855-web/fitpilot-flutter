import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// 7-dot row visualising the last 7 days of workout history.
class StreakDots extends StatelessWidget {
  final List<String> history; // all logged dates "YYYY-MM-DD"
  final int dotCount;

  const StreakDots({super.key, required this.history, this.dotCount = 7});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (i) {
        final date = today.subtract(Duration(days: dotCount - 1 - i));
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final active = history.contains(key);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.border,
          ),
        );
      }),
    );
  }
}
