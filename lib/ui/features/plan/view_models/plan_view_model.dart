import 'package:flutter/material.dart';
import '../../../../data/models/plan_model.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../../data/repositories/workout_repository.dart';

class PlanViewModel extends ChangeNotifier {
  final PlanRepository planRepository;
  final WorkoutRepository workoutRepository;

  PlanViewModel({
    required this.planRepository,
    required this.workoutRepository,
  }) {
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = PlanRepository.formatDate(now);
  }

  late DateTime _currentMonth;
  DateTime get currentMonth => _currentMonth;

  late String _selectedDate;
  String get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, DayPlan> _monthPlans = {};
  Map<String, DayPlan> get monthPlans => _monthPlans;

  List<Workout> _availableWorkouts = [];
  List<Workout> get availableWorkouts => _availableWorkouts;

  DayPlan get selectedDayPlan =>
      _monthPlans[_selectedDate] ?? DayPlan(date: _selectedDate);

  void selectDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    loadMonth();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    loadMonth();
  }

  void jumpToToday() {
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = PlanRepository.formatDate(now);
    loadMonth();
  }

  Future<void> loadMonth({bool forceReload = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _monthPlans = await planRepository.getPlansForMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
      _availableWorkouts = (await workoutRepository.getWorkouts(forceReload: forceReload)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkoutToDate(String date, Workout workout) async {
    final item = ScheduledItem(
      id: 'sched-${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      type: ScheduledItemType.workout,
      targetId: workout.id,
      title: workout.name,
      subtitle: '${workout.steps.length} steps • ${(workout.totalDurationSeconds / 60).toStringAsFixed(1)}m',
      isCompleted: false,
    );

    await planRepository.addItem(item);
    await loadMonth(forceReload: true);
  }

  Future<void> addMealToDate(String date, String title, String subtitle) async {
    final item = ScheduledItem(
      id: 'sched-${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      type: ScheduledItemType.meal,
      targetId: 'meal-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      isCompleted: false,
    );

    await planRepository.addItem(item);
    await loadMonth(forceReload: true);
  }

  Future<void> toggleCompletion(String id, bool completed) async {
    await planRepository.toggleCompletion(id, completed);
    await loadMonth(forceReload: true);
  }

  Future<void> deleteItem(String id) async {
    await planRepository.deleteItem(id);
    await loadMonth(forceReload: true);
  }
}
