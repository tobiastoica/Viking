import 'dart:convert';

enum ScheduledItemType {
  workout,
  meal,
}

/// Represents an item scheduled for a specific date (workout or planned meal).
class ScheduledItem {
  final String id;
  final String date; // YYYY-MM-DD
  final ScheduledItemType type;
  final String targetId; // Reference to workoutId or mealId
  final String title;
  final String subtitle;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic> customProperties;

  const ScheduledItem({
    required this.id,
    required this.date,
    required this.type,
    required this.targetId,
    required this.title,
    this.subtitle = '',
    this.isCompleted = false,
    this.completedAt,
    this.customProperties = const {},
  });

  bool get isWorkout => type == ScheduledItemType.workout;
  bool get isMeal => type == ScheduledItemType.meal;

  ScheduledItem copyWith({
    String? id,
    String? date,
    ScheduledItemType? type,
    String? targetId,
    String? title,
    String? subtitle,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? customProperties,
  }) {
    return ScheduledItem(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  factory ScheduledItem.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'workout';
    final type = typeStr == 'meal'
        ? ScheduledItemType.meal
        : ScheduledItemType.workout;

    DateTime? completedAt;
    if (json['completedAt'] != null) {
      completedAt = DateTime.tryParse(json['completedAt'] as String);
    }

    return ScheduledItem(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      type: type,
      targetId: json['targetId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: completedAt,
      customProperties: json['customProperties'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['customProperties'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type == ScheduledItemType.meal ? 'meal' : 'workout',
      'targetId': targetId,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'customProperties': customProperties,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory ScheduledItem.fromJsonString(String source) =>
      ScheduledItem.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

/// Helper to aggregate scheduled items on a given day.
class DayPlan {
  final String date;
  final List<ScheduledItem> items;

  const DayPlan({
    required this.date,
    this.items = const [],
  });

  int get totalCount => items.length;
  int get completedCount => items.where((i) => i.isCompleted).length;
  
  double get progressRatio =>
      items.isEmpty ? 0.0 : completedCount / totalCount;

  bool get isFulfilled =>
      items.isNotEmpty && completedCount == totalCount;

  List<ScheduledItem> get workouts =>
      items.where((i) => i.isWorkout).toList();

  List<ScheduledItem> get meals =>
      items.where((i) => i.isMeal).toList();
}
