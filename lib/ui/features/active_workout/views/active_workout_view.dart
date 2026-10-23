import 'package:flutter/material.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../view_models/active_workout_view_model.dart';
import 'workout_completion_dialog.dart';

class ActiveWorkoutView extends StatefulWidget {
  final Workout workout;
  final PlanRepository planRepository;

  const ActiveWorkoutView({
    super.key,
    required this.workout,
    required this.planRepository,
  });

  static Future<void> launch({
    required BuildContext context,
    required Workout workout,
    required PlanRepository planRepository,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ActiveWorkoutView(
          workout: workout,
          planRepository: planRepository,
        ),
      ),
    );
  }

  @override
  State<ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends State<ActiveWorkoutView> {
  late ActiveWorkoutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ActiveWorkoutViewModel(
      workout: widget.workout,
      planRepository: widget.planRepository,
    );
    _viewModel.addListener(_onViewModelUpdate);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (_viewModel.isCompleted && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => WorkoutCompletionDialog(
          workoutTitle: widget.workout.name,
          totalElapsedSeconds: _viewModel.totalElapsedSeconds,
          completedSteps: _viewModel.totalSteps,
          onDismiss: () {
            Navigator.of(ctx).pop(); // pop dialog
            Navigator.of(context).pop(); // pop active workout view
          },
        ),
      );
    }
  }

  String _formatSeconds(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Exit Workout?'),
        content: const Text(
          'Your progress for this workout session will not be saved if you leave before completion.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Resume Workout', style: TextStyle(color: AppColors.emerald)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quit', style: TextStyle(color: AppColors.crimson)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final step = _viewModel.currentStep;
        final nextStep = _viewModel.nextStep;
        final isBreak = step.isBreak;
        final isWaiting = !_viewModel.isStepActive;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Top HUD Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: _confirmExit,
                        tooltip: 'Exit',
                      ),
                      Column(
                        children: [
                          Text(
                            widget.workout.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'STEP ${_viewModel.currentStepIndex + 1} OF ${_viewModel.totalSteps}',
                            style: const TextStyle(
                              color: AppColors.emeraldLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          _formatSeconds(_viewModel.totalElapsedSeconds),
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Overall progress line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _viewModel.overallProgress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isBreak ? AppColors.cyan : AppColors.emerald,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Central Workout Ring & Timer
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular indicator background & active sweep
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: _viewModel.currentStepProgress,
                          strokeWidth: 10,
                          backgroundColor: AppColors.border.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isBreak ? AppColors.cyan : AppColors.emerald,
                          ),
                        ),
                      ),
                      // Inner content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBreak ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
                            color: isBreak ? AppColors.cyan : AppColors.emerald,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatSeconds(_viewModel.secondsRemaining),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isBreak ? AppColors.cyanGaze : AppColors.emeraldGaze,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isBreak
                                  ? 'REST BREAK'
                                  : '${step.reps} REPETITIONS',
                              style: TextStyle(
                                color: isBreak ? AppColors.cyan : AppColors.emeraldLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Current Step Title & Cue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (step.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          step.notes,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // Action Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: isWaiting
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    color: isBreak ? AppColors.cyan : AppColors.emerald,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBreak ? 'Ready to Rest? Press Start' : 'Ready? Press Start to Begin Step',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isBreak ? AppColors.cyan : AppColors.emerald,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                                label: Text(
                                  isBreak ? 'START BREAK' : 'START STEP',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                                onPressed: _viewModel.startStep,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            // Previous step
                            if (_viewModel.currentStepIndex > 0) ...[
                              IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surfaceElevated,
                                  foregroundColor: AppColors.textSecondary,
                                ),
                                icon: const Icon(Icons.skip_previous_rounded),
                                onPressed: _viewModel.previousStep,
                                tooltip: 'Previous Step',
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Pause / Resume
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _viewModel.isPaused
                                        ? AppColors.emerald
                                        : AppColors.surfaceElevated,
                                    foregroundColor: _viewModel.isPaused
                                        ? Colors.black
                                        : AppColors.textPrimary,
                                    side: BorderSide(
                                      color: _viewModel.isPaused ? AppColors.emerald : AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  icon: Icon(
                                    _viewModel.isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    size: 26,
                                  ),
                                  label: Text(
                                    _viewModel.isPaused ? 'RESUME' : 'PAUSE',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                  onPressed: () {
                                    if (_viewModel.isPaused) {
                                      _viewModel.resume();
                                    } else {
                                      _viewModel.pause();
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Jump directly to Next Step
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  icon: const Icon(Icons.skip_next_rounded, size: 26),
                                  label: Text(
                                    _viewModel.currentStepIndex + 1 < _viewModel.totalSteps
                                        ? 'NEXT STEP'
                                        : 'FINISH',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                  onPressed: _viewModel.jumpToNextStep,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 20),

                // "Up Next" preview footer
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          nextStep == null
                              ? Icons.flag_rounded
                              : (nextStep.isBreak ? Icons.bedtime_rounded : Icons.fitness_center_rounded),
                          color: nextStep == null
                              ? AppColors.gold
                              : (nextStep.isBreak ? AppColors.cyan : AppColors.emerald),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'UP NEXT',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              nextStep == null
                                  ? 'Workout Complete 🎉'
                                  : nextStep.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (nextStep != null)
                        Text(
                          nextStep.isBreak
                              ? '${nextStep.durationSeconds}s break'
                              : '${nextStep.reps} reps',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
