import 'dart:convert';

class BodyProfile {
  final String name;
  final double? height;       // cm
  final int? age;
  final double? weight;       // kg
  final double? targetWeight; // kg
  final String? bodyType;
  final String? bodyShape;    // pear | apple | hourglass | rectangle
  final String? fitnessLevel; // beginner | intermediate | advanced
  final String? goal;         // lose | gain | maintain
  final List<String> medicalConditions;
  final String medicalOther;
  final String? takesSupplements; // yes | no | null
  final String medication;
  final bool healthCaution;
  final String? photoPath;  // local file path (not base64)
  final double? bmi;
  final String? bmiCategory; // under | healthy | over | obese

  const BodyProfile({
    this.name = 'User',
    this.height,
    this.age,
    this.weight,
    this.targetWeight,
    this.bodyType,
    this.bodyShape,
    this.fitnessLevel,
    this.goal,
    this.medicalConditions = const [],
    this.medicalOther = '',
    this.takesSupplements,
    this.medication = '',
    this.healthCaution = false,
    this.photoPath,
    this.bmi,
    this.bmiCategory,
  });

  BodyProfile copyWith({
    String? name,
    double? height,
    int? age,
    double? weight,
    double? targetWeight,
    String? bodyType,
    String? bodyShape,
    String? fitnessLevel,
    String? goal,
    List<String>? medicalConditions,
    String? medicalOther,
    String? takesSupplements,
    String? medication,
    bool? healthCaution,
    String? photoPath,
    double? bmi,
    String? bmiCategory,
  }) {
    return BodyProfile(
      name: name ?? this.name,
      height: height ?? this.height,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      bodyType: bodyType ?? this.bodyType,
      bodyShape: bodyShape ?? this.bodyShape,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medicalOther: medicalOther ?? this.medicalOther,
      takesSupplements: takesSupplements ?? this.takesSupplements,
      medication: medication ?? this.medication,
      healthCaution: healthCaution ?? this.healthCaution,
      photoPath: photoPath ?? this.photoPath,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'height': height,
        'age': age,
        'weight': weight,
        'targetWeight': targetWeight,
        'bodyType': bodyType,
        'bodyShape': bodyShape,
        'fitnessLevel': fitnessLevel,
        'goal': goal,
        'medicalConditions': medicalConditions,
        'medicalOther': medicalOther,
        'takesSupplements': takesSupplements,
        'medication': medication,
        'healthCaution': healthCaution,
        'photoPath': photoPath,
        'bmi': bmi,
        'bmiCategory': bmiCategory,
      };

  factory BodyProfile.fromJson(Map<String, dynamic> json) => BodyProfile(
        name: json['name'] as String? ?? 'User',
        height: (json['height'] as num?)?.toDouble(),
        age: json['age'] as int?,
        weight: (json['weight'] as num?)?.toDouble(),
        targetWeight: (json['targetWeight'] as num?)?.toDouble(),
        bodyType: json['bodyType'] as String?,
        bodyShape: json['bodyShape'] as String?,
        fitnessLevel: json['fitnessLevel'] as String?,
        goal: json['goal'] as String?,
        medicalConditions: (json['medicalConditions'] as List?)
                ?.cast<String>() ??
            [],
        medicalOther: json['medicalOther'] as String? ?? '',
        takesSupplements: json['takesSupplements'] as String?,
        medication: json['medication'] as String? ?? '',
        healthCaution: json['healthCaution'] as bool? ?? false,
        photoPath: json['photoPath'] as String?,
        bmi: (json['bmi'] as num?)?.toDouble(),
        bmiCategory: json['bmiCategory'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());
  factory BodyProfile.fromJsonString(String s) =>
      BodyProfile.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
