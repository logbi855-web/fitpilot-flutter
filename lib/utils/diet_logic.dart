/// Offline rule-based diet "AI" — mirrors the JS intent detection system.
/// No network calls — purely deterministic keyword matching.
class DietLogic {
  static String respond({
    required String input,
    required String goal,
    required String personality,
    String? allergies,
  }) {
    final text = input.toLowerCase();
    final greeting = _greeting(personality);

    // Special intent paths — checked before main intent switch
    if (RegExp(r'tired|low energy|exhausted|no energy').hasMatch(text)) {
      return _tiredResponse(personality);
    }
    if (RegExp(r'workout|train|exercise|gym').hasMatch(text) &&
        !RegExp(r'grocery|shop|meal plan|what.*(eat|food)').hasMatch(text)) {
      return _workoutAdvice(goal, greeting);
    }

    final intent = _detectIntent(text);
    final profile = _profiles[goal] ?? _profiles['maintain']!;

    switch (intent) {
      case 'grocery':
        final allergyLower = (allergies ?? '').toLowerCase().trim();
        final items = allergyLower.isNotEmpty
            ? profile.groceryItems
                .where((i) => !i.toLowerCase().contains(allergyLower))
                .toList()
            : profile.groceryItems;
        final allergyNote = allergyLower.isNotEmpty
            ? '\n\nAllergy note: items containing "$allergies" have been excluded.'
            : '';
        return '$greeting Here is your grocery list:\n\n'
            '${items.map((i) => '• $i').join('\n')}$allergyNote';

      case 'mealPlan':
        return '$greeting Here is your meal plan:\n\n${profile.mealPlan}';

      case 'recipe':
        return '$greeting Try one of these recipes:\n\n${profile.recipes}';

      case 'ingredients':
        return '$greeting ${_ingredientMeal(text)}';

      case 'bmi':
        return '$greeting Calorie guide:\n\n${profile.calorieGuide}';

      case 'supplements':
        final supps = goal == 'gain'
            ? 'Whey protein, Creatine (5 g/day), Mass gainer (if needed), Omega-3, ZMA'
            : goal == 'lose'
                ? 'Whey protein (preserve muscle), Caffeine/pre-workout, Omega-3, Multivitamin, L-Carnitine'
                : 'Whey protein, Creatine, Omega-3, Multivitamin — keep it simple.';
        return '$greeting Supplements:\n\n$supps\n\nAlways consult a doctor before starting.';

      case 'tips':
        return '$greeting Nutrition tips:\n\n'
            '• Eat every 3–4 hours\n'
            '• Prioritise whole foods\n'
            '• Stay hydrated — aim for 2 L water daily\n'
            '• Limit processed sugars\n'
            '• Prep meals in advance';

      default:
        return '$greeting Tell me more — ask for a grocery list, meal plan, recipe ideas, or tell me what ingredients you have!';
    }
  }

  static String _detectIntent(String text) {
    if (RegExp(r'groceri|shopping|grocery|shop|buy|store|supermarket|pick up')
        .hasMatch(text)) { return 'grocery'; }
    if (RegExp(
            r'meal plan|day plan|daily plan|what (should|can) i eat|full day|eat today|eating plan|diet plan')
        .hasMatch(text)) { return 'mealPlan'; }
    if (RegExp(
            r'recipe|how (do i|to) (make|cook|prepare)|cook|step|instructions|prepare')
        .hasMatch(text)) { return 'recipe'; }
    if (RegExp(r'\bhave\b|ingredient|i got|using|with these|what can i (make|cook)|i have')
        .hasMatch(text)) { return 'ingredients'; }
    if (RegExp(r'calorie|bmi|body mass|intake|how much|overweight|underweight')
        .hasMatch(text)) { return 'bmi'; }
    if (RegExp(r'supplement|protein powder|creatine|vitamin|omega|pre.workout')
        .hasMatch(text)) { return 'supplements'; }
    if (RegExp(r'tip|advice|help|suggest|recommend|guide|how to').hasMatch(text)) {
      return 'tips';
    }
    return 'general';
  }

  static String _greeting(String personality) {
    switch (personality) {
      case 'hard':
        return 'No excuses. Listen up:';
      case 'calm':
        return 'Here is some guidance for you.';
      default:
        return 'Great question! Here you go:';
    }
  }

  static String _tiredResponse(String personality) {
    switch (personality) {
      case 'hard':
        return 'Tired? Still show up. Light movement counts. A good meal and sleep fix most problems.';
      case 'calm':
        return 'Listen to your body. Eat something nourishing, hydrate well, and gentle movement is enough today.';
      default:
        return 'Low energy is okay! Stay hydrated, eat a balanced meal, and rest if needed. Consistency matters more than intensity.';
    }
  }

  static String _workoutAdvice(String goal, String greeting) {
    if (goal == 'gain') {
      return '$greeting Muscle Gain: Strength train 4x/week. High protein (1.6 g/kg bodyweight). Small calorie surplus. Sleep 8 hrs.';
    }
    if (goal == 'lose') {
      return '$greeting Fat Loss: HIIT + strength 5x/week. High protein, calorie deficit. Track your meals.';
    }
    return '$greeting Maintenance: 3-4 workouts/week. Balanced macros. Stay consistent.';
  }

  static String _ingredientMeal(String text) {
    if (text.contains('egg') && text.contains('rice') && text.contains('chicken')) {
      return 'Chicken Egg Fried Rice: Saute diced chicken, add cooked rice, push aside, scramble eggs, combine. Season with soy sauce + sesame oil.';
    }
    if (text.contains('egg') && text.contains('bread')) {
      return 'Protein French Toast: Dip bread in egg + milk mix, pan-fry until golden. Top with banana and a drizzle of honey.';
    }
    if (text.contains('tuna')) {
      return 'Tuna Wrap: Mix tuna + light mayo + diced onion. Roll in a wrap with lettuce and tomato. Quick, lean, high-protein.';
    }
    if (text.contains('oat')) {
      return 'Power Oats: Cook oats, stir in peanut butter or protein powder, top with banana + berries. Great pre-workout fuel.';
    }
    if (text.contains('chicken') && text.contains('rice')) {
      return 'Chicken & Rice Bowl: Grill seasoned chicken, serve over rice with steamed broccoli. Add soy sauce — the ultimate lean meal.';
    }
    if (text.contains('egg')) {
      return 'Protein Omelette: 3 eggs + veggies (spinach, peppers, onion). Whisk, pour into oiled pan, fold when set.';
    }
    return 'Aim for a protein + complex carb + veg combo. Tell me exactly what you have and I will give you step-by-step recipes!';
  }
}

class _DietProfile {
  final List<String> groceryItems;
  final String mealPlan;
  final String recipes;
  final String calorieGuide;

  const _DietProfile({
    required this.groceryItems,
    required this.mealPlan,
    required this.recipes,
    required this.calorieGuide,
  });
}

const _profiles = <String, _DietProfile>{
  'lose': _DietProfile(
    groceryItems: [
      'Chicken breast', 'Tuna', 'Eggs', 'Greek yoghurt (0%)',
      'Spinach', 'Broccoli', 'Cucumber', 'Peppers', 'Zucchini',
      'Sweet potato', 'Brown rice', 'Oats', 'Quinoa',
      'Berries', 'Apple', 'Grapefruit',
      'Olive oil (small)', 'Apple cider vinegar',
      'Green tea', 'Sparkling water', 'Black coffee',
    ],
    mealPlan: 'Breakfast: Protein oats with berries\n'
        'Snack: Greek yoghurt\n'
        'Lunch: Grilled chicken, brown rice, steamed broccoli\n'
        'Snack: Apple + almonds\n'
        'Dinner: Baked tuna with roasted veg',
    recipes: '1. Chicken & Veggie Stir-Fry (~400 kcal)\n'
        '2. Salmon Quinoa Bowl (~450 kcal)\n'
        '3. Egg White Omelette with Spinach (~220 kcal)',
    calorieGuide: '1,400–1,700 kcal/day | Deficit: ~400 kcal\n'
        'Protein: 1.8 g/kg bodyweight\n'
        'Carbs: prioritise complex carbs\n'
        'Fat: keep at 20–30% of total intake.',
  ),
  'gain': _DietProfile(
    groceryItems: [
      'Chicken breast & thighs', 'Beef mince', 'Salmon', 'Whole eggs',
      'Full-fat milk', 'Cottage cheese', 'Greek yoghurt (full fat)',
      'White rice', 'Pasta', 'Oats', 'Whole-grain bread', 'Bananas',
      'Peanut butter', 'Almonds', 'Cashews', 'Avocado',
      'Sweet potato', 'Broccoli', 'Spinach',
      'Olive oil', 'Coconut oil',
      'Whey protein', 'Creatine monohydrate',
    ],
    mealPlan: 'Breakfast: 3-egg omelette + oats + banana\n'
        'Snack: Peanut butter toast\n'
        'Lunch: Beef mince pasta, salad\n'
        'Snack: Full-fat milk protein shake\n'
        'Dinner: Chicken thighs, brown rice, mixed veg',
    recipes: '1. Beef & Rice Power Bowl (~700 kcal)\n'
        '2. Peanut Butter Banana Smoothie (~600 kcal)\n'
        '3. Pasta with Meat Sauce (~650 kcal)',
    calorieGuide: '2,500–3,200 kcal/day | Surplus: ~300–500 kcal\n'
        'Protein: 1.8–2.2 g/kg bodyweight\n'
        'Carbs: 4–6 g/kg bodyweight\n'
        'Eat 5–6 meals per day.',
  ),
  'maintain': _DietProfile(
    groceryItems: [
      'Chicken breast', 'Fish (salmon, tuna)', 'Eggs', 'Lentils', 'Chickpeas',
      'Wholegrain bread', 'Oats', 'Brown rice', 'Quinoa',
      'Seasonal vegetables', 'Spinach', 'Mixed greens', 'Tomatoes', 'Carrots',
      'Fruits: apples, berries, oranges',
      'Low-fat dairy: yoghurt, milk, cheese',
      'Mixed nuts', 'Avocado', 'Olive oil',
    ],
    mealPlan: 'Breakfast: Eggs on wholegrain toast + fruit\n'
        'Snack: Nuts + yoghurt\n'
        'Lunch: Grilled chicken, brown rice, salad\n'
        'Snack: Fruit\n'
        'Dinner: Fish, roasted vegetables, quinoa',
    recipes: '1. Veggie Stir-Fry with Chicken (~500 kcal)\n'
        '2. Lentil Soup (~380 kcal)\n'
        '3. Overnight Oats (~350 kcal)',
    calorieGuide: 'Eat at maintenance calories.\n'
        'Balanced macros: 40% carbs, 30% protein, 30% fat.\n'
        'Focus on food quality over tracking every calorie.',
  ),
};
