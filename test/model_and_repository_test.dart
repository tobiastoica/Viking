import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:viking/data/models/exercise_model.dart';
import 'package:viking/data/models/plan_model.dart';
import 'package:viking/data/models/workout_model.dart';
import 'package:viking/data/models/workout_step_model.dart';
import 'package:viking/data/repositories/plan_repository.dart';
import 'package:viking/data/services/storage_service.dart';
import 'package:viking/ui/features/active_workout/view_models/active_workout_view_model.dart';

void main() {
  group('JSON Serialization & Open-Closed Integrity Tests', () {
    test('Exercise model serializes and deserializes correctly', () {
      const exercise = Exercise(
        id: 'test-ex-1',
        name: 'Diamond Pushups',
        durationSeconds: 40,
        caloriesBurned: 12.5,
        difficulty: 'Advanced',
        category: 'Chest',
        description: 'Tricep and inner chest focus',
        customProperties: {'tempo': '3-1-1', 'equipment': 'bodyweight'},
      );

      final json = exercise.toJson();
      expect(json['id'], 'test-ex-1');
      expect(json['name'], 'Diamond Pushups');
      expect(json['durationSeconds'], 40);
      expect(json['customProperties']['tempo'], '3-1-1');

      final deserialized = Exercise.fromJson(json);
      expect(deserialized.id, exercise.id);
      expect(deserialized.name, exercise.name);
      expect(deserialized.durationSeconds, exercise.durationSeconds);
      expect(deserialized.customProperties['tempo'], '3-1-1');
      expect(deserialized.customProperties['equipment'], 'bodyweight');
    });

    test('WorkoutStep model handles both exercises and breaks', () {
      const exStep = WorkoutStep(
        id: 'step-1',
        type: WorkoutStepType.exercise,
        title: 'Pullups',
        reps: 8,
        durationSeconds: 32,
      );

      final exJson = exStep.toJson();
      expect(exJson['type'], 'exercise');
      final exParsed = WorkoutStep.fromJson(exJson);
      expect(exParsed.isExercise, true);
      expect(exParsed.reps, 8);

      const breakStep = WorkoutStep(
        id: 'step-2',
        type: WorkoutStepType.restBreak,
        title: 'Rest Break',
        durationSeconds: 45,
      );

      final breakJson = breakStep.toJson();
      expect(breakJson['type'], 'restBreak');
      final breakParsed = WorkoutStep.fromJson(breakJson);
      expect(breakParsed.isBreak, true);
      expect(breakParsed.durationSeconds, 45);
    });

    test('Workout model computes total duration and steps count', () {
      const workout = Workout(
        id: 'wk-1',
        name: 'Upper Body Blitz',
        steps: [
          WorkoutStep(
            id: 's1',
            type: WorkoutStepType.exercise,
            title: 'Pushups',
            reps: 15,
            durationSeconds: 45,
          ),
          WorkoutStep(
            id: 's2',
            type: WorkoutStepType.restBreak,
            title: 'Break',
            durationSeconds: 30,
          ),
          WorkoutStep(
            id: 's3',
            type: WorkoutStepType.exercise,
            title: 'Pullups',
            reps: 10,
            durationSeconds: 40,
          ),
        ],
      );

      expect(workout.totalDurationSeconds, 115);
      expect(workout.exerciseCount, 2);
      expect(workout.breakCount, 1);

      final json = workout.toJson();
      final parsed = Workout.fromJson(json);
      expect(parsed.totalDurationSeconds, 115);
      expect(parsed.steps.length, 3);
    });

    test('DayPlan computes progress ratio and fulfilled state accurately', () {
      const items = [
        ScheduledItem(
          id: 'i1',
          date: '2026-10-24',
          type: ScheduledItemType.workout,
          targetId: 'wk-1',
          title: 'Morning Lift',
          isCompleted: true,
        ),
        ScheduledItem(
          id: 'i2',
          date: '2026-10-24',
          type: ScheduledItemType.meal,
          targetId: 'm-1',
          title: 'High Protein Lunch',
          isCompleted: false,
        ),
      ];

      final plan = DayPlan(date: '2026-10-24', items: items);
      expect(plan.totalCount, 2);
      expect(plan.completedCount, 1);
      expect(plan.progressRatio, 0.5);
      expect(plan.isFulfilled, false);

      final fulfilledItems = items.map((i) => i.copyWith(isCompleted: true)).toList();
      final fulfilledPlan = DayPlan(date: '2026-10-24', items: fulfilledItems);
      expect(fulfilledPlan.progressRatio, 1.0);
      expect(fulfilledPlan.isFulfilled, true);
    });
  });

  group('Active Workout Execution State Machine Tests', () {
    test('Exercise/break never starts until user presses startStep', () async {
      final tempDir = Directory.systemTemp.createTempSync('viking_test_');
      final storage = StorageService(overrideDir: tempDir);
      final planRepo = PlanRepository(storage: storage);

      const workout = Workout(
        id: 'test-wk-exec',
        name: 'Test Execution',
        steps: [
          WorkoutStep(
            id: 's1',
            type: WorkoutStepType.exercise,
            title: 'Dips',
            reps: 10,
            durationSeconds: 20,
          ),
          WorkoutStep(
            id: 's2',
            type: WorkoutStepType.restBreak,
            title: 'Rest',
            durationSeconds: 15,
          ),
        ],
      );

      final vm = ActiveWorkoutViewModel(
        workout: workout,
        planRepository: planRepo,
      );

      // Verify initial state: NOT active until user presses start
      expect(vm.currentStepIndex, 0);
      expect(vm.isStepActive, false);
      expect(vm.isPaused, false);
      expect(vm.secondsRemaining, 20);

      // User presses start
      vm.startStep();
      expect(vm.isStepActive, true);
      expect(vm.isPaused, false);

      // User pauses
      vm.pause();
      expect(vm.isPaused, true);

      // User resumes
      vm.resume();
      expect(vm.isPaused, false);

      // Directly jumping to next step
      await vm.jumpToNextStep();
      expect(vm.currentStepIndex, 1);
      // Crucial rule: new step is NOT active until user presses start for that step
      expect(vm.isStepActive, false);
      expect(vm.secondsRemaining, 15);

      // Finish workout on next jump
      await vm.jumpToNextStep();
      expect(vm.isCompleted, true);

      // Check that workout was marked completed for today's plan
      final todayStr = PlanRepository.formatDate(DateTime.now());
      final todayItems = await planRepo.getItemsForDate(todayStr);
      final completedItem = todayItems.firstWhere((i) => i.targetId == 'test-wk-exec');
      expect(completedItem.isCompleted, true);

      vm.dispose();
      tempDir.deleteSync(recursive: true);
    });
  });
}
