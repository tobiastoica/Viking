import 'dart:convert';

enum WorkoutStepType {
  exercise,
  restBreak,
}

/// Represents an individual step in a workout sequence: either an exercise or a break.
class WorkoutStep {
  final String id;
  final WorkoutStepType type;
  /// Associated exercise id (if type == exercise)
  final String? exerciseId;
  /// Snapshot of the exercise name for offline fast display
  final String title;
  /// Number of reps (1 or more for exercise steps)
  final int reps;
  /// Duration in seconds for this step.
  /// For an exercise step: computed from (reps * exercise.durationSeconds).
  /// For a rest break: configured rest time.
  final int durationSeconds;
  /// Optional cues or coaching notes
  final String notes;
  final Map<String, dynamic> customProperties;

  const WorkoutStep({
    required this.id,
    required this.type,
    required this.title,
    this.exerciseId,
    this.reps = 1,
    required this.durationSeconds,
    this.notes = '',
    this.customProperties = const {},
  });

  bool get isExercise => type == WorkoutStepType.exercise;
  bool get isBreak => type == WorkoutStepType.restBreak;

  WorkoutStep copyWith({
    String? id,
    WorkoutStepType? type,
    String? exerciseId,
    String? title,
    int? reps,
    int? durationSeconds,
    String? notes,
    Map<String, dynamic>? customProperties,
  }) {
    return WorkoutStep(
      id: id ?? this.id,
      type: type ?? this.type,
      exerciseId: exerciseId ?? this.exerciseId,
      title: title ?? this.title,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  factory WorkoutStep.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'exercise';
    final stepType = typeStr == 'restBreak' || typeStr == 'break'
        ? WorkoutStepType.restBreak
        : WorkoutStepType.exercise;

    return WorkoutStep(
      id: json['id'] as String? ?? '',
      type: stepType,
      exerciseId: json['exerciseId'] as String?,
      title: json['title'] as String? ?? (stepType == WorkoutStepType.restBreak ? 'Rest Break' : 'Exercise'),
      reps: (json['reps'] as num?)?.toInt() ?? 1,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 30,
      notes: json['notes'] as String? ?? '',
      customProperties: json['customProperties'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['customProperties'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == WorkoutStepType.restBreak ? 'restBreak' : 'exercise',
      'exerciseId': exerciseId,
      'title': title,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'notes': notes,
      'customProperties': customProperties,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutStep.fromJsonString(String source) =>
      WorkoutStep.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
