// ignore_for_file: constant_identifier_names

/// Generates workout plans based on wizard choices.
/// Mirrors the JS app's 72-variant static plan system.
class WorkoutLogic {
  static const _highCautionConditions = [
    'heart', 'hypertension',
  ];
  static const _jointCautionConditions = [
    'arthritis', 'back_pain',
  ];

  static List<String> generatePlan({
    required String intensity, // high | low
    required String location,  // home | gym
    required String focus,     // upper | lower | full
    required String fitnessLevel, // beginner | intermediate | advanced
    required List<String> medicalConditions,
    String? bodyShape,
  }) {
    final key = '${intensity}_${location}_$focus';
    final pool = _plans[key] ?? {};
    var exercises = List<String>.from(pool[fitnessLevel] ?? pool['beginner'] ?? []);

    // Medical substitutions
    final hasHeart = medicalConditions.any((c) => _highCautionConditions.contains(c));
    final hasJoint = medicalConditions.any((c) => _jointCautionConditions.contains(c));

    if (hasHeart) {
      exercises = exercises
          .map((e) => e.toLowerCase().contains('jump') ? 'March in Place — 3×60s' : e)
          .toList();
    }
    if (hasJoint) {
      exercises = exercises
          .map((e) => e.toLowerCase().contains('deadlift') ? 'Resistance Band Row — 3×15' : e)
          .toList();
    }

    // Body shape accent exercise
    if (bodyShape != null) {
      final accent = _accentExercise[bodyShape];
      if (accent != null) exercises.add(accent);
    }

    return exercises;
  }

  static String planTitle(String focus, String intensity) {
    final focusLabel = {'upper': 'Upper Body', 'lower': 'Lower Body', 'full': 'Full Body'}[focus] ?? focus;
    final intensityLabel = intensity == 'high' ? 'High Intensity' : 'Low Intensity';
    return '$focusLabel $intensityLabel Workout';
  }

  static String planMeta(String location, String intensity, String level) {
    final loc = location == 'home' ? 'Home' : 'Gym';
    final int = intensity == 'high' ? 'High Intensity' : 'Low Intensity';
    final lvl = level[0].toUpperCase() + level.substring(1);
    return '$loc · $int · $lvl';
  }

  static List<String> buildTags({
    required String intensity,
    required String location,
    required String level,
    String? goal,
    String? bodyShape,
    int? age,
  }) {
    return [
      intensity,
      location,
      level,
      if (goal != null) goal,
      if (bodyShape != null) bodyShape,
      if (age != null && age >= 50) '50+',
      if (age != null && age >= 40 && age < 50) '40+',
    ];
  }

  // ── Static exercise database (sample — expand for all 72 variants) ──────────

  static const _accentExercise = {
    'pear': 'Hip Abduction — 3×20',
    'apple': 'Bicycle Crunches — 3×20',
    'hourglass': 'Hip Thrust — 3×15',
    'rectangle': 'Lateral Raises — 3×15',
  };

  static const _plans = <String, Map<String, List<String>>>{
    // ── HIGH / HOME / UPPER ────────────────────────────────────────────────
    'high_home_upper': {
      'beginner': [
        'Push-ups — 3×10',
        'Tricep Dips (chair) — 3×10',
        'Pike Push-ups — 3×8',
        'Diamond Push-ups — 3×8',
        'Arm Circles — 3×30s',
      ],
      'intermediate': [
        'Push-ups — 4×15',
        'Wide Push-ups — 3×12',
        'Tricep Dips — 3×15',
        'Pike Push-ups — 3×12',
        'Plank Shoulder Taps — 3×20',
      ],
      'advanced': [
        'Plyometric Push-ups — 4×12',
        'Diamond Push-ups — 4×15',
        'Archer Push-ups — 3×10 each',
        'Tricep Dips — 4×20',
        'Pseudo-Planche Push-ups — 3×8',
      ],
    },
    // ── HIGH / HOME / LOWER ────────────────────────────────────────────────
    'high_home_lower': {
      'beginner': [
        'Squats — 3×15',
        'Lunges — 3×10 each',
        'Glute Bridges — 3×15',
        'Calf Raises — 3×20',
        'Wall Sit — 3×30s',
      ],
      'intermediate': [
        'Jump Squats — 4×12',
        'Bulgarian Split Squats — 3×12 each',
        'Jump Lunges — 3×10 each',
        'Glute Bridges — 4×20',
        'Calf Raises — 4×25',
      ],
      'advanced': [
        'Pistol Squats — 3×8 each',
        'Jump Squats — 4×15',
        'Nordic Hamstring Curls — 3×8',
        'Bulgarian Split Squats — 4×15 each',
        'Box Jumps — 4×10',
      ],
    },
    // ── HIGH / HOME / FULL ────────────────────────────────────────────────
    'high_home_full': {
      'beginner': [
        'Jumping Jacks — 3×30s',
        'Push-ups — 3×10',
        'Squats — 3×15',
        'Mountain Climbers — 3×30s',
        'Plank — 3×30s',
      ],
      'intermediate': [
        'Burpees — 4×10',
        'Push-ups — 4×15',
        'Jump Squats — 4×12',
        'Mountain Climbers — 4×40s',
        'Plank — 4×45s',
      ],
      'advanced': [
        'Burpees — 5×15',
        'Plyometric Push-ups — 4×12',
        'Pistol Squats — 3×8 each',
        'Tuck Jumps — 4×12',
        'L-Sit — 3×20s',
      ],
    },
    // ── HIGH / GYM / UPPER ────────────────────────────────────────────────
    'high_gym_upper': {
      'beginner': [
        'Bench Press — 3×10',
        'Lat Pulldown — 3×10',
        'Dumbbell Shoulder Press — 3×10',
        'Cable Row — 3×10',
        'Bicep Curls — 3×12',
      ],
      'intermediate': [
        'Bench Press — 4×12',
        'Pull-ups — 3×8',
        'Dumbbell Shoulder Press — 4×12',
        'Barbell Row — 4×10',
        'Tricep Pushdown — 3×15',
      ],
      'advanced': [
        'Bench Press — 5×5',
        'Weighted Pull-ups — 4×8',
        'Arnold Press — 4×12',
        'Pendlay Row — 4×6',
        'Close-Grip Bench — 3×12',
      ],
    },
    // ── HIGH / GYM / LOWER ────────────────────────────────────────────────
    'high_gym_lower': {
      'beginner': [
        'Leg Press — 3×15',
        'Leg Curl — 3×12',
        'Leg Extension — 3×12',
        'Calf Raises (machine) — 3×20',
        'Hip Abduction — 3×15',
      ],
      'intermediate': [
        'Barbell Squat — 4×10',
        'Romanian Deadlift — 4×10',
        'Leg Press — 4×15',
        'Leg Curl — 4×12',
        'Walking Lunges — 3×12 each',
      ],
      'advanced': [
        'Barbell Squat — 5×5',
        'Deadlift — 4×5',
        'Bulgarian Split Squats — 4×10 each',
        'Romanian Deadlift — 4×8',
        'Box Jumps — 4×10',
      ],
    },
    // ── HIGH / GYM / FULL ────────────────────────────────────────────────
    'high_gym_full': {
      'beginner': [
        'Treadmill Run — 10 min',
        'Bench Press — 3×10',
        'Barbell Squat — 3×12',
        'Lat Pulldown — 3×10',
        'Plank — 3×30s',
      ],
      'intermediate': [
        'Treadmill Sprint Intervals — 15 min',
        'Bench Press — 4×10',
        'Barbell Squat — 4×10',
        'Deadlift — 3×8',
        'Pull-ups — 3×8',
      ],
      'advanced': [
        'Assault Bike — 10 min HIIT',
        'Bench Press — 5×5',
        'Deadlift — 4×5',
        'Pull-ups — 4×10',
        'Barbell Squat — 4×8',
      ],
    },
    // ── LOW / HOME / UPPER ────────────────────────────────────────────────
    'low_home_upper': {
      'beginner': [
        'Wall Push-ups — 3×15',
        'Arm Circles — 3×30s',
        'Shoulder Rolls — 3×20',
        'Seated Tricep Dips — 3×10',
        'Band Pull-Aparts — 3×15',
      ],
      'intermediate': [
        'Incline Push-ups — 3×15',
        'Tricep Dips — 3×12',
        'Shoulder Taps — 3×20',
        'Superman — 3×15',
        'Plank — 3×30s',
      ],
      'advanced': [
        'Push-ups — 4×15',
        'Pike Push-ups — 3×12',
        'Tricep Dips — 4×15',
        'Plank Shoulder Taps — 3×20',
        'Plank — 4×45s',
      ],
    },
    // ── LOW / HOME / LOWER ────────────────────────────────────────────────
    'low_home_lower': {
      'beginner': [
        'Bodyweight Squats — 3×15',
        'Calf Raises — 3×20',
        'Glute Bridges — 3×15',
        'Side-Lying Leg Raises — 3×15 each',
        'Standing Hip Circles — 3×10 each',
      ],
      'intermediate': [
        'Squats — 4×15',
        'Reverse Lunges — 3×12 each',
        'Glute Bridges — 4×20',
        'Side Leg Raises — 3×20 each',
        'Calf Raises — 4×25',
      ],
      'advanced': [
        'Bulgarian Split Squats — 4×12 each',
        'Single-Leg Glute Bridge — 4×15 each',
        'Jump Squats — 3×12',
        'Lateral Lunges — 3×12 each',
        'Calf Raises — 5×25',
      ],
    },
    // ── LOW / HOME / FULL ────────────────────────────────────────────────
    'low_home_full': {
      'beginner': [
        'March in Place — 5 min',
        'Wall Push-ups — 3×12',
        'Bodyweight Squats — 3×15',
        'Glute Bridges — 3×15',
        'Plank — 3×20s',
      ],
      'intermediate': [
        'Light Jog in Place — 5 min',
        'Push-ups — 3×12',
        'Squats — 3×15',
        'Mountain Climbers (slow) — 3×30s',
        'Plank — 3×30s',
      ],
      'advanced': [
        'Jump Rope — 5 min',
        'Push-ups — 4×15',
        'Jump Squats — 3×12',
        'Mountain Climbers — 4×40s',
        'Plank — 4×45s',
      ],
    },
    // ── LOW / GYM / UPPER ────────────────────────────────────────────────
    'low_gym_upper': {
      'beginner': [
        'Cable Chest Fly — 3×15 (light)',
        'Lat Pulldown — 3×12 (light)',
        'Dumbbell Lateral Raises — 3×15',
        'Face Pulls — 3×15',
        'Bicep Curls — 3×15',
      ],
      'intermediate': [
        'Dumbbell Bench Press — 3×12',
        'Seated Row — 3×12',
        'Dumbbell Shoulder Press — 3×12',
        'Lat Pulldown — 3×12',
        'Tricep Pushdown — 3×15',
      ],
      'advanced': [
        'Bench Press — 4×10',
        'Barbell Row — 4×10',
        'Arnold Press — 3×12',
        'Pull-ups — 3×10',
        'Cable Bicep Curl — 4×12',
      ],
    },
    // ── LOW / GYM / LOWER ────────────────────────────────────────────────
    'low_gym_lower': {
      'beginner': [
        'Leg Press (light) — 3×15',
        'Leg Curl (light) — 3×12',
        'Hip Abduction — 3×15',
        'Calf Raises — 3×20',
        'Seated Leg Extension — 3×12',
      ],
      'intermediate': [
        'Goblet Squat — 3×12',
        'Romanian Deadlift — 3×10',
        'Leg Press — 3×15',
        'Leg Curl — 3×12',
        'Calf Raises — 4×20',
      ],
      'advanced': [
        'Barbell Squat — 4×8',
        'Romanian Deadlift — 4×8',
        'Leg Press — 4×15',
        'Walking Lunges — 3×12 each',
        'Seated Calf Raises — 4×20',
      ],
    },
    // ── LOW / GYM / FULL ────────────────────────────────────────────────
    'low_gym_full': {
      'beginner': [
        'Treadmill Walk — 15 min',
        'Leg Press — 3×12',
        'Lat Pulldown — 3×12',
        'Dumbbell Curl — 3×12',
        'Plank — 3×20s',
      ],
      'intermediate': [
        'Elliptical — 15 min',
        'Goblet Squat — 3×12',
        'Seated Row — 3×12',
        'Dumbbell Shoulder Press — 3×12',
        'Plank — 3×30s',
      ],
      'advanced': [
        'Rowing Machine — 15 min',
        'Barbell Squat — 4×8',
        'Bench Press — 4×10',
        'Deadlift — 3×6',
        'Pull-ups — 3×8',
      ],
    },
  };
}
