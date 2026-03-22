import 'dart:convert';

class SavedPlan {
  final int id;           // timestamp millis
  final String title;
  final String meta;
  final List<String> exercises;
  final String intensity; // high | low
  final String location;  // home | gym
  final String focus;     // upper | lower | full
  final String savedAt;
  final List<String> tags;

  const SavedPlan({
    required this.id,
    required this.title,
    required this.meta,
    required this.exercises,
    required this.intensity,
    required this.location,
    required this.focus,
    required this.savedAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'meta': meta,
        'exercises': exercises,
        'intensity': intensity,
        'location': location,
        'focus': focus,
        'savedAt': savedAt,
        'tags': tags,
      };

  factory SavedPlan.fromJson(Map<String, dynamic> json) => SavedPlan(
        id: json['id'] as int,
        title: json['title'] as String,
        meta: json['meta'] as String,
        exercises: (json['exercises'] as List).cast<String>(),
        intensity: json['intensity'] as String,
        location: json['location'] as String,
        focus: json['focus'] as String,
        savedAt: json['savedAt'] as String,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
      );

  static List<SavedPlan> listFromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return list.map((e) => SavedPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<SavedPlan> plans) =>
      jsonEncode(plans.map((p) => p.toJson()).toList());
}
