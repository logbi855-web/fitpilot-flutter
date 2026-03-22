import 'dart:convert';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastWorkoutDate; // "YYYY-MM-DD"
  final List<String> history;   // last 30 workout dates

  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
    this.history = const [],
  });

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastWorkoutDate,
    List<String>? history,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastWorkoutDate': lastWorkoutDate,
        'history': history,
      };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastWorkoutDate: json['lastWorkoutDate'] as String?,
        history: (json['history'] as List?)?.cast<String>() ?? [],
      );

  String toJsonString() => jsonEncode(toJson());
  factory StreakData.fromJsonString(String s) =>
      StreakData.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
