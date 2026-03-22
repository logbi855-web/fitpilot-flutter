class BmiCalc {
  /// weight in kg, height in cm
  static double calculate(double weight, double height) {
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  /// Returns 'under' | 'healthy' | 'over' | 'obese'
  static String category(double bmi) {
    if (bmi < 18.5) return 'under';
    if (bmi < 25) return 'healthy';
    if (bmi < 30) return 'over';
    return 'obese';
  }

  static String categoryLabel(String category) {
    switch (category) {
      case 'under':
        return 'Underweight';
      case 'healthy':
        return 'Healthy';
      case 'over':
        return 'Overweight';
      case 'obese':
        return 'Obese';
      default:
        return '';
    }
  }
}
