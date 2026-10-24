# ⚡ Viking — Strength, Workout & Nutrition Tracker

[![Build & Release Viking APK](https://github.com/tobiastoica/Viking/actions/workflows/build_apk.yml/badge.svg)](https://github.com/tobiastoica/Viking/actions/workflows/build_apk.yml)

> **Viking** is a sleek, modular, 100% offline mobile workout and nutrition tracking application built with Flutter. Engineered with an athletic dark aesthetic, responsive navigation, drag-and-drop routine design, monthly calendar planning, and an immersive live workout execution HUD.

---

## 🛡️ Key Features

### 1. 🏋️ Workouts & Exercises Manager
- **Dual Tab Hub**: Switch seamlessly between **My Workouts** and **My Exercises**.
- **Exercise Library**:
  - Track duration in seconds, estimated calories burned, category (Chest, Legs, Core, Cardio, Back, etc.), and difficulty levels.
  - Open-closed data model: easily extensible for new metrics, equipment tags, and tempo cues.
  - Searchable by name, muscle category, or difficulty.
  - Full modal creation, editing, and deletion.
- **Interactive Workout Builder**:
  - Dedicated routine composition page.
  - Drag-and-drop step reordering using `ReorderableListView`.
  - **Add Exercise**: Search your exercise pool, select reps, and the app automatically computes total required time (`reps × exercise duration`).
  - **Add Break**: Quick duration presets (15s, 30s, 45s, 60s, 90s) for structured rest periods.
  - Dynamic total duration counter and exercise/break counters.

### 2. ⚡ Activate Workout Mode (Live HUD)
- **High-Performance Player**: Enter a focused, distraction-free athletic workout HUD.
- **User-Initiated Step Requirement**: No exercise or break countdown begins until you press **START STEP**.
- **Real-Time Controls**:
  - Circular countdown timer with dynamic stroke sweep and digital clock (`MM:SS`).
  - Pause & Resume.
  - **NEXT STEP**: Instantly jump to the next exercise or break.
  - **PREVIOUS STEP**: Step backward if needed.
  - **Up Next Preview**: Bottom card displays what exercise or rest period is immediately upcoming.
- **Sensory Cues**: Haptic feedback and alert sound chimes on step completion.
- **Victory Screen & Auto-Logging**: When all steps are finished, celebration stats appear and the workout is automatically marked completed in today's plan!

### 3. 📅 My Plan (Monthly Calendar & Progress Rings)
- **Month Calendar Grid**: View the current month with previous/next month navigation and a "Jump to Today" shortcut.
- **Green Progress Circles**: Each calendar day features an animated progress ring that reflects the proportion of completed objectives (workouts + meals).
- **Day Glow Completion**: When all objectives on a day are fulfilled, the day cell turns vibrant emerald green with an animated completion badge.
- **Intuitive Gestures**:
  - **Long Press / Hold on a day**: Opens a quick modal to add either a saved Workout routine or a Planned Meal.
  - **Tap on a day**: Opens the day detail sheet to inspect scheduled objectives, toggle completion, delete items, or activate workouts directly.

### 4. 🏠 Today's Dashboard (Home)
- Real-time overview of active workouts and planned meals for today.
- Central progress ring reflecting daily completion.
- Direct **ACTIVATE WORKOUT** one-tap launch.

### 5. 🥗 Nutrition Hub (Work in Progress)
- Dedicated hub outlining upcoming macronutrient targets (Protein, Carbs, Fats), barcode food logging, hydration tracking, and recipe templates.

### 6. 🔒 100% Offline & Private
- No cloud login or remote tracking required. All data is persisted locally via structured JSON files.
- Built-in JSON export and import capabilities for backup or sharing routines with friends offline.

---

## 🏛️ Architecture & Best Practices

The app strictly follows **Clean Architecture & MVVM** separation of concerns:

```text
lib/
├── data/
│   ├── models/            # JSON-serializable domain models with open-closed customProperties
│   │   ├── exercise_model.dart
│   │   ├── workout_step_model.dart
│   │   ├── workout_model.dart
│   │   └── plan_model.dart
│   ├── services/          # Low-level file I/O & sensory feedback
│   │   ├── storage_service.dart
│   │   └── feedback_service.dart
│   └── repositories/      # Single sources of truth with in-memory caching
│       ├── exercise_repository.dart
│       ├── workout_repository.dart
│       └── plan_repository.dart
├── ui/
│   ├── core/              # Design system tokens, dark athletic theme, adaptive scaffold
│   │   ├── theme/
│   │   └── widgets/
│   └── features/          # Feature slices (Views & ViewModels)
│       ├── home/
│       ├── workouts/
│       ├── plan/
│       ├── active_workout/
│       └── nutrition/
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.24+ recommended)
- [Android Studio](https://developer.android.com/studio) or Android SDK with command-line tools
- Java Development Kit (JDK 17 or higher)

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/tobiastoica/Viking.git
   cd Viking
   ```

2. Get package dependencies:
   ```bash
   flutter pub get
   ```

3. Run the automated test suite:
   ```bash
   flutter test
   ```

4. Launch the app on a connected device or emulator:
   ```bash
   flutter run
   ```

---

## 📦 Building the APK

### Automated GitHub Cloud Builds (CI/CD)
The repository includes a GitHub Actions workflow [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml).
On every push or pull request to `main`:
1. GitHub spins up a runner, verifies dependencies, runs `flutter analyze` and `flutter test`.
2. It compiles `app-release.apk` automatically in the cloud.
3. You can download the compiled APK anytime from the **Actions** tab on GitHub under **Artifacts** (`viking-app-release`).
4. Pushing a version tag (e.g. `git tag v1.0.0 && git push origin v1.0.0`) automatically publishes a GitHub Release with the APK attached.

### Local Build
To generate a standalone release APK locally on your machine:

```bash
flutter build apk --release
```

The compiled APK will be output at:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing

Run static analysis and unit/widget tests:
```bash
flutter analyze
flutter test
```
