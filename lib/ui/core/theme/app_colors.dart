import 'package:flutter/material.dart';

/// Design tokens for Viking Workout & Nutrition App.
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0C1017);
  static const Color surface = Color(0xFF151C26);
  static const Color surfaceElevated = Color(0xFF1E2836);
  static const Color surfaceHighlight = Color(0xFF293648);
  static const Color border = Color(0xFF243040);

  // Emerald & Green Accents (Success & Progress)
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldGaze = Color(0x2610B981);

  // Athletic Highlights
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldGaze = Color(0x26F59E0B);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanGaze = Color(0x2606B6D4);
  static const Color crimson = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradient presets
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2330), Color(0xFF131922)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient workoutHudGradient = LinearGradient(
    colors: [Color(0xFF0B1017), Color(0xFF111823)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
