import 'dart:convert';

class SettingsModel {
  final String language;      // en | af | fr | zu
  final String personality;   // friendly | hard | calm
  final int waterGoal;        // ml/day (1500–3500)
  final bool restDay;
  final bool weatherWorkout;
  final bool progress;

  const SettingsModel({
    this.language = 'en',
    this.personality = 'friendly',
    this.waterGoal = 2000,
    this.restDay = false,
    this.weatherWorkout = true,
    this.progress = true,
  });

  SettingsModel copyWith({
    String? language,
    String? personality,
    int? waterGoal,
    bool? restDay,
    bool? weatherWorkout,
    bool? progress,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      personality: personality ?? this.personality,
      waterGoal: waterGoal ?? this.waterGoal,
      restDay: restDay ?? this.restDay,
      weatherWorkout: weatherWorkout ?? this.weatherWorkout,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'personality': personality,
        'waterGoal': waterGoal,
        'restDay': restDay,
        'weatherWorkout': weatherWorkout,
        'progress': progress,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        language: json['language'] as String? ?? 'en',
        personality: json['personality'] as String? ?? 'friendly',
        waterGoal: json['waterGoal'] as int? ?? 2000,
        restDay: json['restDay'] as bool? ?? false,
        weatherWorkout: json['weatherWorkout'] as bool? ?? true,
        progress: json['progress'] as bool? ?? true,
      );

  String toJsonString() => jsonEncode(toJson());
  factory SettingsModel.fromJsonString(String s) =>
      SettingsModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
