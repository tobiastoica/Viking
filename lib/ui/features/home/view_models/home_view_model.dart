import 'package:flutter/material.dart';
import '../../../../data/models/plan_model.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../../data/repositories/workout_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final PlanRepository planRepository;
  final WorkoutRepository workoutRepository;

  HomeViewModel({
    required this.planRepository,
    required this.workoutRepository,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DayPlan _todayPlan = DayPlan(date: PlanRepository.formatDate(DateTime.now()));
  DayPlan get todayPlan => _todayPlan;

  Map<String, Workout> _workoutMap = {};
  Map<String, Workout> get workoutMap => _workoutMap;

  Future<void> loadToday({bool forceReload = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final todayStr = PlanRepository.formatDate(DateTime.now());
      final allItems = await planRepository.getItemsForDate(todayStr);
      _todayPlan = DayPlan(date: todayStr, items: allItems);

      final allWorkouts = await workoutRepository.getWorkouts(forceReload: forceReload);
      _workoutMap = {for (final w in allWorkouts) w.id: w};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(String itemId, bool completed) async {
    await planRepository.toggleCompletion(itemId, completed);
    await loadToday();
  }
}
