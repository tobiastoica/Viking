import 'package:flutter/material.dart';
import '../../../../data/models/exercise_model.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/models/workout_step_model.dart';
import '../../../core/theme/app_colors.dart';
import 'select_exercise_dialog.dart';

class WorkoutBuilderView extends StatefulWidget {
  final Workout? initialWorkout;
  final List<Exercise> exercisePool;
  final ValueChanged<Workout> onSave;

  const WorkoutBuilderView({
    super.key,
    this.initialWorkout,
    required this.exercisePool,
    required this.onSave,
  });

  @override
  State<WorkoutBuilderView> createState() => _WorkoutBuilderViewState();
}

class _WorkoutBuilderViewState extends State<WorkoutBuilderView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late List<WorkoutStep> _steps;

  @override
  void initState() {
    super.initState();
    final w = widget.initialWorkout;
    _nameController = TextEditingController(text: w?.name ?? '');
    _descController = TextEditingController(text: w?.description ?? '');
    _steps = w != null ? List<WorkoutStep>.from(w.steps) : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  int get _totalSeconds =>
      _steps.fold(0, (sum, step) => sum + step.durationSeconds);

  String _formatTotalDuration(int seconds) {
    final mins = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    if (mins == 0) return '${remainingSecs}s';
    return '${mins}m ${remainingSecs}s';
  }

  void _addExerciseStep() {
    if (widget.exercisePool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No exercises saved yet! Please add exercises to your library first.'),
          backgroundColor: AppColors.crimson,
        ),
      );
      return;
    }

    SelectExerciseDialog.show(
      context: context,
      exercises: widget.exercisePool,
      onExerciseSelected: (step) {
        setState(() {
          _steps.add(step);
        });
      },
    );
  }

  void _addBreakStep() {
    int breakDuration = 30;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Row(
                children: [
                  Icon(Icons.bedtime_rounded, color: AppColors.cyan),
                  SizedBox(width: 10),
                  Text('Add Rest Break'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose rest break duration:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${breakDuration}s',
                      style: const TextStyle(
                        color: AppColors.cyan,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [15, 30, 45, 60, 90].map((sec) {
                      final isSelected = breakDuration == sec;
                      return ChoiceChip(
                        label: Text('${sec}s'),
                        selected: isSelected,
                        selectedColor: AppColors.cyan,
                        backgroundColor: AppColors.surfaceElevated,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => breakDuration = sec);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan),
                  onPressed: () {
                    final breakStep = WorkoutStep(
                      id: 'break-${DateTime.now().millisecondsSinceEpoch}',
                      type: WorkoutStepType.restBreak,
                      title: 'Rest Break',
                      durationSeconds: breakDuration,
                      notes: 'Catch your breath and hydrate.',
                    );
                    setState(() {
                      _steps.add(breakStep);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Break', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise or break to the workout!'),
          backgroundColor: AppColors.crimson,
        ),
      );
      return;
    }

    final id = widget.initialWorkout?.id ?? 'wk-${DateTime.now().millisecondsSinceEpoch}';
    final workout = Workout(
      id: id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      steps: _steps,
      colorHex: widget.initialWorkout?.colorHex ?? '#10B981',
      customProperties: widget.initialWorkout?.customProperties ?? const {},
    );

    widget.onSave(workout);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialWorkout != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Workout' : 'Create Workout'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Cancel',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
              onPressed: _save,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top settings card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      labelText: 'Workout Name *',
                      hintText: 'e.g. Spartan Strength Routine',
                      prefixIcon: Icon(Icons.fitness_center_rounded, color: AppColors.emerald, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please provide a workout name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'e.g. Focus on chest & core hypertrophy',
                      prefixIcon: Icon(Icons.description_outlined, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Metrics summary banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricChip(
                          icon: Icons.timer_outlined,
                          color: AppColors.cyan,
                          label: 'Duration',
                          value: _formatTotalDuration(_totalSeconds),
                        ),
                        Container(width: 1, height: 24, color: AppColors.border),
                        _buildMetricChip(
                          icon: Icons.fitness_center_rounded,
                          color: AppColors.emerald,
                          label: 'Exercises',
                          value: '${_steps.where((s) => s.isExercise).length}',
                        ),
                        Container(width: 1, height: 24, color: AppColors.border),
                        _buildMetricChip(
                          icon: Icons.bedtime_rounded,
                          color: AppColors.gold,
                          label: 'Breaks',
                          value: '${_steps.where((s) => s.isBreak).length}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Step creation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.emerald,
                        side: const BorderSide(color: AppColors.emerald, width: 1.2),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add Exercise'),
                      onPressed: _addExerciseStep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.cyan,
                        side: const BorderSide(color: AppColors.cyan, width: 1.2),
                      ),
                      icon: const Icon(Icons.bedtime_outlined, size: 20),
                      label: const Text('Add Break'),
                      onPressed: _addBreakStep,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Draggable Steps Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workout Sequence (Drag to reorder):',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_steps.length} steps',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Reorderable Steps List
            Expanded(
              child: _steps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.drag_indicator_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No steps in sequence yet',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "+ Add Exercise" or "+ Add Break" above to build your sequence.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _steps.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final item = _steps.removeAt(oldIndex);
                          _steps.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final step = _steps[index];
                        final isEx = step.isExercise;

                        return Container(
                          key: ValueKey(step.id),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isEx ? AppColors.border : AppColors.cyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isEx ? AppColors.emeraldGaze : AppColors.cyanGaze,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isEx ? Icons.fitness_center_rounded : Icons.bedtime_rounded,
                                color: isEx ? AppColors.emerald : AppColors.cyan,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              step.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              isEx
                                  ? '${step.reps} reps • ${step.durationSeconds}s'
                                  : 'Rest for ${step.durationSeconds}s',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _steps.removeAt(index);
                                    });
                                  },
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(
                                    Icons.drag_handle_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
