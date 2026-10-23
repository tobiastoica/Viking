import '../models/workout_model.dart';
import '../models/workout_step_model.dart';
import '../services/storage_service.dart';

class WorkoutRepository {
  static const String _fileName = 'workouts.json';
  final StorageService storage;
  List<Workout>? _cachedWorkouts;

  WorkoutRepository({required this.storage});

  Future<List<Workout>> getWorkouts({bool forceReload = false}) async {
    if (!forceReload && _cachedWorkouts != null) {
      return List.unmodifiable(_cachedWorkouts!);
    }

    final rawList = await storage.readList(_fileName);
    if (rawList.isEmpty) {
      final initial = _createDefaultWorkouts();
      await storage.writeList(_fileName, initial.map((w) => w.toJson()).toList());
      _cachedWorkouts = initial;
      return List.unmodifiable(initial);
    }

    _cachedWorkouts = rawList.map(Workout.fromJson).toList();
    return List.unmodifiable(_cachedWorkouts!);
  }

  Future<Workout?> getWorkoutById(String id) async {
    final list = await getWorkouts();
    try {
      return list.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWorkout(Workout workout) async {
    final list = (await getWorkouts()).toList();
    final index = list.indexWhere((w) => w.id == workout.id);
    if (index >= 0) {
      list[index] = workout;
    } else {
      list.insert(0, workout);
    }
    _cachedWorkouts = list;
    await storage.writeList(_fileName, list.map((w) => w.toJson()).toList());
  }

  Future<void> deleteWorkout(String id) async {
    final list = (await getWorkouts()).toList();
    list.removeWhere((w) => w.id == id);
    _cachedWorkouts = list;
    await storage.writeList(_fileName, list.map((w) => w.toJson()).toList());
  }

  List<Workout> _createDefaultWorkouts() {
    return const [
      Workout(
        id: 'wk-viking-starter',
        name: 'Viking Foundation Circuit',
        description: 'Complete high-energy full body conditioning routine.',
        colorHex: '#10B981',
        steps: [
          WorkoutStep(
            id: 's-1',
            type: WorkoutStepType.exercise,
            exerciseId: 'ex-pushups',
            title: 'Push-ups',
            reps: 15,
            durationSeconds: 45,
            notes: 'Chest touches the deck, full lockout.',
          ),
          WorkoutStep(
            id: 's-2',
            type: WorkoutStepType.restBreak,
            title: 'Quick Rest',
            durationSeconds: 20,
            notes: 'Deep nasal breaths and shake out arms.',
          ),
          WorkoutStep(
            id: 's-3',
            type: WorkoutStepType.exercise,
            exerciseId: 'ex-squats',
            title: 'Bodyweight Squats',
            reps: 20,
            durationSeconds: 60,
            notes: 'Parallel or below, steady pace.',
          ),
          WorkoutStep(
            id: 's-4',
            type: WorkoutStepType.restBreak,
            title: 'Hydration Break',
            durationSeconds: 30,
            notes: 'Sip water and prepare for core.',
          ),
          WorkoutStep(
            id: 's-5',
            type: WorkoutStepType.exercise,
            exerciseId: 'ex-plank',
            title: 'Plank Hold',
            reps: 1,
            durationSeconds: 45,
            notes: 'Keep core clamped and glutes squeezed.',
          ),
        ],
      ),
    ];
  }
}
