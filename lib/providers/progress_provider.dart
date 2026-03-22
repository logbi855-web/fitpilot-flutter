import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/progress_entry.dart';

class ProgressNotifier extends Notifier<List<ProgressEntry>> {
  @override
  List<ProgressEntry> build() {
    final raw = StorageService.getString(StorageKeys.progress);
    if (raw != null) {
      try {
        return ProgressEntry.listFromJsonString(raw);
      } catch (_) {}
    }
    return [];
  }

  Future<void> upsertEntry(ProgressEntry entry) async {
    final list = List<ProgressEntry>.from(state);
    final idx = list.indexWhere((e) => e.date == entry.date);
    if (idx >= 0) {
      list[idx] = entry;
    } else {
      list.add(entry);
    }
    // Rolling 90-day window
    final sorted = list..sort((a, b) => a.date.compareTo(b.date));
    final trimmed = sorted.length > 90 ? sorted.sublist(sorted.length - 90) : sorted;
    state = trimmed;
    await _persist(trimmed);
  }

  Future<void> incrementWorkout(String date) async {
    final existing = state.firstWhere(
      (e) => e.date == date,
      orElse: () => ProgressEntry(date: date),
    );
    await upsertEntry(existing.copyWith(
      workoutsLogged: existing.workoutsLogged + 1,
    ));
  }

  /// Log weight and/or calories for today — mirrors JS logProgress().
  Future<void> logEntry({double? weight, int caloriesBurned = 0}) async {
    final today = _todayStr();
    final existing = state.firstWhere(
      (e) => e.date == today,
      orElse: () => ProgressEntry(date: today),
    );
    await upsertEntry(existing.copyWith(
      weight: weight ?? existing.weight,
      caloriesBurned:
          caloriesBurned > 0 ? caloriesBurned : existing.caloriesBurned,
    ));
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> reset() async {
    state = [];
    await StorageService.remove(StorageKeys.progress);
  }

  Future<void> _persist(List<ProgressEntry> entries) =>
      StorageService.setString(
        StorageKeys.progress,
        ProgressEntry.listToJsonString(entries),
      );
}

final progressProvider = NotifierProvider<ProgressNotifier, List<ProgressEntry>>(
  ProgressNotifier.new,
);
