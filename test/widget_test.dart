import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:viking/data/repositories/exercise_repository.dart';
import 'package:viking/data/repositories/plan_repository.dart';
import 'package:viking/data/repositories/workout_repository.dart';
import 'package:viking/data/services/storage_service.dart';
import 'package:viking/main.dart';
import 'package:viking/ui/features/home/view_models/home_view_model.dart';
import 'package:viking/ui/features/plan/view_models/plan_view_model.dart';
import 'package:viking/ui/features/workouts/view_models/workouts_view_model.dart';

void main() {
  testWidgets('VikingApp boots and displays Navigation and Home View', (WidgetTester tester) async {
    final tempDir = Directory.systemTemp.createTempSync('viking_widget_test_');
    final storage = StorageService(overrideDir: tempDir);

    final exRepo = ExerciseRepository(storage: storage);
    final wkRepo = WorkoutRepository(storage: storage);
    final planRepo = PlanRepository(storage: storage);

    final homeVm = HomeViewModel(planRepository: planRepo, workoutRepository: wkRepo);
    final wkVm = WorkoutsViewModel(workoutRepository: wkRepo, exerciseRepository: exRepo);
    final planVm = PlanViewModel(planRepository: planRepo, workoutRepository: wkRepo);

    await tester.runAsync(() async {
      await homeVm.loadToday();
      await wkVm.loadData();
      await planVm.loadMonth();
    });

    await tester.pumpWidget(
      VikingApp(
        exerciseRepository: exRepo,
        workoutRepository: wkRepo,
        planRepository: planRepo,
        homeViewModel: homeVm,
        workoutsViewModel: wkVm,
        planViewModel: planVm,
      ),
    );

    await tester.pump();

    // Verify Brand title or Home Dashboard title appears
    expect(find.text("Today's Battle Plan"), findsOneWidget);
    expect(find.text('Active Workouts Today'), findsOneWidget);

    tempDir.deleteSync(recursive: true);
  });
}
