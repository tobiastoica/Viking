import 'package:flutter/services.dart';

/// Provides sensory feedback (haptics and system sound cues) during workout execution.
class FeedbackService {
  const FeedbackService();

  Future<void> click() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> stepStart() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> stepComplete() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> workoutFinished() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
