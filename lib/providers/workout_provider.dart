import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../models/saved_plan.dart';
import '../utils/workout_logic.dart';

class WizardChoices {
  final String? intensity; // high | low
  final String? location;  // home | gym
  final String? focus;     // upper | lower | full

  const WizardChoices({this.intensity, this.location, this.focus});

  WizardChoices copyWith({String? intensity, String? location, String? focus}) =>
      WizardChoices(
        intensity: intensity ?? this.intensity,
        location: location ?? this.location,
        focus: focus ?? this.focus,
      );

  bool get isComplete => intensity != null && location != null && focus != null;
}

class WorkoutState {
  final int step;                // 1–4
  final WizardChoices choices;
  final List<String> exercises;  // generated on step 4
  final List<SavedPlan> savedPlans;

  const WorkoutState({
    this.step = 1,
    this.choices = const WizardChoices(),
    this.exercises = const [],
    this.savedPlans = const [],
  });

  WorkoutState copyWith({
    int? step,
    WizardChoices? choices,
    List<String>? exercises,
    List<SavedPlan>? savedPlans,
  }) =>
      WorkoutState(
        step: step ?? this.step,
        choices: choices ?? this.choices,
        exercises: exercises ?? this.exercises,
        savedPlans: savedPlans ?? this.savedPlans,
      );
}

class WorkoutNotifier extends Notifier<WorkoutState> {
  @override
  WorkoutState build() {
    final raw = StorageService.getString(StorageKeys.saved);
    List<SavedPlan> plans = [];
    if (raw != null) {
      try {
        plans = SavedPlan.listFromJsonString(raw);
      } catch (_) {}
    }
    return WorkoutState(savedPlans: plans);
  }

  void setIntensity(String intensity) {
    state = state.copyWith(
      choices: state.choices.copyWith(intensity: intensity),
      step: 2,
    );
  }

  void setLocation(String location) {
    state = state.copyWith(
      choices: state.choices.copyWith(location: location),
      step: 3,
    );
  }

  void setFocus(String focus, {required String fitnessLevel, required List<String> medicalConditions, required String? bodyShape}) {
    final updated = state.choices.copyWith(focus: focus);
    final exercises = WorkoutLogic.generatePlan(
      intensity: updated.intensity!,
      location: updated.location!,
      focus: focus,
      fitnessLevel: fitnessLevel,
      medicalConditions: medicalConditions,
      bodyShape: bodyShape,
    );
    state = state.copyWith(choices: updated, exercises: exercises, step: 4);
  }

  void goBack() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void resetWizard() {
    state = state.copyWith(
      step: 1,
      choices: const WizardChoices(),
      exercises: [],
    );
  }

  void loadPlan(SavedPlan plan) {
    state = state.copyWith(
      choices: WizardChoices(
        intensity: plan.intensity,
        location: plan.location,
        focus: plan.focus,
      ),
      exercises: List<String>.from(plan.exercises),
      step: 4,
    );
  }

  void updateExercise(int index, String newText) {
    final list = List<String>.from(state.exercises);
    list[index] = newText;
    state = state.copyWith(exercises: list);
  }

  void addExercise(String text) {
    state = state.copyWith(
        exercises: [...state.exercises, text]);
  }

  Future<void> savePlan({
    required String fitnessLevel,
    required String? bodyShape,
    required String? goal,
    required int? age,
  }) async {
    final c = state.choices;
    if (!c.isComplete) return;

    final title = WorkoutLogic.planTitle(c.focus!, c.intensity!);
    final meta = WorkoutLogic.planMeta(c.location!, c.intensity!, fitnessLevel);
    final tags = WorkoutLogic.buildTags(
      intensity: c.intensity!,
      location: c.location!,
      level: fitnessLevel,
      goal: goal,
      bodyShape: bodyShape,
      age: age,
    );

    final plan = SavedPlan(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      meta: meta,
      exercises: List<String>.from(state.exercises),
      intensity: c.intensity!,
      location: c.location!,
      focus: c.focus!,
      savedAt: DateTime.now().toLocal().toString().split(' ').first,
      tags: tags,
    );

    var plans = List<SavedPlan>.from(state.savedPlans)..insert(0, plan);
    if (plans.length > 20) plans = plans.sublist(0, 20);

    state = state.copyWith(savedPlans: plans);
    await StorageService.setString(
        StorageKeys.saved, SavedPlan.listToJsonString(plans));
  }

  Future<void> deletePlan(int id) async {
    final plans = state.savedPlans.where((p) => p.id != id).toList();
    state = state.copyWith(savedPlans: plans);
    await StorageService.setString(
        StorageKeys.saved, SavedPlan.listToJsonString(plans));
  }

  Future<void> resetPlans() async {
    state = state.copyWith(savedPlans: []);
    await StorageService.remove(StorageKeys.saved);
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(
  WorkoutNotifier.new,
);
