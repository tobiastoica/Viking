import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/plan_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../../data/repositories/workout_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circular_day_progress.dart';
import '../view_models/plan_view_model.dart';
import 'add_to_day_modal.dart';
import 'day_detail_modal.dart';

class PlanView extends StatelessWidget {
  final PlanViewModel viewModel;
  final WorkoutRepository workoutRepository;
  final PlanRepository planRepository;

  const PlanView({
    super.key,
    required this.viewModel,
    required this.workoutRepository,
    required this.planRepository,
  });

  void _onCellTap(BuildContext context, String dateStr) {
    viewModel.selectDate(dateStr);
    DayDetailModal.show(
      context: context,
      date: dateStr,
      viewModel: viewModel,
      workoutRepository: workoutRepository,
      planRepository: planRepository,
    );
  }

  void _onCellLongPress(BuildContext context, String dateStr) {
    viewModel.selectDate(dateStr);
    AddToDayModal.show(
      context: context,
      date: dateStr,
      availableWorkouts: viewModel.availableWorkouts,
      onWorkoutSelected: (w) => viewModel.addWorkoutToDate(dateStr, w),
      onMealSelected: (title, sub) => viewModel.addMealToDate(dateStr, title, sub),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final currentMonth = viewModel.currentMonth;
        final monthTitle = DateFormat('MMMM yyyy').format(currentMonth);
        final todayStr = PlanRepository.formatDate(DateTime.now());

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => viewModel.loadMonth(forceReload: true),
              color: AppColors.emerald,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Month navigation bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 28),
                          onPressed: viewModel.previousMonth,
                          tooltip: 'Previous Month',
                        ),
                        Column(
                          children: [
                            Text(
                              monthTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: viewModel.jumpToToday,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldGaze,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Jump to Today',
                                  style: TextStyle(
                                    color: AppColors.emeraldLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary, size: 28),
                          onPressed: viewModel.nextMonth,
                          tooltip: 'Next Month',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gestures hint banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.touch_app_rounded, color: AppColors.emerald, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap cell to view & edit • Hold (long press) cell to quickly add workouts or meals',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calendar Grid Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Weekday headers (Mon - Sun)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                            return SizedBox(
                              width: 38,
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 10),

                        // Month days grid
                        _buildDaysGrid(context, currentMonth, todayStr),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaysGrid(BuildContext context, DateTime currentMonth, String todayStr) {
    final year = currentMonth.year;
    final month = currentMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // weekday is 1 (Mon) to 7 (Sun)
    final leadingBlanks = firstDayOfMonth.weekday - 1;

    final totalCells = leadingBlanks + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - leadingBlanks + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                // Empty cell padding
                return const SizedBox(width: 44, height: 56);
              }

              final dateStr = '$year-${month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
              final dayPlan = viewModel.monthPlans[dateStr] ?? DayPlan(date: dateStr);
              final isToday = dateStr == todayStr;
              final isFulfilled = dayPlan.isFulfilled;
              final hasItems = dayPlan.totalCount > 0;

              return SizedBox(
                width: 44,
                height: 56,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onCellTap(context, dateStr),
                    onLongPress: () => _onCellLongPress(context, dateStr),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        // "A day turns green beautifully when all objectives on a day are fulfilled"
                        color: isFulfilled
                            ? AppColors.emerald.withValues(alpha: 0.2)
                            : (isToday ? AppColors.surfaceElevated : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFulfilled
                              ? AppColors.emerald
                              : (isToday ? AppColors.emerald.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.3)),
                          width: isFulfilled ? 1.5 : (isToday ? 1.2 : 0.8),
                        ),
                        boxShadow: isFulfilled
                            ? [
                                BoxShadow(
                                  color: AppColors.emerald.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Day Number
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: isFulfilled
                                  ? AppColors.emeraldLight
                                  : (isToday ? AppColors.emerald : AppColors.textPrimary),
                              fontWeight: isToday || isFulfilled ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),

                          // Progress circle indicator
                          if (hasItems)
                            CircularDayProgress(
                              progress: dayPlan.progressRatio,
                              isFulfilled: isFulfilled,
                              size: 24,
                              strokeWidth: 2.5,
                              centerChild: isFulfilled
                                  ? const Icon(Icons.check_rounded, color: AppColors.emerald, size: 14)
                                  : null,
                            )
                          else
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday ? AppColors.emerald.withValues(alpha: 0.4) : Colors.transparent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
