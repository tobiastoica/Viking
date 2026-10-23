import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circular_day_progress.dart';
import '../../../core/widgets/viking_card.dart';
import '../../active_workout/views/active_workout_view.dart';
import '../view_models/home_view_model.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel viewModel;
  final PlanRepository planRepository;
  final VoidCallback onNavigateToWorkouts;
  final VoidCallback onNavigateToPlan;

  const HomeView({
    super.key,
    required this.viewModel,
    required this.planRepository,
    required this.onNavigateToWorkouts,
    required this.onNavigateToPlan,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final today = DateTime.now();
        final dateHeader = DateFormat('EEEE, MMMM d').format(today);
        final plan = viewModel.todayPlan;
        final isFulfilled = plan.isFulfilled;
        final workouts = plan.workouts;
        final meals = plan.meals;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => viewModel.loadToday(forceReload: true),
              color: AppColors.emerald,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Header Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateHeader.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.emeraldLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Today\'s Battle Plan',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Today Progress Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isFulfilled
                          ? const LinearGradient(
                              colors: [Color(0xFF0F291E), Color(0xFF131D27)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFulfilled ? AppColors.emerald : AppColors.border,
                        width: isFulfilled ? 1.5 : 1.0,
                      ),
                      boxShadow: isFulfilled
                          ? [
                              BoxShadow(
                                color: AppColors.emerald.withValues(alpha: 0.2),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        CircularDayProgress(
                          progress: plan.progressRatio,
                          isFulfilled: isFulfilled,
                          size: 64,
                          strokeWidth: 5,
                          centerChild: isFulfilled
                              ? const Icon(Icons.check_rounded, color: AppColors.emerald, size: 32)
                              : Text(
                                  '${(plan.progressRatio * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFulfilled
                                    ? 'Day Completed!'
                                    : '${plan.completedCount} of ${plan.totalCount} Done',
                                style: TextStyle(
                                  color: isFulfilled ? AppColors.emeraldLight : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isFulfilled
                                    ? 'All workouts and nutrition goals crushed for today.'
                                    : (plan.totalCount == 0
                                        ? 'No routines scheduled yet for today.'
                                        : 'Execute today\'s routine to keep your streak alive!'),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Workouts Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Active Workouts Today',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onNavigateToWorkouts,
                        child: const Text('All Workouts', style: TextStyle(color: AppColors.emerald)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (workouts.isEmpty)
                    VikingCard(
                      child: Column(
                        children: [
                          const Icon(Icons.fitness_center_outlined, size: 36, color: AppColors.textMuted),
                          const SizedBox(height: 10),
                          const Text(
                            'No workouts scheduled for today',
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Schedule a workout from the calendar or start one now.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_month_rounded, size: 18),
                            label: const Text('Go to My Plan'),
                            onPressed: onNavigateToPlan,
                          ),
                        ],
                      ),
                    )
                  else
                    ...workouts.map((item) {
                      final workout = viewModel.workoutMap[item.targetId];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VikingCard(
                          isSelected: !item.isCompleted,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: item.isCompleted
                                                ? AppColors.textSecondary
                                                : AppColors.textPrimary,
                                            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        Text(
                                          item.subtitle.isNotEmpty
                                              ? item.subtitle
                                              : (workout != null
                                                  ? '${workout.steps.length} steps • ${(workout.totalDurationSeconds / 60).toStringAsFixed(1)}m'
                                                  : 'Workout'),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (item.isCompleted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.emeraldGaze,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'COMPLETED',
                                        style: TextStyle(
                                          color: AppColors.emerald,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (workout != null && !item.isCompleted) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.emerald,
                                      foregroundColor: Colors.black,
                                    ),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('ACTIVATE WORKOUT'),
                                    onPressed: () {
                                      ActiveWorkoutView.launch(
                                        context: context,
                                        workout: workout,
                                        planRepository: planRepository,
                                      ).then((_) {
                                        viewModel.loadToday();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // Planned Meals Section (WIP)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Planned Meals Today',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'WIP',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: onNavigateToPlan,
                        child: const Text('Add in Plan', style: TextStyle(color: AppColors.gold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (meals.isEmpty)
                    VikingCard(
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant_outlined, size: 36, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          const Text(
                            'No meals planned for today',
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add meal milestones from the My Plan calendar view.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    ...meals.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VikingCard(
                          child: Row(
                            children: [
                              Checkbox(
                                value: meal.isCompleted,
                                activeColor: AppColors.emerald,
                                checkColor: Colors.black,
                                onChanged: (val) {
                                  if (val != null) {
                                    viewModel.toggleCompletion(meal.id, val);
                                  }
                                },
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.goldGaze,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: meal.isCompleted
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                        decoration: meal.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (meal.subtitle.isNotEmpty)
                                      Text(
                                        meal.subtitle,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
