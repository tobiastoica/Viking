import 'package:flutter/material.dart';
import '../../../../data/models/exercise_model.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseFormModal extends StatefulWidget {
  final Exercise? initialExercise;
  final ValueChanged<Exercise> onSave;

  const ExerciseFormModal({
    super.key,
    this.initialExercise,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    Exercise? exercise,
    required ValueChanged<Exercise> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseFormModal(
        initialExercise: exercise,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ExerciseFormModal> createState() => _ExerciseFormModalState();
}

class _ExerciseFormModalState extends State<ExerciseFormModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _descriptionController;

  late String _difficulty;
  late String _category;

  final List<String> _difficulties = const ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _categories = const [
    'General',
    'Chest',
    'Back',
    'Legs',
    'Arms',
    'Core',
    'Cardio',
    'Full Body',
  ];

  @override
  void initState() {
    super.initState();
    final ex = widget.initialExercise;
    _nameController = TextEditingController(text: ex?.name ?? '');
    _durationController = TextEditingController(text: ex != null ? ex.durationSeconds.toString() : '30');
    _caloriesController = TextEditingController(text: ex != null && ex.caloriesBurned > 0 ? ex.caloriesBurned.toString() : '8');
    _descriptionController = TextEditingController(text: ex?.description ?? '');
    _difficulty = ex?.difficulty ?? 'Intermediate';
    _category = ex?.category ?? 'General';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final duration = int.tryParse(_durationController.text.trim()) ?? 30;
    final calories = double.tryParse(_caloriesController.text.trim()) ?? 0.0;
    final id = widget.initialExercise?.id ?? 'ex-${DateTime.now().millisecondsSinceEpoch}';

    final exercise = Exercise(
      id: id,
      name: _nameController.text.trim(),
      durationSeconds: duration,
      caloriesBurned: calories,
      difficulty: _difficulty,
      category: _category,
      description: _descriptionController.text.trim(),
      customProperties: widget.initialExercise?.customProperties ?? const {},
    );

    widget.onSave(exercise);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialExercise != null;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
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

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Exercise' : 'Create New Exercise',
                    style: const TextStyle(
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
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name *',
                  hintText: 'e.g. Diamond Push-ups',
                  prefixIcon: Icon(Icons.fitness_center_rounded, color: AppColors.emerald, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Duration & Calories in Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (sec) *',
                        hintText: '30',
                        prefixIcon: Icon(Icons.timer_outlined, color: AppColors.cyan, size: 20),
                        suffixText: 's',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final num = int.tryParse(val.trim());
                        if (num == null || num <= 0) return '> 0 sec';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal)',
                        hintText: '8.0',
                        prefixIcon: Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 20),
                        suffixText: 'kcal',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category and Difficulty dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined, color: AppColors.textSecondary, size: 20),
                      ),
                      dropdownColor: AppColors.surfaceElevated,
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        prefixIcon: Icon(Icons.speed_rounded, color: AppColors.textSecondary, size: 20),
                      ),
                      dropdownColor: AppColors.surfaceElevated,
                      items: _difficulties.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _difficulty = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description / Coaching cues
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Instructions / Notes (Optional)',
                  hintText: 'Form cues, tempo, equipment...',
                  prefixIcon: Icon(Icons.notes_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Actions (Cancel and Save)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Save Changes' : 'Create Exercise'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
