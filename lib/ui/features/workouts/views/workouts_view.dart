import 'package:flutter/material.dart';
import '../../../../data/models/exercise_model.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/plan_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/viking_card.dart';
import '../../active_workout/views/active_workout_view.dart';
import '../view_models/workouts_view_model.dart';
import 'exercise_form_modal.dart';
import 'workout_builder_view.dart';

class WorkoutsView extends StatefulWidget {
  final WorkoutsViewModel viewModel;
  final PlanRepository planRepository;

  const WorkoutsView({
    super.key,
    required this.viewModel,
    required this.planRepository,
  });

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.viewModel.selectedTabIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      widget.viewModel.setTabIndex(_tabController.index);
    }
  }

  void _openExerciseModal(BuildContext context, [Exercise? exercise]) {
    ExerciseFormModal.show(
      context: context,
      exercise: exercise,
      onSave: (saved) {
        widget.viewModel.saveExercise(saved);
      },
    );
  }

  void _openWorkoutBuilder(BuildContext context, [Workout? workout]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutBuilderView(
          initialWorkout: workout,
          exercisePool: widget.viewModel.filteredExercises,
          onSave: (saved) {
            widget.viewModel.saveWorkout(saved);
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required String title, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete $title?'),
        content: Text(
          'Are you sure you want to permanently delete "$title"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimson),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    if (mins == 0) return '${remainingSecs}s';
    return '${mins}m ${remainingSecs}s';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Tab Bar Header
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fitness_center_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('My Workouts'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.format_list_bulleted_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('My Exercises'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWorkoutsTab(context),
                          _buildExercisesTab(context),
                        ],
                      ),
                    ),
                  ],
                ),

                // Prominent Floating "+" button in the bottom center
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.large(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        onPressed: () {
                          if (_tabController.index == 0) {
                            _openWorkoutBuilder(context);
                          } else {
                            _openExerciseModal(context);
                          }
                        },
                        child: const Icon(Icons.add_rounded, size: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab(BuildContext context) {
    final workouts = widget.viewModel.filteredWorkouts;

    return RefreshIndicator(
      onRefresh: () => widget.viewModel.loadData(forceReload: true),
      color: AppColors.emerald,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          SearchField(
            hint: 'Search workouts by name or description...',
            onChanged: (q) => widget.viewModel.setWorkoutSearch(q),
          ),
          const SizedBox(height: 16),
          if (workouts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'No workouts found',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the big "+" button below to build your first routine!',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...workouts.map((workout) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VikingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              workout.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                            color: AppColors.surfaceElevated,
                            onSelected: (val) {
                              if (val == 'edit') {
                                _openWorkoutBuilder(context, workout);
                              } else if (val == 'delete') {
                                _confirmDelete(
                                  context,
                                  title: workout.name,
                                  onConfirm: () => widget.viewModel.deleteWorkout(workout.id),
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                                    SizedBox(width: 8),
                                    Text('Edit Workout'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: AppColors.crimson),
                                    SizedBox(width: 8),
                                    Text('Delete Workout', style: TextStyle(color: AppColors.crimson)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (workout.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          workout.description,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, color: AppColors.cyan, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(workout.totalDurationSeconds),
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.fitness_center_rounded, color: AppColors.emerald, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${workout.exerciseCount} exercises',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          if (workout.breakCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bedtime_rounded, color: AppColors.gold, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${workout.breakCount} breaks',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
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
                              planRepository: widget.planRepository,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildExercisesTab(BuildContext context) {
    final exercises = widget.viewModel.filteredExercises;

    return RefreshIndicator(
      onRefresh: () => widget.viewModel.loadData(forceReload: true),
      color: AppColors.emerald,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          SearchField(
            hint: 'Search exercises by name, muscle, or difficulty...',
            onChanged: (q) => widget.viewModel.setExerciseSearch(q),
          ),
          const SizedBox(height: 16),
          if (exercises.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'No exercises found',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the big "+" button below to save an exercise to your pool!',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...exercises.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VikingCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGaze,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.fitness_center_rounded, color: AppColors.emerald, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  '${exercise.durationSeconds}s / rep',
                                  style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${exercise.category}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${exercise.difficulty}',
                                  style: const TextStyle(color: AppColors.gold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                        onPressed: () => _openExerciseModal(context, exercise),
                        tooltip: 'Edit Exercise',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                        onPressed: () {
                          _confirmDelete(
                            context,
                            title: exercise.name,
                            onConfirm: () => widget.viewModel.deleteExercise(exercise.id),
                          );
                        },
                        tooltip: 'Delete Exercise',
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
