import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'exercise_illustration.dart';

// ── Category ──────────────────────────────────────────────────────────────────

enum ExerciseCategory { upperBody, lowerBody, core, cardio }

extension ExerciseCategoryX on ExerciseCategory {
  IconData get icon {
    switch (this) {
      case ExerciseCategory.upperBody:
        return Icons.fitness_center;
      case ExerciseCategory.lowerBody:
        return Icons.accessibility_new;
      case ExerciseCategory.core:
        return Icons.self_improvement;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
    }
  }

  Color get color {
    switch (this) {
      case ExerciseCategory.upperBody:
        return const Color(0xFF64B5F6); // blue
      case ExerciseCategory.lowerBody:
        return const Color(0xFF81C784); // green
      case ExerciseCategory.core:
        return const Color(0xFFFFB74D); // amber
      case ExerciseCategory.cardio:
        return const Color(0xFFEF5350); // red
    }
  }
}

// ── Exercise info ─────────────────────────────────────────────────────────────

class ExerciseInfo {
  final ExerciseCategory category;
  final String muscles;
  final List<String> steps;
  final List<String> mistakes;

  const ExerciseInfo({
    required this.category,
    required this.muscles,
    required this.steps,
    required this.mistakes,
  });
}

// ── Database ──────────────────────────────────────────────────────────────────

class ExerciseDatabase {
  ExerciseDatabase._();

  /// Returns the best-matching [ExerciseInfo] for a raw exercise string
  /// like "Push-ups — 3×12". Longer keys are tested first for specificity.
  static ExerciseInfo lookup(String rawText) {
    // Normalise: take name part only, lowercase, replace hyphens with spaces
    final name = rawText
        .split(' — ')
        .first
        .toLowerCase()
        .replaceAll('-', ' ');

    for (final entry in _prioritized) {
      if (name.contains(entry.key)) return entry.value;
    }

    // Category keyword fallbacks
    if (_hasAny(name, ['run', 'jump', 'sprint', 'cardio', 'hiit'])) {
      return _cardioFallback;
    }
    if (_hasAny(name, ['leg', 'glute', 'calf', 'hip', 'hamstring', 'quad'])) {
      return _lowerFallback;
    }
    if (_hasAny(name, ['core', 'ab ', 'abs', 'twist', 'crunch', 'plank'])) {
      return _coreFallback;
    }
    return _upperFallback;
  }

  static bool _hasAny(String s, List<String> keywords) =>
      keywords.any(s.contains);

  // Sorted by key length descending so "bicycle crunch" beats "crunch", etc.
  static final List<MapEntry<String, ExerciseInfo>> _prioritized =
      _db.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length));

  // ── Fallbacks ────────────────────────────────────────────────────────────

  static const _upperFallback = ExerciseInfo(
    category: ExerciseCategory.upperBody,
    muscles: 'Upper body muscles',
    steps: [
      'Set up in the correct starting position.',
      'Engage your core and maintain proper alignment.',
      'Perform the movement with controlled, deliberate form.',
      'Return to the starting position under control.',
    ],
    mistakes: [
      'Using momentum instead of muscle control.',
      'Neglecting full range of motion.',
    ],
  );

  static const _lowerFallback = ExerciseInfo(
    category: ExerciseCategory.lowerBody,
    muscles: 'Lower body muscles',
    steps: [
      'Stand with feet at hip or shoulder width.',
      'Engage your core and keep your chest up.',
      'Perform the movement, tracking knees over toes.',
      'Return to starting position under control.',
    ],
    mistakes: [
      'Letting knees cave inward.',
      'Lifting heels off the floor.',
    ],
  );

  static const _coreFallback = ExerciseInfo(
    category: ExerciseCategory.core,
    muscles: 'Core — abs and stabilisers',
    steps: [
      'Position yourself correctly for the movement.',
      'Brace your core before each rep.',
      'Move deliberately, focusing on muscle contraction.',
      'Breathe out on exertion, in on the return.',
    ],
    mistakes: [
      'Holding your breath.',
      'Using momentum instead of abdominal strength.',
    ],
  );

  static const _cardioFallback = ExerciseInfo(
    category: ExerciseCategory.cardio,
    muscles: 'Full body — cardiovascular system',
    steps: [
      'Warm up with a slower version of the movement.',
      'Maintain a pace you can sustain for the full set.',
      'Keep your core engaged throughout.',
      'Cool down gradually after finishing.',
    ],
    mistakes: [
      'Starting too fast and burning out early.',
      'Neglecting arm movement, which reduces calorie burn.',
    ],
  );

  // ── Exercise map (keys are lowercase, hyphens already removed) ────────────

  static const Map<String, ExerciseInfo> _db = {
    'push up': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Chest, triceps, front deltoids, core',
      steps: [
        'Start in a high plank with hands slightly wider than shoulder-width.',
        'Keep your body in a straight line from head to heels.',
        'Lower your chest to just above the floor, elbows at ~45°.',
        'Press back up to the starting position in a controlled manner.',
        'Breathe in on the way down, out on the way up.',
      ],
      mistakes: [
        'Letting your hips sag or pike up.',
        'Flaring elbows out to 90° — keep them at roughly 45°.',
        'Not achieving full range of motion.',
      ],
    ),
    'pull up': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Latissimus dorsi, biceps, rear deltoids',
      steps: [
        'Hang from a bar with an overhand grip, slightly wider than shoulders.',
        'Engage your core and pull your shoulder blades down and back.',
        'Pull yourself up until your chin clears the bar.',
        'Lower yourself with control until arms are fully extended.',
      ],
      mistakes: [
        'Kipping or using body momentum to get up.',
        'Not fully extending at the bottom of each rep.',
        'Crossing your ankles — keep legs straight.',
      ],
    ),
    'chin up': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Biceps, latissimus dorsi, rear deltoids',
      steps: [
        'Hang from a bar with an underhand (supinated) grip at shoulder-width.',
        'Brace your core and squeeze your shoulder blades together.',
        'Pull yourself up until chin clears the bar, leading with elbows.',
        'Lower with full control back to a dead hang.',
      ],
      mistakes: [
        'Using a kipping motion to cheat the rep.',
        'Letting elbows flare wide — keep them pointing down and back.',
        'Not pausing at the bottom to eliminate elastic energy.',
      ],
    ),
    'bicycle crunch': ExerciseInfo(
      category: ExerciseCategory.core,
      muscles: 'Obliques, rectus abdominis, hip flexors',
      steps: [
        'Lie on your back with hands lightly behind your head.',
        'Lift your shoulder blades off the floor.',
        'Drive your right knee toward your chest while rotating your left elbow to meet it.',
        'Simultaneously extend your left leg.',
        'Alternate sides in a controlled cycling motion.',
      ],
      mistakes: [
        'Pulling on your neck with your hands.',
        'Twisting only your arms — the rotation must come from your torso.',
        'Moving too fast and losing the oblique contraction.',
      ],
    ),
    'mountain climber': ExerciseInfo(
      category: ExerciseCategory.cardio,
      muscles: 'Core, hip flexors, shoulders, chest',
      steps: [
        'Start in a high plank with arms straight, hands under shoulders.',
        'Drive your right knee toward your chest.',
        'Quickly switch — extend the right leg back while driving the left knee in.',
        'Alternate legs in a running motion, keeping hips level.',
        'Maintain a flat back and engaged core throughout.',
      ],
      mistakes: [
        'Bouncing your hips up and down instead of keeping them level.',
        'Not fully extending each leg behind you.',
        'Holding your breath — breathe rhythmically.',
      ],
    ),
    'jumping jack': ExerciseInfo(
      category: ExerciseCategory.cardio,
      muscles: 'Calves, hip abductors, deltoids, cardiovascular system',
      steps: [
        'Stand upright with feet together and arms at your sides.',
        'Jump and simultaneously spread your feet to shoulder-width.',
        'Raise your arms overhead as your feet land.',
        'Jump back, bringing feet together and lowering arms.',
        'Maintain a steady, bouncy rhythm.',
      ],
      mistakes: [
        'Locking your knees on landing — keep a slight bend.',
        'Not swinging your arms all the way overhead.',
        'Landing flat-footed — stay on the balls of your feet.',
      ],
    ),
    'russian twist': ExerciseInfo(
      category: ExerciseCategory.core,
      muscles: 'Obliques, transverse abdominis',
      steps: [
        'Sit on the floor with knees bent, feet flat or slightly elevated.',
        'Lean back to about 45°, keeping your spine long — not hunched.',
        'Clasp your hands in front and rotate your torso to the right.',
        'Touch the floor beside your hip, then rotate to the left.',
        'Keep the movement controlled and breathe steadily.',
      ],
      mistakes: [
        'Rounding your back — maintain a neutral spine.',
        'Twisting only your arms; the rotation must come from your torso.',
        'Moving too fast and losing control of the movement.',
      ],
    ),
    'dumbbell row': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Latissimus dorsi, rhomboids, biceps, rear deltoids',
      steps: [
        'Hinge forward at the hips until your torso is nearly parallel to the floor.',
        'Hold a dumbbell in each hand with arms hanging straight down.',
        'Pull the weights up by driving your elbows back past your torso.',
        'Squeeze your shoulder blades together at the top.',
        'Lower with control back to the starting position.',
      ],
      mistakes: [
        'Rounding your back — keep it flat throughout.',
        'Pulling with your biceps first instead of initiating with your back.',
        'Shrugging your shoulders toward your ears.',
      ],
    ),
    'bent over row': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Latissimus dorsi, rhomboids, biceps, rear deltoids',
      steps: [
        'Hinge forward at the hips until your torso is nearly parallel to the floor.',
        'Hold a dumbbell in each hand with arms hanging straight down.',
        'Pull the weights up by driving your elbows back past your torso.',
        'Squeeze your shoulder blades together at the top.',
        'Lower with control back to the starting position.',
      ],
      mistakes: [
        'Rounding your back — keep it flat throughout.',
        'Pulling with your biceps first instead of initiating with your back.',
        'Shrugging your shoulders toward your ears.',
      ],
    ),
    'chest press': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Pectorals, triceps, anterior deltoids',
      steps: [
        'Lie on a bench or the floor holding dumbbells at chest level.',
        'Keep your feet flat and maintain a natural arch in your lower back.',
        'Press the weights straight up until arms are nearly extended.',
        'Lower with control back to chest level.',
        'Keep your shoulder blades retracted throughout.',
      ],
      mistakes: [
        'Bouncing the weights off your chest.',
        'Flaring elbows out to 90° — keep them at 45–75°.',
        'Losing shoulder blade retraction at the bottom.',
      ],
    ),
    'shoulder press': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Deltoids, triceps, upper trapezius',
      steps: [
        'Hold dumbbells at ear level with palms facing forward.',
        'Brace your core and avoid arching your lower back.',
        'Press the weights straight up until arms are nearly extended.',
        'Lower back to ear level with control.',
      ],
      mistakes: [
        'Arching your lower back — tighten your core to prevent this.',
        'Pressing the weights slightly forward instead of directly overhead.',
        'Locking out elbows at the top — keep a slight bend.',
      ],
    ),
    'tricep dip': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Triceps, chest, anterior deltoids',
      steps: [
        'Grip the edge of a bench or chair with hands shoulder-width apart.',
        'Extend your arms and slide your hips off the edge.',
        'Lower your body by bending your elbows to 90°.',
        'Push back up to the start by straightening your arms.',
        'Keep your chest open and shoulders down throughout.',
      ],
      mistakes: [
        'Flaring your elbows out to the sides.',
        'Dipping too deep, stressing the shoulder joint.',
        'Shrugging your shoulders up toward your ears.',
      ],
    ),
    'bicep curl': ExerciseInfo(
      category: ExerciseCategory.upperBody,
      muscles: 'Biceps brachii, brachialis, forearms',
      steps: [
        'Stand holding dumbbells at your sides, palms facing forward.',
        'Keep your elbows pinned close to your torso.',
        'Curl the weights up toward your shoulders, squeezing your biceps.',
        'Hold briefly at the top, then lower slowly back to the start.',
      ],
      mistakes: [
        'Swinging your torso to help lift — isolate the biceps.',
        'Moving your elbows forward as you curl.',
        'Dropping the weight on the way down instead of controlling it.',
      ],
    ),
    'glute bridge': ExerciseInfo(
      category: ExerciseCategory.lowerBody,
      muscles: 'Glutes, hamstrings, core',
      steps: [
        'Lie on your back with knees bent, feet flat on the floor, hip-width apart.',
        'Push through your heels and squeeze your glutes to lift your hips.',
        'Drive hips up until your body forms a straight line shoulder-to-knee.',
        'Hold at the top for 1–2 seconds, then lower slowly.',
      ],
      mistakes: [
        'Driving through your lower back instead of your glutes.',
        'Placing feet too far from or too close to your body.',
        'Not reaching full hip extension at the top.',
      ],
    ),
    'deadlift': ExerciseInfo(
      category: ExerciseCategory.lowerBody,
      muscles: 'Hamstrings, glutes, lower back, traps, forearms',
      steps: [
        'Stand with feet hip-width apart, bar over mid-foot (or dumbbells at sides).',
        'Hinge at the hips, push them back, and grip the bar with a flat back.',
        'Brace your core and keep your chest proud.',
        'Drive through your heels, pushing the floor away to stand up.',
        'Lock out by squeezing your glutes at the top.',
      ],
      mistakes: [
        'Rounding your lower back — this is the most dangerous mistake.',
        'Letting the bar drift away from your body.',
        'Jerking the weight instead of a smooth, controlled drive.',
      ],
    ),
    'squat': ExerciseInfo(
      category: ExerciseCategory.lowerBody,
      muscles: 'Quadriceps, glutes, hamstrings, core',
      steps: [
        'Stand with feet shoulder-width apart, toes pointed slightly out.',
        'Brace your core and keep your chest tall.',
        'Hinge at the hips and bend your knees, sending them over your toes.',
        'Lower until your thighs are at least parallel to the floor.',
        'Drive through your heels to return to standing.',
      ],
      mistakes: [
        'Allowing knees to collapse inward.',
        'Lifting your heels off the ground.',
        'Rounding your lower back at the bottom.',
      ],
    ),
    'lunge': ExerciseInfo(
      category: ExerciseCategory.lowerBody,
      muscles: 'Quadriceps, glutes, hamstrings, hip flexors',
      steps: [
        'Stand tall with feet hip-width apart.',
        'Step one foot forward and lower your back knee toward the floor.',
        'Keep your front knee directly above your ankle — not past your toes.',
        'Push through your front heel to return to the starting position.',
        'Alternate legs each repetition.',
      ],
      mistakes: [
        'Letting your front knee travel past your toes.',
        'Leaning your torso too far forward.',
        'Rushing through reps without control.',
      ],
    ),
    'step up': ExerciseInfo(
      category: ExerciseCategory.lowerBody,
      muscles: 'Quadriceps, glutes, hamstrings',
      steps: [
        'Stand in front of a sturdy step or box.',
        'Step your right foot onto the box, pressing through your heel.',
        'Drive through that heel to lift your entire body up.',
        'Bring your left foot up to the box.',
        'Step back down one foot at a time, then repeat on the other side.',
      ],
      mistakes: [
        'Pushing off with your back foot instead of the leading leg.',
        'Leaning too far forward.',
        'Using a box too high for your current range of motion.',
      ],
    ),
    'calf raise': ExerciseInfo(
      category: ExerciseCategory.lowerBody,
      muscles: 'Gastrocnemius, soleus',
      steps: [
        'Stand with feet hip-width apart, near a wall for balance if needed.',
        'Rise onto the balls of your feet by pushing through your toes.',
        'Pause at the top and squeeze your calves.',
        'Lower slowly back down — go below neutral on a step for full range.',
      ],
      mistakes: [
        'Moving too fast through each rep.',
        'Not using full range of motion.',
        'Leaning forward instead of staying upright.',
      ],
    ),
    'box jump': ExerciseInfo(
      category: ExerciseCategory.cardio,
      muscles: 'Quadriceps, glutes, calves, core',
      steps: [
        'Stand facing the box with feet shoulder-width apart.',
        'Dip into a quarter squat and swing your arms back.',
        'Explode upward, swinging your arms forward for momentum.',
        'Land softly on the box with knees bent and feet flat.',
        'Step down one foot at a time — do not jump down.',
      ],
      mistakes: [
        'Landing with straight, locked knees.',
        'Jumping down from the box instead of stepping.',
        'Not swinging your arms to aid the jump.',
      ],
    ),
    'high knee': ExerciseInfo(
      category: ExerciseCategory.cardio,
      muscles: 'Hip flexors, quadriceps, calves, core',
      steps: [
        'Stand with feet hip-width apart.',
        'Drive your right knee up to hip height.',
        'Quickly switch, bringing the left knee up as the right comes down.',
        'Pump your arms in sync with your legs.',
        'Stay on the balls of your feet throughout.',
      ],
      mistakes: [
        'Leaning your torso back instead of staying upright.',
        'Not lifting your knees to at least hip height.',
        'Landing on your heels — this slows you down and stresses joints.',
      ],
    ),
    'burpee': ExerciseInfo(
      category: ExerciseCategory.cardio,
      muscles: 'Full body — chest, shoulders, core, quads, glutes',
      steps: [
        'Stand with feet shoulder-width apart.',
        'Squat down and place both hands on the floor.',
        'Jump your feet back into a high plank position.',
        'Perform a push-up (optional but recommended).',
        'Jump your feet back to your hands, then explosively jump up with arms overhead.',
      ],
      mistakes: [
        'Skipping the push-up and losing upper-body work.',
        'Landing heavily — bend your knees on impact.',
        'Letting your hips sag in the plank phase.',
      ],
    ),
    'plank': ExerciseInfo(
      category: ExerciseCategory.core,
      muscles: 'Core — transverse abdominis, obliques, lower back, glutes',
      steps: [
        'Place your forearms on the floor with elbows directly below shoulders.',
        'Extend your legs behind you, resting on the balls of your feet.',
        'Form a straight line from your head to your heels.',
        'Brace your abs and squeeze your glutes throughout the hold.',
        'Breathe steadily — do not hold your breath.',
      ],
      mistakes: [
        'Letting your hips sag toward the floor.',
        'Raising your hips too high in the air.',
        'Holding your breath instead of breathing steadily.',
      ],
    ),
    'crunch': ExerciseInfo(
      category: ExerciseCategory.core,
      muscles: 'Rectus abdominis, obliques',
      steps: [
        'Lie on your back with knees bent and feet flat on the floor.',
        'Place hands lightly behind your head without interlocking fingers.',
        'Curl your shoulders off the floor by contracting your abs.',
        'Hold briefly at the top, then lower slowly.',
        'Exhale as you curl up, inhale as you lower.',
      ],
      mistakes: [
        'Pulling your neck with your hands.',
        'Using momentum to swing up — use controlled muscle contraction.',
        'Lifting your lower back off the floor.',
      ],
    ),
    'leg raise': ExerciseInfo(
      category: ExerciseCategory.core,
      muscles: 'Lower abs, hip flexors',
      steps: [
        'Lie flat on your back with arms at your sides or under your lower back.',
        'Keep your legs straight and lift them to 90° (or as high as you can).',
        'Lower your legs slowly — stop just before they touch the floor.',
        'Keep your lower back pressed into the floor throughout.',
      ],
      mistakes: [
        'Letting your lower back arch off the floor.',
        'Swinging your legs up with momentum.',
        'Bending your knees to reduce the challenge.',
      ],
    ),
  };
}

// ── ExerciseCard ──────────────────────────────────────────────────────────────

class ExerciseCard extends StatefulWidget {
  final String rawText;
  final bool isDone;
  final VoidCallback onToggleDone;
  final VoidCallback onEdit;

  const ExerciseCard({
    super.key,
    required this.rawText,
    required this.isDone,
    required this.onToggleDone,
    required this.onEdit,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final info = ExerciseDatabase.lookup(widget.rawText);
    final parts = widget.rawText.split(' — ');
    final name = parts[0];
    final setsReps = parts.length > 1 ? parts[1] : '';
    final accent = info.category.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // ── Header row ─────────────────────────────────────────────────
              InkWell(
                onTap: _toggleExpand,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      // Done toggle
                      GestureDetector(
                        onTap: widget.onToggleDone,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isDone
                                ? AppColors.primary
                                : AppColors.card2,
                            border: Border.all(
                                color: widget.isDone
                                    ? AppColors.primary
                                    : AppColors.border2),
                          ),
                          child: widget.isDone
                              ? const Icon(Icons.check,
                                  size: 14, color: AppColors.bg)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Category icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: accent.withValues(alpha: 0.14),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.30),
                              width: 1),
                        ),
                        child: Icon(info.category.icon,
                            size: 18, color: accent),
                      ),
                      const SizedBox(width: 10),
                      // Name + sets/reps
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: widget.isDone
                                    ? AppColors.muted
                                    : AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: widget.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (setsReps.isNotEmpty)
                              Text(
                                setsReps,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      // Edit
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 15, color: AppColors.muted),
                        onPressed: widget.onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                      ),
                      // Expand chevron
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Expandable body ────────────────────────────────────────────
              SizeTransition(
                sizeFactor: _expandAnim,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise illustration
                      ExerciseIllustration(
                        rawName: name,
                        muscles: info.muscles,
                      ),
                      // Muscles row
                      _InfoRow(
                        icon: Icons.radio_button_checked,
                        label: 'Muscles',
                        text: info.muscles,
                        accent: accent,
                      ),
                      const SizedBox(height: 12),
                      // How to do it
                      _Label('How to do it', accent),
                      const SizedBox(height: 6),
                      ...info.steps.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${e.key + 1}.',
                                      style: TextStyle(
                                          color: accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 10),
                      // Common mistakes
                      _Label('Common mistakes', AppColors.error),
                      const SizedBox(height: 6),
                      ...info.mistakes.map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•',
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 11)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(m,
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color accent;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 11, color: accent),
        const SizedBox(width: 5),
        Text('$label: ',
            style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 11)),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;

  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w700),
    );
  }
}
