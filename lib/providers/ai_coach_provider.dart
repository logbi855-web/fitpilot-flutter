import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/ai_coach_service.dart';
import 'profile_provider.dart';
import 'settings_provider.dart';
import 'streak_provider.dart';
import 'progress_provider.dart';

class AiCoachState {
  final String message;
  final bool loading;

  const AiCoachState({
    this.message = 'Tap a topic below to get a personalised recommendation.',
    this.loading = false,
  });

  AiCoachState copyWith({String? message, bool? loading}) => AiCoachState(
        message: message ?? this.message,
        loading: loading ?? this.loading,
      );
}

class AiCoachNotifier extends Notifier<AiCoachState> {
  @override
  AiCoachState build() => const AiCoachState();

  Future<void> ask(CoachTopic topic) async {
    state = state.copyWith(loading: true, message: 'Thinking…');

    final profile = ref.read(profileProvider);
    final streak = ref.read(streakProvider);
    final progress = ref.read(progressProvider);

    final name = profile.name.isNotEmpty ? profile.name : 'the user';
    final goal = profile.goal ?? 'maintain';
    final level = profile.fitnessLevel ?? 'beginner';
    const goalMap = {
      'lose': 'fat loss',
      'gain': 'muscle gain',
      'maintain': 'maintenance',
    };

    final recentWorkouts = progress
        .where((e) => e.workoutsLogged > 0)
        .toList();
    final recent3 = recentWorkouts.length > 3
        ? recentWorkouts.sublist(recentWorkouts.length - 3)
        : recentWorkouts;

    final now = DateTime.now();
    final weekCals = progress
        .where((e) => now.difference(DateTime.parse(e.date)).inDays <= 7)
        .fold(0, (sum, e) => sum + e.caloriesBurned);

    final weightLine =
        profile.weight != null ? ', weighs ${profile.weight}kg' : '';
    final heightLine =
        profile.height != null ? ', height ${profile.height}cm' : '';
    final conditionsLine = profile.medicalConditions.isNotEmpty
        ? 'Health notes: ${profile.medicalConditions.join(', ')}.'
        : '';
    final recentLine = recent3.isNotEmpty
        ? recent3.map((e) => e.date).join(', ')
        : 'none this week';

    final systemContext = "You are FitPilot's AI coach. The user's name is $name.\n"
        "Profile: $level level, goal is ${goalMap[goal] ?? goal}$weightLine$heightLine.\n"
        "Current streak: ${streak.currentStreak} days. Longest streak: ${streak.longestStreak} days.\n"
        "Recent workout days: $recentLine.\n"
        "Weekly calories burned: $weekCals kcal.\n"
        "$conditionsLine\n"
        "Give a short, direct, actionable recommendation (2–3 sentences max). Be motivating but specific.";

    final apiKey = ref.read(settingsProvider).claudeApiKey;
    final service = AiCoachService(apiKey: apiKey);

    try {
      final result = await service.ask(
        topic: topic,
        systemContext: systemContext,
      );
      state = state.copyWith(loading: false, message: result);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        message: _fallback(topic, streak.currentStreak, goal),
      );
    }
  }

  String _fallback(CoachTopic topic, int streakDays, String goal) {
    switch (topic) {
      case CoachTopic.workout:
        if (goal == 'lose') {
          return 'Focus on cardio today — 30 mins of brisk walking or cycling burns fat efficiently. '
              "You're on a $streakDays-day streak, keep it alive!";
        }
        if (goal == 'gain') {
          return 'Hit a compound movement today — squats, deadlifts, or bench press. '
              'Aim for 4 sets of 8 reps.';
        }
        return 'A full-body circuit today would be perfect. '
            '3 rounds of push-ups, lunges, and plank holds.';
      case CoachTopic.meal:
        if (goal == 'lose') {
          return 'Try grilled chicken with steamed vegetables and brown rice. '
              'High protein, moderate carbs — perfect for fat loss.';
        }
        return 'Post-workout: 2 eggs + oats + banana. '
            'Fast carbs to refuel, protein to rebuild.';
      case CoachTopic.recovery:
        if (streakDays >= 3) {
          return "You've trained $streakDays days straight — today prioritise "
              '8hrs sleep, foam rolling, and light stretching.';
        }
        return 'Active recovery day: 20-min walk, light yoga, and stay hydrated '
            '(aim for 2L water).';
      case CoachTopic.motivation:
        if (streakDays > 0) {
          return '$streakDays days in a row — that\'s real discipline. '
              "Most people quit before they see results. You won't.";
        }
        return 'Day 1 starts now. Every consistent action compounds. '
            "Log today's workout and start your streak.";
    }
  }
}

final aiCoachProvider =
    NotifierProvider<AiCoachNotifier, AiCoachState>(AiCoachNotifier.new);
