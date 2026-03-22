import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/settings_model.dart';

class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    final raw = StorageService.getString(StorageKeys.settings);
    if (raw != null) {
      try {
        return SettingsModel.fromJsonString(raw);
      } catch (_) {}
    }
    return const SettingsModel();
  }

  Future<void> save(SettingsModel settings) async {
    state = settings;
    await StorageService.setString(StorageKeys.settings, settings.toJsonString());
  }

  Future<void> update({
    String? language,
    String? personality,
    int? waterGoal,
    bool? restDay,
    bool? weatherWorkout,
    bool? progress,
  }) {
    return save(state.copyWith(
      language: language,
      personality: personality,
      waterGoal: waterGoal,
      restDay: restDay,
      weatherWorkout: weatherWorkout,
      progress: progress,
    ));
  }

  Future<void> reset() => save(const SettingsModel());
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(
  SettingsNotifier.new,
);
