import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/meal_entry.dart';

class MealNotifier extends Notifier<List<MealEntry>> {
  @override
  List<MealEntry> build() {
    final raw = StorageService.getString(StorageKeys.meals);
    if (raw != null) {
      try {
        return MealEntry.listFromJsonString(raw);
      } catch (_) {}
    }
    return [];
  }

  Future<void> addMeal({
    required String name,
    required int calories,
    required String type,
  }) async {
    final today = _todayStr();
    final entry = MealEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      date: today,
      name: name,
      calories: calories,
      type: type,
    );
    final list = [...state, entry];
    // Keep a rolling 30-day window
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final cutoffStr =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    final trimmed =
        list.where((e) => e.date.compareTo(cutoffStr) >= 0).toList();
    state = trimmed;
    await _persist(trimmed);
  }

  Future<void> deleteMeal(String id) async {
    final list = state.where((e) => e.id != id).toList();
    state = list;
    await _persist(list);
  }

  List<MealEntry> mealsForDate(String date) =>
      state.where((e) => e.date == date).toList();

  int totalCaloriesForDate(String date) =>
      mealsForDate(date).fold(0, (sum, e) => sum + e.calories);

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> reset() async {
    state = [];
    await StorageService.remove(StorageKeys.meals);
  }

  Future<void> _persist(List<MealEntry> entries) =>
      StorageService.setString(
          StorageKeys.meals, MealEntry.listToJsonString(entries));
}

final mealProvider =
    NotifierProvider<MealNotifier, List<MealEntry>>(MealNotifier.new);
