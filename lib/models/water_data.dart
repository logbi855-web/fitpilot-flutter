import 'dart:convert';

class WaterLogEntry {
  final int ml;
  final String time; // "HH:MM"

  const WaterLogEntry({required this.ml, required this.time});

  Map<String, dynamic> toJson() => {'ml': ml, 'time': time};
  factory WaterLogEntry.fromJson(Map<String, dynamic> json) =>
      WaterLogEntry(ml: json['ml'] as int, time: json['time'] as String);
}

class WaterData {
  final String date;      // "YYYY-MM-DD"
  final int totalMl;
  final List<WaterLogEntry> log;
  final String lastReset;

  const WaterData({
    required this.date,
    this.totalMl = 0,
    this.log = const [],
    this.lastReset = '',
  });

  WaterData copyWith({
    String? date,
    int? totalMl,
    List<WaterLogEntry>? log,
    String? lastReset,
  }) {
    return WaterData(
      date: date ?? this.date,
      totalMl: totalMl ?? this.totalMl,
      log: log ?? this.log,
      lastReset: lastReset ?? this.lastReset,
    );
  }

  factory WaterData.today() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return WaterData(date: dateStr);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'totalMl': totalMl,
        'log': log.map((e) => e.toJson()).toList(),
        'lastReset': lastReset,
      };

  factory WaterData.fromJson(Map<String, dynamic> json) => WaterData(
        date: json['date'] as String,
        totalMl: json['totalMl'] as int,
        log: (json['log'] as List)
            .map((e) => WaterLogEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastReset: json['lastReset'] as String? ?? '',
      );

  String toJsonString() => jsonEncode(toJson());
  factory WaterData.fromJsonString(String s) =>
      WaterData.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
