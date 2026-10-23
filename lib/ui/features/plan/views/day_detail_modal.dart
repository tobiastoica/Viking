import 'package:flutter/material.dart';
import '../../../../data/models/plan_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../../data/repositories/workout_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circular_day_progress.dart';
import '../../active_workout/views/active_workout_view.dart';
import '../view_models/plan_view_model.dart';
import 'add_to_day_modal.dart';

class DayDetailModal extends StatelessWidget {
  final String date;
  final PlanViewModel viewModel;
  final WorkoutRepository workoutRepository;
  final PlanRepository planRepository;

  const DayDetailModal({
    super.key,
    required this.date,
    required this.viewModel,
    required this.workoutRepository,
    required this.planRepository,
  });

  static Future<void> show({
    required BuildContext context,
    required String date,
    required PlanViewModel viewModel,
    required WorkoutRepository workoutRepository,
    required PlanRepository planRepository,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailModal(
        date: date,
        viewModel: viewModel,
        workoutRepository: workoutRepository,
        planRepository: planRepository,
      ),
    );
  }

  void _openAddModal(BuildContext context) {
    AddToDayModal.show(
      context: context,
      date: date,
      availableWorkouts: viewModel.availableWorkouts,
      onWorkoutSelected: (w) => viewModel.addWorkoutToDate(date, w),
      onMealSelected: (title, sub) => viewModel.addMealToDate(date, title, sub),
    );
  }

  Future<void> _launchWorkout(BuildContext context, String workoutId) async {
    final workout = await workoutRepository.getWorkoutById(workoutId);
    if (workout != null && context.mounted) {
      Navigator.of(context).pop(); // close modal
      ActiveWorkoutView.launch(
        context: context,
        workout: workout,
        planRepository: planRepository,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final dayPlan = viewModel.monthPlans[date] ?? DayPlan(date: date);
        final isFulfilled = dayPlan.isFulfilled;
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          margin: EdgeInsets.only(bottom: bottomInset),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header with Progress Circle
                Row(
                  children: [
                    CircularDayProgress(
                      progress: dayPlan.progressRatio,
                      isFulfilled: isFulfilled,
                      size: 48,
                      strokeWidth: 4,
                      centerChild: isFulfilled
                          ? const Icon(Icons.check_rounded, color: AppColors.emerald, size: 24)
                          : Text(
                              '${(dayPlan.progressRatio * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dayPlan.totalCount == 0
                                ? 'No objectives planned yet'
                                : '${dayPlan.completedCount} of ${dayPlan.totalCount} objectives completed',
                            style: TextStyle(
                              fontSize: 13,
                              color: isFulfilled ? AppColors.emeraldLight : AppColors.textSecondary,
                              fontWeight: isFulfilled ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fulfilled congratulations banner
                if (isFulfilled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGaze,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.stars_rounded, color: AppColors.emerald, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'All Day Objectives Fulfilled! Outstanding work, Viking!',
                            style: TextStyle(
                              color: AppColors.emeraldLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action to Add
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Day Objectives:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.emerald),
                      label: const Text('Add Objective', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
                      onPressed: () => _openAddModal(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items list
                Flexible(
                  child: dayPlan.items.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_note_outlined, size: 36, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              const Text(
                                'No objectives scheduled for this date.',
                                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Schedule Workout or Meal'),
                                onPressed: () => _openAddModal(context),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: dayPlan.items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = dayPlan.items[index];
                            final isWorkout = item.isWorkout;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item.isCompleted
                                    ? AppColors.surfaceElevated.withValues(alpha: 0.5)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: item.isCompleted
                                      ? AppColors.emerald.withValues(alpha: 0.3)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Checkbox
                                  Checkbox(
                                    value: item.isCompleted,
                                    activeColor: AppColors.emerald,
                                    checkColor: Colors.black,
                                    onChanged: (val) {
                                      if (val != null) {
                                        viewModel.toggleCompletion(item.id, val);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  // Icon
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isWorkout ? AppColors.emeraldGaze : AppColors.goldGaze,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isWorkout ? Icons.fitness_center_rounded : Icons.restaurant_rounded,
                                      color: isWorkout ? AppColors.emerald : AppColors.gold,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Titles
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: item.isCompleted
                                                ? AppColors.textSecondary
                                                : AppColors.textPrimary,
                                            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        if (item.subtitle.isNotEmpty)
                                          Text(
                                            item.subtitle,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Quick launch for workout
                                  if (isWorkout) ...[
                                    IconButton(
                                      icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.emerald, size: 26),
                                      tooltip: 'Activate Workout',
                                      onPressed: () => _launchWorkout(context, item.targetId),
                                    ),
                                  ],

                                  // Delete
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                                    onPressed: () => viewModel.deleteItem(item.id),
                                    tooltip: 'Delete Objective',
                                  ),
                                ],
                              ),
                            );
                          },
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
