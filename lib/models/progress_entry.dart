import 'dart:convert';

class ProgressEntry {
  final String date;             // "YYYY-MM-DD"
  final double? weight;          // kg
  final int caloriesBurned;
  final int workoutsLogged;

  const ProgressEntry({
    required this.date,
    this.weight,
    this.caloriesBurned = 0,
    this.workoutsLogged = 0,
  });

  ProgressEntry copyWith({
    String? date,
    double? weight,
    int? caloriesBurned,
    int? workoutsLogged,
  }) {
    return ProgressEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      workoutsLogged: workoutsLogged ?? this.workoutsLogged,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'weight': weight,
        'caloriesBurned': caloriesBurned,
        'workoutsLogged': workoutsLogged,
      };

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        date: json['date'] as String,
        weight: (json['weight'] as num?)?.toDouble(),
        caloriesBurned: json['caloriesBurned'] as int? ?? 0,
        workoutsLogged: json['workoutsLogged'] as int? ?? 0,
      );

  static List<ProgressEntry> listFromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return list
        .map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<ProgressEntry> entries) =>
      jsonEncode(entries.map((e) => e.toJson()).toList());
}
