import 'dart:convert';

class MealEntry {
  final String id;       // millisecondsSinceEpoch string — unique key
  final String date;     // YYYY-MM-DD
  final String name;
  final int calories;
  final String type;     // breakfast | lunch | dinner | snack

  const MealEntry({
    required this.id,
    required this.date,
    required this.name,
    required this.calories,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'name': name,
        'calories': calories,
        'type': type,
      };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        id: json['id'] as String? ??
            '${DateTime.now().millisecondsSinceEpoch}',
        date: json['date'] as String,
        name: json['name'] as String? ?? '',
        calories: json['calories'] as int? ?? 0,
        type: json['type'] as String? ?? 'snack',
      );

  static List<MealEntry> listFromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return list
        .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<MealEntry> entries) =>
      jsonEncode(entries.map((e) => e.toJson()).toList());
}
