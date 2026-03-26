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
import '../../core/services/weather_service.dart';
import '../../widgets/weather_card_theme.dart';
import '../../widgets/glow_icon.dart';
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
  final WeatherData? weatherData;
  final String motivation;

  const _HeroCard({
    required this.profile,
    required this.weatherData,
    required this.motivation,
  });

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final wd = weatherData;
    final isNight = wd?.icon.endsWith('n') ?? false;
    final weatherTheme = WeatherThemeMapper.fromCode(
      wd?.weatherId,
      isNight: isNight,
    );
    final tempStr = wd != null ? '${wd.temp.round()}°C' : '--';
    final description = wd != null ? _capitalize(wd.description) : '';
    final name = profile.name as String? ?? 'there';
    final photoPath = profile.photoPath as String?;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: weatherTheme.gradientColors,
          stops: weatherTheme.gradientStops,
        ),
      ),
      child: Stack(
        children: [
          // Subtle animated weather particles (rain / snow / stars)
          if (wd != null)
            Positioned.fill(
              child: RepaintBoundary(
                child: WeatherParticles(condition: weatherTheme.condition),
              ),
            ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              WeatherIconWidget(
                                  theme: weatherTheme, size: 34),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          tempStr,
                                          style: const TextStyle(
                                            color: AppColors.text,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const _LocalBadge(),
                                      ],
                                    ),
                                    if (description.isNotEmpty)
                                      Text(
                                        description,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
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
        ],
      ),
    );
  }
}

class _LocalBadge extends StatelessWidget {
  const _LocalBadge();

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
          icon: Icons.flag_rounded,
          glowColors: const [Color(0xFFFFB74D), Color(0xFFEF6C00)],
        ),
        _StatTile(
          label: 'BMI',
          value: bmiStr,
          icon: Icons.monitor_weight_outlined,
          glowColors: const [Color(0xFF64B5F6), Color(0xFF1565C0)],
        ),
        _StatTile(
          label: 'Water',
          value: '${water.totalMl} / ${settings.waterGoal} ml',
          icon: Icons.water_drop_rounded,
          glowColors: const [Color(0xFF4DD0E1), Color(0xFF00838F)],
        ),
        _StatTile(
          label: 'Weight',
          value: profile.weight != null ? '${profile.weight} kg' : '--',
          icon: Icons.fitness_center_rounded,
          glowColors: const [Color(0xFFA78BFA), Color(0xFF5B21B6)],
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
  final List<Color> glowColors;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.glowColors,
  });

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
                GlowIcon(icon: icon, colors: glowColors, size: 22),
                const SizedBox(width: 8),
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
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            _StreakCalendar(history: streak.history as List<String>),
          ],
        ),
      ),
    );
  }
}

// ── Streak Calendar ───────────────────────────────────────────────────────────

class _StreakCalendar extends StatefulWidget {
  final List<String> history;

  const _StreakCalendar({required this.history});

  @override
  State<_StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<_StreakCalendar> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isCurrentMonth = _displayMonth.year == now.year &&
        _displayMonth.month == now.month;
    if (!isCurrentMonth) {
      setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _displayMonth.year == now.year &&
        _displayMonth.month == now.month;

    final monthLabel = _monthName(_displayMonth.month);
    final year = _displayMonth.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month navigation header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _prevMonth,
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.muted, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            Text(
              '$monthLabel $year',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            IconButton(
              onPressed: isCurrentMonth ? null : _nextMonth,
              icon: Icon(Icons.chevron_right,
                  color: isCurrentMonth ? AppColors.border : AppColors.muted,
                  size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _CalendarGrid(
          month: _displayMonth,
          today: now,
          history: widget.history,
        ),
      ],
    );
  }

  static String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime today;
  final List<String> history;

  const _CalendarGrid({
    required this.month,
    required this.today,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Build day grid
    final firstDay = DateTime(month.year, month.month, 1);
    // Monday=1, so offset: Monday→0, Tuesday→1, ..., Sunday→6
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Day-of-week header
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Calendar rows
        for (int row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNumber = cellIndex - startOffset + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final date = DateTime(month.year, month.month, dayNumber);
                return Expanded(
                  child: _DayCell(
                    day: dayNumber,
                    date: date,
                    today: today,
                    history: history,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final DateTime date;
  final DateTime today;
  final List<String> history;

  const _DayCell({
    required this.day,
    required this.date,
    required this.today,
    required this.history,
  });

  String get _key =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool get _isToday =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;

  bool get _isFuture => date.isAfter(today);

  bool get _logged => history.contains(_key);

  @override
  Widget build(BuildContext context) {
    Color? fillColor;
    Color textColor;
    BoxBorder? border;
    double opacity = 1.0;

    if (_isFuture) {
      fillColor = null;
      textColor = AppColors.border;
      opacity = 0.5;
    } else if (_isToday && _logged) {
      fillColor = AppColors.primary;
      textColor = Colors.white;
      border = Border.all(color: AppColors.primary, width: 2);
    } else if (_isToday) {
      fillColor = null;
      textColor = AppColors.primary;
      border = Border.all(color: AppColors.primary, width: 1.5);
    } else if (_logged) {
      fillColor = AppColors.primary.withValues(alpha: 0.75);
      textColor = Colors.white;
    } else {
      fillColor = null;
      textColor = AppColors.muted;
    }

    return Opacity(
      opacity: opacity,
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: border,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight:
                    _isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
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
                const GlowIcon.workout(size: 26),
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
    final modules = [
      _Module(
        label: 'Workouts',
        tabIndex: 1,
        glowIcon: const GlowIcon.workout(size: 44),
      ),
      _Module(
        label: 'Diet AI',
        tabIndex: 2,
        glowIcon: const GlowIcon.diet(size: 44),
      ),
      _Module(
        label: 'Water',
        tabIndex: 3,
        glowIcon: const GlowIcon.water(size: 44),
      ),
      _Module(
        label: 'Profile',
        tabIndex: 4,
        glowIcon: const GlowIcon.profile(size: 44),
      ),
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
                m.glowIcon,
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

class _Module {
  final String label;
  final int tabIndex;
  final GlowIcon glowIcon;
  const _Module(
      {required this.label,
      required this.tabIndex,
      required this.glowIcon});
}
