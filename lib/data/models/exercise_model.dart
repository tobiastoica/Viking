import 'dart:convert';

/// Represents a single exercise that can be performed or included in workouts.
///
/// Designed open-closed to allow arbitrary future fields (calories, difficulty, etc.)
/// without altering core schema or breaking serialization.
class Exercise {
  final String id;
  final String name;
  final int durationSeconds;
  final double caloriesBurned;
  final String difficulty;
  final String category;
  final String description;
  final Map<String, dynamic> customProperties;

  const Exercise({
    required this.id,
    required this.name,
    required this.durationSeconds,
    this.caloriesBurned = 0.0,
    this.difficulty = 'Intermediate',
    this.category = 'General',
    this.description = '',
    this.customProperties = const {},
  });

  Exercise copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    double? caloriesBurned,
    String? difficulty,
    String? category,
    String? description,
    Map<String, dynamic>? customProperties,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      description: description ?? this.description,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Exercise',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 30,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      difficulty: json['difficulty'] as String? ?? 'Intermediate',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      customProperties: json['customProperties'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['customProperties'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'difficulty': difficulty,
      'category': category,
      'description': description,
      'customProperties': customProperties,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory Exercise.fromJsonString(String source) =>
      Exercise.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ durationSeconds.hashCode;
}
