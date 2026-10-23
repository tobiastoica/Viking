import 'package:flutter/material.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'data/services/storage_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/core/widgets/adaptive_scaffold.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/home/views/home_view.dart';
import 'ui/features/nutrition/views/nutrition_view.dart';
import 'ui/features/plan/view_models/plan_view_model.dart';
import 'ui/features/plan/views/plan_view.dart';
import 'ui/features/workouts/view_models/workouts_view_model.dart';
import 'ui/features/workouts/views/workouts_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final exerciseRepository = ExerciseRepository(storage: storageService);
  final workoutRepository = WorkoutRepository(storage: storageService);
  final planRepository = PlanRepository(storage: storageService);

  final homeViewModel = HomeViewModel(
    planRepository: planRepository,
    workoutRepository: workoutRepository,
  );

  final workoutsViewModel = WorkoutsViewModel(
    workoutRepository: workoutRepository,
    exerciseRepository: exerciseRepository,
  );

  final planViewModel = PlanViewModel(
    planRepository: planRepository,
    workoutRepository: workoutRepository,
  );

  // Initial asynchronous load
  await Future.wait([
    homeViewModel.loadToday(),
    workoutsViewModel.loadData(),
    planViewModel.loadMonth(),
  ]);

  runApp(
    VikingApp(
      exerciseRepository: exerciseRepository,
      workoutRepository: workoutRepository,
      planRepository: planRepository,
      homeViewModel: homeViewModel,
      workoutsViewModel: workoutsViewModel,
      planViewModel: planViewModel,
    ),
  );
}

class VikingApp extends StatelessWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutRepository workoutRepository;
  final PlanRepository planRepository;
  final HomeViewModel homeViewModel;
  final WorkoutsViewModel workoutsViewModel;
  final PlanViewModel planViewModel;

  const VikingApp({
    super.key,
    required this.exerciseRepository,
    required this.workoutRepository,
    required this.planRepository,
    required this.homeViewModel,
    required this.workoutsViewModel,
    required this.planViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainShell(
        exerciseRepository: exerciseRepository,
        workoutRepository: workoutRepository,
        planRepository: planRepository,
        homeViewModel: homeViewModel,
        workoutsViewModel: workoutsViewModel,
        planViewModel: planViewModel,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutRepository workoutRepository;
  final PlanRepository planRepository;
  final HomeViewModel homeViewModel;
  final WorkoutsViewModel workoutsViewModel;
  final PlanViewModel planViewModel;

  const MainShell({
    super.key,
    required this.exerciseRepository,
    required this.workoutRepository,
    required this.planRepository,
    required this.homeViewModel,
    required this.workoutsViewModel,
    required this.planViewModel,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh view data when navigating
    if (index == 0) {
      widget.homeViewModel.loadToday();
    } else if (index == 2) {
      widget.workoutsViewModel.loadData();
    } else if (index == 3) {
      widget.planViewModel.loadMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeView(
        viewModel: widget.homeViewModel,
        planRepository: widget.planRepository,
        onNavigateToWorkouts: () => _onNavigate(2),
        onNavigateToPlan: () => _onNavigate(3),
      ),
      const NutritionView(),
      WorkoutsView(
        viewModel: widget.workoutsViewModel,
        planRepository: widget.planRepository,
      ),
      PlanView(
        viewModel: widget.planViewModel,
        workoutRepository: widget.workoutRepository,
        planRepository: widget.planRepository,
      ),
    ];

    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigate,
      pages: pages,
    );
  }
}
