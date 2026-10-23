import 'dart:convert';
import 'workout_step_model.dart';

/// Represents a complete workout routine comprising exercises and rest breaks.
class Workout {
  final String id;
  final String name;
  final String description;
  final List<WorkoutStep> steps;
  final String? colorHex;
  final Map<String, dynamic> customProperties;

  const Workout({
    required this.id,
    required this.name,
    this.description = '',
    this.steps = const [],
    this.colorHex,
    this.customProperties = const {},
  });

  /// Total duration in seconds computed automatically across all steps.
  int get totalDurationSeconds =>
      steps.fold(0, (sum, step) => sum + step.durationSeconds);

  int get exerciseCount =>
      steps.where((step) => step.isExercise).length;

  int get breakCount =>
      steps.where((step) => step.isBreak).length;

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutStep>? steps,
    String? colorHex,
    Map<String, dynamic>? customProperties,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      colorHex: colorHex ?? this.colorHex,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    final stepsRaw = json['steps'] as List<dynamic>? ?? [];
    final stepsList = stepsRaw
        .map((s) => WorkoutStep.fromJson(s as Map<String, dynamic>))
        .toList();

    return Workout(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Workout',
      description: json['description'] as String? ?? '',
      steps: stepsList,
      colorHex: json['colorHex'] as String?,
      customProperties: json['customProperties'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['customProperties'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'steps': steps.map((s) => s.toJson()).toList(),
      'colorHex': colorHex,
      'customProperties': customProperties,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory Workout.fromJsonString(String source) =>
      Workout.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
