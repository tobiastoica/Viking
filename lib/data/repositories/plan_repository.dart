import 'package:intl/intl.dart';
import '../models/plan_model.dart';
import '../services/storage_service.dart';

class PlanRepository {
  static const String _fileName = 'schedules.json';
  final StorageService storage;
  List<ScheduledItem>? _cachedItems;

  PlanRepository({required this.storage});

  static String formatDate(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  Future<List<ScheduledItem>> getAllItems({bool forceReload = false}) async {
    if (!forceReload && _cachedItems != null) {
      return List.unmodifiable(_cachedItems!);
    }

    final rawList = await storage.readList(_fileName);
    if (rawList.isEmpty) {
      final initial = _createDefaultSchedule();
      await storage.writeList(_fileName, initial.map((i) => i.toJson()).toList());
      _cachedItems = initial;
      return List.unmodifiable(initial);
    }

    _cachedItems = rawList.map(ScheduledItem.fromJson).toList();
    return List.unmodifiable(_cachedItems!);
  }

  Future<List<ScheduledItem>> getItemsForDate(String date) async {
    final all = await getAllItems();
    return all.where((item) => item.date == date).toList();
  }

  Future<DayPlan> getDayPlan(String date) async {
    final items = await getItemsForDate(date);
    return DayPlan(date: date, items: items);
  }

  Future<Map<String, DayPlan>> getPlansForMonth(int year, int month) async {
    final all = await getAllItems();
    final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';
    
    final map = <String, List<ScheduledItem>>{};
    for (final item in all) {
      if (item.date.startsWith(monthPrefix)) {
        map.putIfAbsent(item.date, () => []).add(item);
      }
    }

    return map.map((date, items) => MapEntry(date, DayPlan(date: date, items: items)));
  }

  Future<void> addItem(ScheduledItem item) async {
    final list = (await getAllItems()).toList();
    list.add(item);
    _cachedItems = list;
    await storage.writeList(_fileName, list.map((i) => i.toJson()).toList());
  }

  Future<void> updateItem(ScheduledItem item) async {
    final list = (await getAllItems()).toList();
    final index = list.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      list[index] = item;
      _cachedItems = list;
      await storage.writeList(_fileName, list.map((i) => i.toJson()).toList());
    }
  }

  Future<void> deleteItem(String id) async {
    final list = (await getAllItems()).toList();
    list.removeWhere((i) => i.id == id);
    _cachedItems = list;
    await storage.writeList(_fileName, list.map((i) => i.toJson()).toList());
  }

  Future<void> toggleCompletion(String id, bool completed) async {
    final list = (await getAllItems()).toList();
    final index = list.indexWhere((i) => i.id == id);
    if (index >= 0) {
      list[index] = list[index].copyWith(
        isCompleted: completed,
        completedAt: completed ? DateTime.now() : null,
      );
      _cachedItems = list;
      await storage.writeList(_fileName, list.map((i) => i.toJson()).toList());
    }
  }

  /// Marks a workout completed for today.
  /// If today does not have this workout scheduled, automatically creates and marks it completed.
  Future<void> markWorkoutCompletedForToday(String workoutId, String workoutTitle) async {
    final todayStr = formatDate(DateTime.now());
    final list = (await getAllItems()).toList();
    final index = list.indexWhere(
      (i) => i.date == todayStr && i.targetId == workoutId && i.type == ScheduledItemType.workout,
    );

    if (index >= 0) {
      list[index] = list[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
    } else {
      list.add(
        ScheduledItem(
          id: 'sched-${DateTime.now().millisecondsSinceEpoch}',
          date: todayStr,
          type: ScheduledItemType.workout,
          targetId: workoutId,
          title: workoutTitle,
          subtitle: 'Completed workout session',
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      );
    }
    _cachedItems = list;
    await storage.writeList(_fileName, list.map((i) => i.toJson()).toList());
  }

  List<ScheduledItem> _createDefaultSchedule() {
    final todayStr = formatDate(DateTime.now());
    return [
      ScheduledItem(
        id: 'init-sched-1',
        date: todayStr,
        type: ScheduledItemType.workout,
        targetId: 'wk-viking-starter',
        title: 'Viking Foundation Circuit',
        subtitle: '5 steps • 3.5 mins',
        isCompleted: false,
      ),
      ScheduledItem(
        id: 'init-sched-2',
        date: todayStr,
        type: ScheduledItemType.meal,
        targetId: 'meal-breakfast',
        title: 'High Protein Viking Breakfast',
        subtitle: 'Oatmeal, 4 eggs, berries (WIP)',
        isCompleted: false,
      ),
    ];
  }
}
