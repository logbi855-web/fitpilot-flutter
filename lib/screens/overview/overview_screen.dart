import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/ai_coach_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/tab_provider.dart';
import '../../core/services/ai_coach_service.dart';
import '../../widgets/streak_dots.dart';
import '../../widgets/weekly_chart.dart';
import '../../utils/weather_icon_mapper.dart';
import '../../utils/bmi_calc.dart';
import '../../models/progress_entry.dart';

const _motivationMessages = [
  'Small progress is still progress.',
  'Consistency beats motivation.',
  'You are stronger than yesterday.',
  'Discipline creates freedom.',
  'Train like the storm is coming.',
  'One workout closer to your goal.',
  'Show up even when it\'s hard.',
];

final _sessionMotivation =
    _motivationMessages[Random().nextInt(_motivationMessages.length)];

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Returns a fade animation staggered by [index].
  Animation<double> _fade(int index) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(
          (index * 0.08).clamp(0.0, 0.7),
          ((index * 0.08) + 0.35).clamp(0.1, 1.0),
          curve: Curves.easeOut,
        ),
      );

  /// Returns a slide-up animation staggered by [index].
  Animation<Offset> _slide(int index) =>
      Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            (index * 0.08).clamp(0.0, 0.7),
            ((index * 0.08) + 0.35).clamp(0.1, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );

  Widget _animated(int index, Widget child) => FadeTransition(
        opacity: _fade(index),
        child: SlideTransition(position: _slide(index), child: child),
      );

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final streak = ref.watch(streakProvider);
    final water = ref.watch(waterProvider);
    final progress = ref.watch(progressProvider);
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);
    final workout = ref.watch(workoutProvider);

    final now = DateTime.now();
    final last7 = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return progress.firstWhere(
        (e) => e.date == key,
        orElse: () => ProgressEntry(date: key),
      );
    });

    int animIdx = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animated(
            animIdx++,
            _HeroCard(
              profile: profile,
              weatherData: weather.current,
              city: weather.city,
              motivation: _sessionMotivation,
            ),
          ),
          const SizedBox(height: 14),
          _animated(
            animIdx++,
            _StatsGrid(profile: profile, water: water, settings: settings),
          ),
          const SizedBox(height: 14),
          if (workout.savedPlans.isNotEmpty) ...[
            _animated(animIdx++, _WorkoutCard(plan: workout.savedPlans.first)),
            const SizedBox(height: 14),
          ] else
            () {
              animIdx++;
              return const SizedBox.shrink();
            }(),
          _animated(
            animIdx++,
            _StreakCard(
              streak: streak,
              onLogWorkout: () =>
                  ref.read(streakProvider.notifier).logWorkout(),
            ),
          ),
          const SizedBox(height: 14),
          _animated(
            animIdx++,
            _ProgressCard(entries: last7),
          ),
          const SizedBox(height: 14),
          _animated(
            animIdx++,
            _WeeklyReportCard(
              progress: progress,
              longestStreak: streak.longestStreak,
              water: water,
            ),
          ),
          const SizedBox(height: 14),
          _animated(animIdx++, const _AiCoachCard()),
          const SizedBox(height: 14),
          _animated(animIdx, const _ModulesGrid()),
        ],
      ),
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final dynamic profile;
  final dynamic weatherData;
  final String city;
  final String motivation;

  const _HeroCard({
    required this.profile,
    required this.weatherData,
    required this.city,
    required this.motivation,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = weatherData != null
        ? WeatherIconMapper.map(weatherData.weatherId as int)
        : null;
    final weatherIcon = weatherInfo?.emoji ?? '';
    final weatherLabel = weatherInfo?.label ?? '';
    final tempStr =
        weatherData != null ? '${(weatherData.temp as num).round()}°C' : '--';
    final name = profile.name as String? ?? 'there';
    final photoPath = profile.photoPath as String?;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1040),
            Color(0xFF2D1B69),
            Color(0xFF120D2A),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryDim,
                    backgroundImage: photoPath != null
                        ? FileImage(File(photoPath))
                        : null,
                    child: photoPath == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${name.isNotEmpty ? name : 'there'}',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (weatherData != null)
                        Row(
                          children: [
                            Text(weatherIcon,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 5),
                            Text(
                              tempStr,
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            if (weatherLabel.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              Text(
                                '· $weatherLabel',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 12),
                              ),
                            ],
                            const SizedBox(width: 8),
                            _LocalBadge(),
                          ],
                        )
                      else
                        Row(
                          children: [
                            const Text('--',
                                style: TextStyle(
                                    color: AppColors.muted, fontSize: 13)),
                            const SizedBox(width: 8),
                            _LocalBadge(),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryDim.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Text(
                motivation,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: const Text(
        'LOCAL',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic profile;
  final dynamic water;
  final dynamic settings;

  const _StatsGrid(
      {required this.profile, required this.water, required this.settings});

  @override
  Widget build(BuildContext context) {
    final bmiStr = profile.bmi != null
        ? '${(profile.bmi as double).toStringAsFixed(1)} (${BmiCalc.categoryLabel(profile.bmiCategory as String? ?? '')})'
        : '--';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatTile(
            label: 'Goal',
            value: profile.goal != null
                ? _goalLabel(profile.goal as String)
                : '--',
            icon: Icons.flag_outlined),
        _StatTile(
            label: 'BMI',
            value: bmiStr,
            icon: Icons.monitor_weight_outlined),
        _StatTile(
          label: 'Water',
          value: '${water.totalMl} / ${settings.waterGoal} ml',
          icon: Icons.water_drop_outlined,
        ),
        _StatTile(
          label: 'Weight',
          value: profile.weight != null ? '${profile.weight} kg' : '--',
          icon: Icons.fitness_center,
        ),
      ],
    );
  }

  String _goalLabel(String g) => switch (g) {
        'lose' => 'Lose Weight',
        'gain' => 'Gain Muscle',
        'maintain' => 'Maintain',
        _ => g,
      };
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak Card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final dynamic streak;
  final VoidCallback onLogWorkout;

  const _StreakCard({required this.streak, required this.onLogWorkout});

  String get _title {
    final n = streak.currentStreak as int;
    if (n == 0) return 'Start Your Streak';
    if (n < 3) return 'Getting Started';
    if (n < 7) return 'Building Momentum';
    return 'On Fire!';
  }

  String get _subtitle {
    final n = streak.currentStreak as int;
    if (n == 0) return 'Every journey starts with day 1';
    if (n < 3) return 'Keep showing up!';
    if (n < 7) return "Don't break the chain!";
    return 'Legendary consistency';
  }

  bool get _loggedToday {
    final today = DateTime.now();
    final key =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return streak.lastWorkoutDate == key;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title,
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(
                        streak.currentStreak == 0
                            ? 'Log a workout to begin'
                            : '${streak.currentStreak} day streak',
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${streak.currentStreak}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(_subtitle,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 12),
            StreakDots(history: streak.history as List<String>),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loggedToday ? null : onLogWorkout,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40)),
              child: Text(_loggedToday
                  ? 'Logged today'
                  : "Log today's workout"),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress Card ─────────────────────────────────────────────────────────────

class _ProgressCard extends ConsumerStatefulWidget {
  final List<ProgressEntry> entries;

  const _ProgressCard({required this.entries});

  @override
  ConsumerState<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends ConsumerState<_ProgressCard> {
  final _weightCtrl = TextEditingController();
  final _calsCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _calsCtrl.dispose();
    super.dispose();
  }

  void _log() {
    final weight = double.tryParse(_weightCtrl.text.trim());
    final cals = int.tryParse(_calsCtrl.text.trim()) ?? 0;
    if (weight == null && cals == 0) return;
    ref.read(progressProvider.notifier).logEntry(
          weight: weight,
          caloriesBurned: cals,
        );
    _weightCtrl.clear();
    _calsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Progress',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            WeeklyChart(entries: widget.entries),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.text, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Weight (kg)',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _calsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.text, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Calories burned',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _log,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10)),
                child: const Text('Log', style: TextStyle(fontSize: 12)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Weekly Report Card ────────────────────────────────────────────────────────

class _WeeklyReportCard extends StatelessWidget {
  final List<ProgressEntry> progress;
  final int longestStreak;
  final dynamic water;

  const _WeeklyReportCard({
    required this.progress,
    required this.longestStreak,
    required this.water,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekEntries = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return progress.firstWhere((e) => e.date == key,
          orElse: () => ProgressEntry(date: key));
    });

    final workouts =
        weekEntries.fold(0, (s, e) => s + e.workoutsLogged);
    final cals = weekEntries.fold(0, (s, e) => s + e.caloriesBurned);
    final activeDays = weekEntries
        .where((e) => e.workoutsLogged > 0 || e.caloriesBurned > 0)
        .length;
    final consistency = (activeDays / 7 * 100).round();
    final weekNum = _isoWeek(now);

    String recommendation;
    if (workouts == 0) {
      recommendation =
          'No workouts logged yet this week. Start with a short 20-min session today.';
    } else if (consistency >= 80) {
      recommendation =
          'Outstanding week! You hit $consistency% consistency. Keep it up and add a stretch session tomorrow.';
    } else if (consistency >= 50) {
      recommendation =
          'Good effort — $workouts workouts this week. Aim for one more session to push past 70%.';
    } else if (cals < 500) {
      recommendation =
          'Try adding a cardio session to boost your calorie burn. Even a 30-min walk counts.';
    } else {
      recommendation =
          "You're building momentum. Stay consistent and aim for ${workouts + 1} workouts next week.";
    }

    return Card(
      color: AppColors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Week $weekNum Summary',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$consistency%',
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              _ReportStat(label: 'Workouts', value: '$workouts'),
              _ReportStat(
                  label: 'Calories',
                  value: cals > 0 ? '$cals kcal' : '0 kcal'),
              _ReportStat(
                  label: 'Best Streak', value: '$longestStreak days'),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: consistency / 100,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Text(recommendation,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  int _isoWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final thursday =
        d.add(Duration(days: 4 - (d.weekday == 7 ? 0 : d.weekday)));
    final firstThursday = DateTime(thursday.year, 1, 4).add(
        Duration(days: 4 - DateTime(thursday.year, 1, 4).weekday));
    return ((thursday.difference(firstThursday).inDays) / 7).floor() + 1;
  }
}

class _ReportStat extends StatelessWidget {
  final String label;
  final String value;
  const _ReportStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          Text(label,
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── AI Coach Card ─────────────────────────────────────────────────────────────

class _AiCoachCard extends ConsumerWidget {
  const _AiCoachCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coach = ref.watch(aiCoachProvider);

    return Card(
      color: AppColors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Coach',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: coach.loading
                  ? const Row(
                      children: [
                        SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary)),
                        SizedBox(width: 8),
                        Text('Thinking…',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                      ],
                    )
                  : Text(coach.message,
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 13)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CoachChip(label: 'Workout', topic: CoachTopic.workout),
                _CoachChip(label: 'Meal', topic: CoachTopic.meal),
                _CoachChip(label: 'Recovery', topic: CoachTopic.recovery),
                _CoachChip(label: 'Motivation', topic: CoachTopic.motivation),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachChip extends ConsumerWidget {
  final String label;
  final CoachTopic topic;

  const _CoachChip({required this.label, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      label: Text(label),
      onPressed: () => ref.read(aiCoachProvider.notifier).ask(topic),
    );
  }
}

// ── Workout Card ──────────────────────────────────────────────────────────────

class _WorkoutCard extends StatelessWidget {
  final dynamic plan;
  const _WorkoutCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final tags = plan.tags as List<String>;
    final intTag = tags.firstWhere(
        (t) => ['high', 'low'].contains(t.toLowerCase()),
        orElse: () => '');
    final focusTag = tags.firstWhere(
        (t) => ['upper', 'lower', 'full', 'strength', 'cardio', 'hiit']
            .contains(t.toLowerCase()),
        orElse: () => '');

    return Card(
      color: AppColors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Last Workout Plan',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const Spacer(),
                if (intTag.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(intTag.toUpperCase(),
                        style: AppTextStyles.mono(
                            fontSize: 9, color: AppColors.text)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(plan.title as String,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(plan.meta as String,
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 12)),
            if (focusTag.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${(plan.exercises as List).length} exercises · ${focusTag[0].toUpperCase()}${focusTag.substring(1)} focus',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Modules Grid ──────────────────────────────────────────────────────────────

class _ModulesGrid extends ConsumerWidget {
  const _ModulesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const modules = [
      (label: 'Workouts', icon: Icons.fitness_center, tabIndex: 1),
      (label: 'Diet AI', icon: Icons.restaurant_menu_outlined, tabIndex: 2),
      (label: 'Water', icon: Icons.water_drop_outlined, tabIndex: 3),
      (label: 'Profile', icon: Icons.person_outline, tabIndex: 4),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: modules.map((m) {
        return Material(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                ref.read(selectedTabProvider.notifier).state = m.tabIndex,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m.icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  m.label,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
