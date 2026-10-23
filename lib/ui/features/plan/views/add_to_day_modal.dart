import 'package:flutter/material.dart';
import '../../../../data/models/workout_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/search_field.dart';

class AddToDayModal extends StatefulWidget {
  final String date;
  final List<Workout> availableWorkouts;
  final ValueChanged<Workout> onWorkoutSelected;
  final Function(String title, String subtitle) onMealSelected;

  const AddToDayModal({
    super.key,
    required this.date,
    required this.availableWorkouts,
    required this.onWorkoutSelected,
    required this.onMealSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String date,
    required List<Workout> availableWorkouts,
    required ValueChanged<Workout> onWorkoutSelected,
    required Function(String title, String subtitle) onMealSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToDayModal(
        date: date,
        availableWorkouts: availableWorkouts,
        onWorkoutSelected: onWorkoutSelected,
        onMealSelected: onMealSelected,
      ),
    );
  }

  @override
  State<AddToDayModal> createState() => _AddToDayModalState();
}

class _AddToDayModalState extends State<AddToDayModal> {
  int _viewMode = 0; // 0: Choose Type (Workout or Meal), 1: Select Workout, 2: Add Meal
  String _workoutSearch = '';

  List<Workout> get _filteredWorkouts {
    if (_workoutSearch.trim().isEmpty) return widget.availableWorkouts;
    final q = _workoutSearch.toLowerCase();
    return widget.availableWorkouts.where((w) {
      return w.name.toLowerCase().contains(q) ||
          w.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: _buildCurrentView(),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewMode) {
      case 1:
        return _buildSelectWorkoutView();
      case 2:
        return _buildAddMealView();
      default:
        return _buildChooseTypeView();
    }
  }

  Widget _buildChooseTypeView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add to Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Date: ${widget.date}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Workout Option
        InkWell(
          onTap: () => setState(() => _viewMode = 1),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGaze,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: AppColors.emerald, size: 22),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Workout Routine',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Select from your library of created workouts',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Meal Option (WIP)
        InkWell(
          onTap: () => setState(() => _viewMode = 2),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.goldGaze,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Add Planned Meal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '(WIP)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Schedule a meal target for the day',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectWorkoutView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
              onPressed: () => setState(() => _viewMode = 0),
            ),
            const Text(
              'Select Workout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SearchField(
          hint: 'Search workouts to schedule...',
          onChanged: (q) => setState(() => _workoutSearch = q),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: _filteredWorkouts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No workouts found.', style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredWorkouts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final w = _filteredWorkouts[index];
                    return InkWell(
                      onTap: () {
                        widget.onWorkoutSelected(w);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.emeraldGaze,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fitness_center_rounded, color: AppColors.emerald, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${w.steps.length} steps • ${(w.totalDurationSeconds / 60).toStringAsFixed(1)} mins',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle_outline_rounded, color: AppColors.emerald),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddMealView() {
    final mealController = TextEditingController(text: 'High Protein Meal');
    final descController = TextEditingController(text: 'Calories & macros target');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
              onPressed: () => setState(() => _viewMode = 0),
            ),
            const Text(
              'Add Meal (WIP)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: mealController,
          decoration: const InputDecoration(
            labelText: 'Meal Title',
            prefixIcon: Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descController,
          decoration: const InputDecoration(
            labelText: 'Description / Targets (Optional)',
            prefixIcon: Icon(Icons.notes_rounded, color: AppColors.textSecondary, size: 20),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () {
              widget.onMealSelected(
                mealController.text.trim().isEmpty ? 'Meal' : mealController.text.trim(),
                descController.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Add Meal to Day', style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}
