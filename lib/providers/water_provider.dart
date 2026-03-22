import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/water_data.dart';

class WaterNotifier extends Notifier<WaterData> {
  @override
  WaterData build() {
    return _loadAndReset();
  }

  WaterData _loadAndReset() {
    final raw = StorageService.getString(StorageKeys.water);
    WaterData data;
    if (raw != null) {
      try {
        data = WaterData.fromJsonString(raw);
      } catch (_) {
        data = WaterData.today();
      }
    } else {
      data = WaterData.today();
    }

    final today = WaterData.today().date;
    if (data.date != today) {
      // Daily reset
      data = WaterData(date: today, lastReset: data.date);
      _persist(data);
    }
    return data;
  }

  /// Called on app resume to check for midnight reset
  void checkMidnightReset() {
    final today = WaterData.today().date;
    if (state.date != today) {
      final reset = WaterData(date: today, lastReset: state.date);
      state = reset;
      _persist(reset);
    }
  }

  Future<void> addWater(int ml) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final entry = WaterLogEntry(ml: ml, time: timeStr);
    final updated = state.copyWith(
      totalMl: state.totalMl + ml,
      log: [...state.log, entry],
    );
    state = updated;
    await _persist(updated);
  }

  Future<void> removeEntry(int index) async {
    final newLog = List<WaterLogEntry>.from(state.log)..removeAt(index);
    final newTotal = newLog.fold<int>(0, (sum, e) => sum + e.ml);
    final updated = state.copyWith(totalMl: newTotal, log: newLog);
    state = updated;
    await _persist(updated);
  }

  Future<void> reset() async {
    final fresh = WaterData.today();
    state = fresh;
    await _persist(fresh);
  }

  Future<void> _persist(WaterData data) =>
      StorageService.setString(StorageKeys.water, data.toJsonString());
}

final waterProvider = NotifierProvider<WaterNotifier, WaterData>(
  WaterNotifier.new,
);
