import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/body_profile.dart';
import '../utils/bmi_calc.dart';

class ProfileNotifier extends Notifier<BodyProfile> {
  @override
  BodyProfile build() {
    final raw = StorageService.getString(StorageKeys.body);
    if (raw != null) {
      try {
        return BodyProfile.fromJsonString(raw);
      } catch (_) {}
    }
    return const BodyProfile();
  }

  Future<void> save(BodyProfile profile) async {
    // Recalculate BMI on every save
    double? bmi;
    String? bmiCategory;
    if (profile.weight != null && profile.height != null && profile.height! > 0) {
      bmi = BmiCalc.calculate(profile.weight!, profile.height!);
      bmiCategory = BmiCalc.category(bmi);
    }

    const highCaution = ['heart', 'hypertension', 'diabetes', 'asthma', 'arthritis', 'back_pain'];
    final healthCaution =
        profile.medicalConditions.any((c) => highCaution.contains(c));

    final updated = profile.copyWith(
      bmi: bmi,
      bmiCategory: bmiCategory,
      healthCaution: healthCaution,
    );
    state = updated;
    await StorageService.setString(StorageKeys.body, updated.toJsonString());
  }

  Future<void> updatePhoto(String path) => save(state.copyWith(photoPath: path));

  Future<void> reset() async {
    state = const BodyProfile();
    await StorageService.remove(StorageKeys.body);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, BodyProfile>(
  ProfileNotifier.new,
);
