/// Offline rule-based diet "AI" — mirrors the JS intent detection system.
/// No network calls — purely deterministic keyword matching.
class DietLogic {
  static String respond({
    required String input,
    required String goal,        // lose | gain | maintain
    required String personality, // friendly | hard | calm
    String? allergies,
  }) {
    final intent = _detectIntent(input.toLowerCase());
    final profile = _profiles[goal] ?? _profiles['maintain']!;
    final greeting = _greeting(personality);

    switch (intent) {
      case 'grocery':
        return '$greeting Here is your grocery list:\n\n${profile.groceryList}';
      case 'mealPlan':
        return '$greeting Here is your meal plan:\n\n${profile.mealPlan}';
      case 'recipe':
        return '$greeting Try one of these recipes:\n\n${profile.recipes}';
      case 'bmi':
        return '$greeting Your BMI and calorie guide:\n\n${profile.calorieGuide}';
      case 'supplements':
        return '$greeting Supplement advice:\n\nConsider protein powder, omega-3, and a multivitamin. Always consult your doctor before starting supplements.';
      case 'tips':
        return '$greeting Nutrition tips:\n\n• Eat every 3–4 hours\n• Prioritise whole foods\n• Stay hydrated — aim for 2 L water daily\n• Limit processed sugars\n• Prep meals in advance';
      default:
        return '$greeting Tell me more — you can ask for a grocery list, meal plan, recipe ideas, or calorie guidance!';
    }
  }

  static String _detectIntent(String text) {
    if (RegExp(r'grocery|shop|buy|store|ingredient').hasMatch(text)) return 'grocery';
    if (RegExp(r'meal plan|weekly|daily|schedule|plan my').hasMatch(text)) return 'mealPlan';
    if (RegExp(r'recipe|cook|make|prepare|how to').hasMatch(text)) return 'recipe';
    if (RegExp(r'calorie|bmi|intake|how much').hasMatch(text)) return 'bmi';
    if (RegExp(r'supplement|protein powder|vitamin|omega').hasMatch(text)) return 'supplements';
    if (RegExp(r'tip|advice|help|suggest|guide').hasMatch(text)) return 'tips';
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
}

class _DietProfile {
  final String groceryList;
  final String mealPlan;
  final String recipes;
  final String calorieGuide;

  const _DietProfile({
    required this.groceryList,
    required this.mealPlan,
    required this.recipes,
    required this.calorieGuide,
  });
}

const _profiles = <String, _DietProfile>{
  'lose': _DietProfile(
    groceryList: '• Chicken breast\n• Salmon\n• Eggs\n• Greek yoghurt\n• Spinach\n• Broccoli\n• Sweet potato\n• Brown rice\n• Oats\n• Berries\n• Avocado\n• Olive oil\n• Green tea',
    mealPlan: 'Breakfast: Oats with berries and a boiled egg\nSnack: Greek yoghurt\nLunch: Grilled chicken, brown rice, steamed broccoli\nSnack: Apple + almonds\nDinner: Baked salmon, spinach salad, sweet potato',
    recipes: '1. Chicken & Veggie Stir-Fry (400 kcal)\n2. Salmon Quinoa Bowl (450 kcal)\n3. Egg White Omelette with Spinach (220 kcal)',
    calorieGuide: 'Calorie deficit: aim for 300–500 kcal below maintenance.\nProtein: 1.6–2.0 g per kg body weight.\nCarbs: prioritise complex carbs.\nFat: keep at 20–30% of total intake.',
  ),
  'gain': _DietProfile(
    groceryList: '• Whole eggs\n• Full-fat milk\n• Beef mince\n• Peanut butter\n• Whole grain bread\n• Pasta\n• Banana\n• Oats\n• Nuts & seeds\n• Cheese\n• Rice\n• Olive oil',
    mealPlan: 'Breakfast: 3-egg omelette + oats + banana\nSnack: Peanut butter toast\nLunch: Beef mince pasta, salad\nSnack: Full-fat milk protein shake\nDinner: Chicken thighs, brown rice, mixed veg',
    recipes: '1. Beef & Rice Power Bowl (700 kcal)\n2. Peanut Butter Banana Smoothie (600 kcal)\n3. Pasta with Meat Sauce (650 kcal)',
    calorieGuide: 'Calorie surplus: aim for 300–500 kcal above maintenance.\nProtein: 1.8–2.2 g per kg body weight.\nCarbs: 4–6 g per kg body weight.\nEat 5–6 meals per day.',
  ),
  'maintain': _DietProfile(
    groceryList: '• Chicken or fish\n• Eggs\n• Lentils\n• Wholegrain bread\n• Oats\n• Brown rice\n• Seasonal vegetables\n• Fruits\n• Low-fat dairy\n• Nuts\n• Olive oil',
    mealPlan: 'Breakfast: Eggs on wholegrain toast + fruit\nSnack: Nuts + yoghurt\nLunch: Grilled chicken, brown rice, salad\nSnack: Fruit\nDinner: Fish, roasted vegetables, quinoa',
    recipes: '1. Veggie Stir-Fry with Chicken (500 kcal)\n2. Lentil Soup (380 kcal)\n3. Overnight Oats (350 kcal)',
    calorieGuide: 'Eat at maintenance calories.\nBalanced macros: 40% carbs, 30% protein, 30% fat.\nFocus on food quality over tracking every calorie.',
  ),
};
