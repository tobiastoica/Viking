import 'package:flutter/material.dart';
import '../../../../data/models/exercise_model.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/exercise_repository.dart';
import '../../../../data/repositories/workout_repository.dart';

class WorkoutsViewModel extends ChangeNotifier {
  final WorkoutRepository workoutRepository;
  final ExerciseRepository exerciseRepository;

  WorkoutsViewModel({
    required this.workoutRepository,
    required this.exerciseRepository,
  });

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Workout> _allWorkouts = [];
  List<Exercise> _allExercises = [];

  String _workoutSearchQuery = '';
  String get workoutSearchQuery => _workoutSearchQuery;

  String _exerciseSearchQuery = '';
  String get exerciseSearchQuery => _exerciseSearchQuery;

  List<Workout> get filteredWorkouts {
    if (_workoutSearchQuery.trim().isEmpty) return _allWorkouts;
    final query = _workoutSearchQuery.toLowerCase();
    return _allWorkouts.where((w) {
      return w.name.toLowerCase().contains(query) ||
          w.description.toLowerCase().contains(query);
    }).toList();
  }

  List<Exercise> get filteredExercises {
    if (_exerciseSearchQuery.trim().isEmpty) return _allExercises;
    final query = _exerciseSearchQuery.toLowerCase();
    return _allExercises.where((e) {
      return e.name.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query) ||
          e.difficulty.toLowerCase().contains(query);
    }).toList();
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void setWorkoutSearch(String query) {
    _workoutSearchQuery = query;
    notifyListeners();
  }

  void setExerciseSearch(String query) {
    _exerciseSearchQuery = query;
    notifyListeners();
  }

  Future<void> loadData({bool forceReload = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allWorkouts = (await workoutRepository.getWorkouts(forceReload: forceReload)).toList();
      _allExercises = (await exerciseRepository.getExercises(forceReload: forceReload)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveExercise(Exercise exercise) async {
    await exerciseRepository.saveExercise(exercise);
    await loadData(forceReload: true);
  }

  Future<void> deleteExercise(String id) async {
    await exerciseRepository.deleteExercise(id);
    await loadData(forceReload: true);
  }

  Future<void> saveWorkout(Workout workout) async {
    await workoutRepository.saveWorkout(workout);
    await loadData(forceReload: true);
  }

  Future<void> deleteWorkout(String id) async {
    await workoutRepository.deleteWorkout(id);
    await loadData(forceReload: true);
  }
}
