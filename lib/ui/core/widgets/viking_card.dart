import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VikingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Border? border;
  final bool isSelected;

  const VikingCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.border,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        Border.all(
          color: isSelected ? AppColors.emerald : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        );

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: effectiveBorder,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.emerald.withValues(alpha: 0.1),
        highlightColor: AppColors.surfaceElevated.withValues(alpha: 0.2),
        child: cardContent,
      ),
    );
  }
}
