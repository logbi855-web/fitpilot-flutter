import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/streak_data.dart';
import 'progress_provider.dart';

class StreakNotifier extends Notifier<StreakData> {
  @override
  StreakData build() {
    final raw = StorageService.getString(StorageKeys.streak);
    if (raw != null) {
      try {
        return StreakData.fromJsonString(raw);
      } catch (_) {}
    }
    return const StreakData();
  }

  /// Log a workout for today and update streak + progress.
  Future<void> logWorkout() async {
    final today = _todayStr();
    if (state.history.isNotEmpty && state.history.last == today) return; // already logged

    int current = state.currentStreak;
    if (state.lastWorkoutDate != null) {
      final diff = _dayDiff(state.lastWorkoutDate!, today);
      current = diff == 1 ? current + 1 : 1;
    } else {
      current = 1;
    }

    final newHistory = [...state.history, today];
    final trimmed = newHistory.length > 30
        ? newHistory.sublist(newHistory.length - 30)
        : newHistory;

    final updated = StreakData(
      currentStreak: current,
      longestStreak: current > state.longestStreak ? current : state.longestStreak,
      lastWorkoutDate: today,
      history: trimmed,
    );
    state = updated;
    await StorageService.setString(StorageKeys.streak, updated.toJsonString());

    // Also write into progress log
    await ref.read(progressProvider.notifier).incrementWorkout(today);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int _dayDiff(String a, String b) {
    final dateA = DateTime.parse(a);
    final dateB = DateTime.parse(b);
    return dateB.difference(dateA).inDays;
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakData>(
  StreakNotifier.new,
);
