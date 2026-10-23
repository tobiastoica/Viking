import '../models/exercise_model.dart';
import '../services/storage_service.dart';

class ExerciseRepository {
  static const String _fileName = 'exercises.json';
  final StorageService storage;
  List<Exercise>? _cachedExercises;

  ExerciseRepository({required this.storage});

  Future<List<Exercise>> getExercises({bool forceReload = false}) async {
    if (!forceReload && _cachedExercises != null) {
      return List.unmodifiable(_cachedExercises!);
    }

    final rawList = await storage.readList(_fileName);
    if (rawList.isEmpty) {
      // Seed default exercises for fresh install
      final initial = _createDefaultExercises();
      await storage.writeList(_fileName, initial.map((e) => e.toJson()).toList());
      _cachedExercises = initial;
      return List.unmodifiable(initial);
    }

    _cachedExercises = rawList.map(Exercise.fromJson).toList();
    return List.unmodifiable(_cachedExercises!);
  }

  Future<Exercise?> getExerciseById(String id) async {
    final list = await getExercises();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveExercise(Exercise exercise) async {
    final list = (await getExercises()).toList();
    final index = list.indexWhere((e) => e.id == exercise.id);
    if (index >= 0) {
      list[index] = exercise;
    } else {
      list.insert(0, exercise);
    }
    _cachedExercises = list;
    await storage.writeList(_fileName, list.map((e) => e.toJson()).toList());
  }

  Future<void> deleteExercise(String id) async {
    final list = (await getExercises()).toList();
    list.removeWhere((e) => e.id == id);
    _cachedExercises = list;
    await storage.writeList(_fileName, list.map((e) => e.toJson()).toList());
  }

  List<Exercise> _createDefaultExercises() {
    return const [
      Exercise(
        id: 'ex-pushups',
        name: 'Push-ups',
        durationSeconds: 3,
        caloriesBurned: 8.0,
        difficulty: 'Beginner',
        category: 'Chest',
        description: 'Standard floor push-ups with full range of motion.',
      ),
      Exercise(
        id: 'ex-squats',
        name: 'Bodyweight Squats',
        durationSeconds: 3,
        caloriesBurned: 9.0,
        difficulty: 'Beginner',
        category: 'Legs',
        description: 'Deep squats keeping chest upright and knees tracking over toes.',
      ),
      Exercise(
        id: 'ex-pullups',
        name: 'Pull-ups',
        durationSeconds: 4,
        caloriesBurned: 10.0,
        difficulty: 'Advanced',
        category: 'Back',
        description: 'Overhand grip pull-ups with chin over bar.',
      ),
      Exercise(
        id: 'ex-plank',
        name: 'Plank Hold',
        durationSeconds: 45,
        caloriesBurned: 5.0,
        difficulty: 'Intermediate',
        category: 'Core',
        description: 'Isometric forearm plank maintaining rigid spine and engaged core.',
      ),
      Exercise(
        id: 'ex-burpees',
        name: 'Burpees',
        durationSeconds: 4,
        caloriesBurned: 14.0,
        difficulty: 'Advanced',
        category: 'Cardio',
        description: 'High intensity burpee with chest-to-deck and vertical jump.',
      ),
      Exercise(
        id: 'ex-lunges',
        name: 'Walking Lunges',
        durationSeconds: 3,
        caloriesBurned: 7.5,
        difficulty: 'Intermediate',
        category: 'Legs',
        description: 'Alternating forward lunges maintaining 90-degree knee bend.',
      ),
    ];
  }
}
