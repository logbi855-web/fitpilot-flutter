import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/ai_coach_provider.dart';
import '../../core/services/ai_coach_service.dart';
import '../../widgets/streak_dots.dart';
import '../../widgets/weekly_chart.dart';
import '../../utils/weather_icon_mapper.dart';
import '../../utils/bmi_calc.dart';
import '../../models/progress_entry.dart';

// Motivational messages — picked once per app session (mirrors JS sessionStorage logic).
const _motivationMessages = [
  'Small progress is still progress.',
  'Consistency beats motivation.',
  'You are stronger than yesterday.',
  'Discipline creates freedom.',
  'Train like the storm is coming.',
  'One workout closer to your goal.',
  'Show up even when it\'s hard.',
];

final _sessionMotivation = _motivationMessages[
    Random().nextInt(_motivationMessages.length)];

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final streak = ref.watch(streakProvider);
    final water = ref.watch(waterProvider);
    final progress = ref.watch(progressProvider);
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    // Last 7 days aligned oldest→newest
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroCard(
                name: profile.name,
                weatherData: weather.current,
                city: weather.city,
                motivation: _sessionMotivation,
              ),
              const SizedBox(height: 16),
              _StatsGrid(profile: profile, water: water, settings: settings),
              const SizedBox(height: 16),
              _StreakCard(streak: streak, ref: ref),
              const SizedBox(height: 16),
              _ProgressCard(entries: last7, ref: ref),
              const SizedBox(height: 16),
              _WeeklyReportCard(
                  progress: progress, longestStreak: streak.longestStreak, water: water),
              const SizedBox(height: 16),
              const _AiCoachCard(),
              const SizedBox(height: 16),
              _ModulesGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String name;
  final dynamic weatherData;
  final String city;
  final String motivation;

  const _HeroCard({
    required this.name,
    required this.weatherData,
    required this.city,
    required this.motivation,
  });

  @override
  Widget build(BuildContext context) {
    final weatherIcon = weatherData != null
        ? WeatherIconMapper.map(weatherData.weatherId).emoji
        : '🌡';
    final tempStr =
        weatherData != null ? '${weatherData.temp.round()}°C' : '--';

    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryDim,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
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
                      Row(
                        children: [
                          Text(weatherIcon,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '$tempStr · $city',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryDim.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                motivation,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic profile;
  final dynamic water;
  final dynamic settings;

  const _StatsGrid(
      {required this.profile, required this.water, required this.settings});

  @override
  Widget build(BuildContext context) {
    final bmiStr = profile.bmi != null
        ? '${profile.bmi!.toStringAsFixed(1)} (${BmiCalc.categoryLabel(profile.bmiCategory ?? '')})'
        : '--';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatTile(
            label: 'Goal',
            value: profile.goal ?? '--',
            icon: Icons.flag_outlined),
        _StatTile(label: 'BMI', value: bmiStr, icon: Icons.monitor_weight_outlined),
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
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            Text(value,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Streak Card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final dynamic streak;
  final WidgetRef ref;

  const _StreakCard({required this.streak, required this.ref});

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

  String get _label {
    final n = streak.currentStreak as int;
    if (n == 0) return 'Log a workout to begin';
    return '$n day streak';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text(_label,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 13)),
                  ],
                ),
                Text('${streak.currentStreak}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text(_subtitle,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 12),
            StreakDots(history: streak.history),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loggedToday
                  ? null
                  : () => ref.read(streakProvider.notifier).logWorkout(),
              child: Text(
                  _loggedToday ? 'Logged today' : "Log today's workout"),
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
  final WidgetRef ref;

  const _ProgressCard({required this.entries, required this.ref});

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final cals =
        weekEntries.fold(0, (s, e) => s + e.caloriesBurned);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  value: cals > 0 ? '${cals.toString()} kcal' : '0 kcal'),
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
    final firstThursday =
        DateTime(thursday.year, 1, 4)
            .add(Duration(days: 4 - DateTime(thursday.year, 1, 4).weekday));
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                _CoachChip(
                    label: 'Workout',
                    topic: CoachTopic.workout,
                    ref: ref),
                _CoachChip(
                    label: 'Meal', topic: CoachTopic.meal, ref: ref),
                _CoachChip(
                    label: 'Recovery',
                    topic: CoachTopic.recovery,
                    ref: ref),
                _CoachChip(
                    label: 'Motivation',
                    topic: CoachTopic.motivation,
                    ref: ref),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachChip extends StatelessWidget {
  final String label;
  final CoachTopic topic;
  final WidgetRef ref;

  const _CoachChip(
      {required this.label, required this.topic, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => ref.read(aiCoachProvider.notifier).ask(topic),
    );
  }
}

// ── Modules Grid ─────────────────────────────────────────────────────────────

class _ModulesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const modules = [
      (label: 'Weather', icon: Icons.wb_sunny_outlined, route: '/app/weather'),
      (label: 'Workouts', icon: Icons.fitness_center, route: '/app/workout'),
      (label: 'Diet AI', icon: Icons.restaurant_menu, route: '/app/diet'),
      (label: 'Water', icon: Icons.water_drop_outlined, route: '/app/water'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: modules.map((m) {
        return GestureDetector(
          onTap: () => context.go(m.route),
          child: Card(
            color: AppColors.card2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m.icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(m.label,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
