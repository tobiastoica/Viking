import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated circular progress ring representing day completion progress.
/// Turns solid emerald green with subtle glow when all objectives for the day are fulfilled.
class CircularDayProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isFulfilled;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  const CircularDayProgress({
    super.key,
    required this.progress,
    required this.isFulfilled,
    this.size = 36.0,
    this.strokeWidth = 3.0,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle or fulfilled glowing fill
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFulfilled
                  ? AppColors.emerald.withValues(alpha: 0.2)
                  : Colors.transparent,
              boxShadow: isFulfilled
                  ? [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
          // Custom painted arc
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressArcPainter(
              progress: progress.clamp(0.0, 1.0),
              isFulfilled: isFulfilled,
              strokeWidth: strokeWidth,
            ),
          ),
          ?centerChild,
        ],
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final bool isFulfilled;
  final double strokeWidth;

  _ProgressArcPainter({
    required this.progress,
    required this.isFulfilled,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track background
    final trackPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = isFulfilled ? AppColors.emerald : AppColors.emeraldLight
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isFulfilled != isFulfilled ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
