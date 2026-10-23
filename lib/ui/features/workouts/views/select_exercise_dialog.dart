import 'package:flutter/material.dart';
import '../../../../data/models/exercise_model.dart';
import '../../../../data/models/workout_step_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/search_field.dart';

class SelectExerciseDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final ValueChanged<WorkoutStep> onExerciseSelected;

  const SelectExerciseDialog({
    super.key,
    required this.exercises,
    required this.onExerciseSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Exercise> exercises,
    required ValueChanged<WorkoutStep> onExerciseSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectExerciseDialog(
        exercises: exercises,
        onExerciseSelected: onExerciseSelected,
      ),
    );
  }

  @override
  State<SelectExerciseDialog> createState() => _SelectExerciseDialogState();
}

class _SelectExerciseDialogState extends State<SelectExerciseDialog> {
  String _searchQuery = '';
  Exercise? _selectedExercise;
  int _reps = 10;

  List<Exercise> get _filteredExercises {
    if (_searchQuery.trim().isEmpty) return widget.exercises;
    final q = _searchQuery.toLowerCase();
    return widget.exercises.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
    }).toList();
  }

  int get _computedDuration {
    if (_selectedExercise == null) return 0;
    return _reps * _selectedExercise!.durationSeconds;
  }

  void _confirmSelection() {
    if (_selectedExercise == null) return;

    final step = WorkoutStep(
      id: 'step-${DateTime.now().millisecondsSinceEpoch}',
      type: WorkoutStepType.exercise,
      exerciseId: _selectedExercise!.id,
      title: _selectedExercise!.name,
      reps: _reps,
      durationSeconds: _computedDuration,
      notes: _selectedExercise!.description,
    );

    widget.onExerciseSelected(step);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Column(
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
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Exercise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search bar
          SearchField(
            hint: 'Search exercise by name or category...',
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),

          // List of exercises
          Expanded(
            child: _filteredExercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises found matching search.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredExercises.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ex = _filteredExercises[index];
                      final isSelected = _selectedExercise?.id == ex.id;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedExercise = ex;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.emeraldGaze : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.emerald : AppColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.emerald : AppColors.surfaceHighlight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.fitness_center_rounded,
                                  color: isSelected ? Colors.black : AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${ex.category} • ${ex.durationSeconds}s / rep',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.emerald,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Reps & duration summary drawer (if selected)
          if (_selectedExercise != null) ...[
            const Divider(color: AppColors.border, height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Repetitions:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                            onPressed: () {
                              if (_reps > 1) setState(() => _reps--);
                            },
                          ),
                          Text(
                            '$_reps reps',
                            style: const TextStyle(
                              color: AppColors.emerald,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.emerald),
                            onPressed: () {
                              setState(() => _reps++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Computed Time Needed:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_computedDuration}s (${(_computedDuration / 60).toStringAsFixed(1)} min)',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Exercise to Workout'),
                onPressed: _confirmSelection,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
