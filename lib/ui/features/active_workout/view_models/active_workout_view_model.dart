import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/models/workout_step_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../../data/services/feedback_service.dart';

class ActiveWorkoutViewModel extends ChangeNotifier {
  final Workout workout;
  final PlanRepository planRepository;
  final FeedbackService feedback;

  ActiveWorkoutViewModel({
    required this.workout,
    required this.planRepository,
    this.feedback = const FeedbackService(),
  }) {
    _initFirstStep();
  }

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  int _totalElapsedSeconds = 0;
  int get totalElapsedSeconds => _totalElapsedSeconds;

  bool _isStepActive = false;
  /// Mandatory requirement: No exercise or break starts unless user presses start for that step.
  bool get isStepActive => _isStepActive;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  Timer? _timer;

  WorkoutStep get currentStep => workout.steps[_currentStepIndex];

  WorkoutStep? get nextStep {
    if (_currentStepIndex + 1 < workout.steps.length) {
      return workout.steps[_currentStepIndex + 1];
    }
    return null;
  }

  int get totalSteps => workout.steps.length;

  double get currentStepProgress {
    final total = currentStep.durationSeconds;
    if (total <= 0) return 1.0;
    final elapsed = total - _secondsRemaining;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  double get overallProgress {
    if (totalSteps == 0) return 0.0;
    final baseProgress = _currentStepIndex / totalSteps;
    final stepContribution = (1.0 / totalSteps) * currentStepProgress;
    return (baseProgress + stepContribution).clamp(0.0, 1.0);
  }

  void _initFirstStep() {
    if (workout.steps.isNotEmpty) {
      _currentStepIndex = 0;
      _secondsRemaining = currentStep.durationSeconds;
      _isStepActive = false;
      _isPaused = false;
    }
  }

  /// Called when player presses "START STEP".
  void startStep() {
    _isStepActive = true;
    _isPaused = false;
    feedback.stepStart();
    _startTimer();
    notifyListeners();
  }

  void pause() {
    if (_isStepActive && !_isPaused) {
      _isPaused = true;
      _timer?.cancel();
      feedback.click();
      notifyListeners();
    }
  }

  void resume() {
    if (_isStepActive && _isPaused) {
      _isPaused = false;
      feedback.click();
      _startTimer();
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _totalElapsedSeconds++;

      if (_secondsRemaining > 1) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _secondsRemaining = 0;
        _timer?.cancel();
        _onStepTimerFinished();
      }
    });
  }

  Future<void> _onStepTimerFinished() async {
    feedback.stepComplete();
    if (_currentStepIndex + 1 < workout.steps.length) {
      _advanceToStep(_currentStepIndex + 1);
    } else {
      await _finishWorkout();
    }
  }

  /// Directly jump to the next exercise or break.
  Future<void> jumpToNextStep() async {
    _timer?.cancel();
    feedback.click();
    if (_currentStepIndex + 1 < workout.steps.length) {
      _advanceToStep(_currentStepIndex + 1);
    } else {
      await _finishWorkout();
    }
  }

  /// Navigate back to previous step if needed.
  void previousStep() {
    if (_currentStepIndex > 0) {
      _timer?.cancel();
      feedback.click();
      _advanceToStep(_currentStepIndex - 1);
    }
  }

  void _advanceToStep(int newIndex) {
    _currentStepIndex = newIndex;
    _secondsRemaining = currentStep.durationSeconds;
    // Rule: "no exercise/break starts unless the user presses start for that step"
    _isStepActive = false;
    _isPaused = false;
    notifyListeners();
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    _isCompleted = true;
    _isStepActive = false;
    _isPaused = false;
    notifyListeners();

    // Mark completed in PlanRepository for today!
    await planRepository.markWorkoutCompletedForToday(workout.id, workout.name);
    feedback.workoutFinished();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
