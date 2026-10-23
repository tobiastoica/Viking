import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/viking_card.dart';

class NutritionView extends StatelessWidget {
  const NutritionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E2211), Color(0xFF161C24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldGaze,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          'WORK IN PROGRESS',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Viking Nutrition Hub',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Precision fuel for high-performance warriors. Track macros, log meals, and optimize protein intake to fuel your workouts.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Upcoming Nutrition Modules:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            _buildFeaturePreview(
              icon: Icons.pie_chart_rounded,
              color: AppColors.emerald,
              title: 'Macronutrient Targets',
              description: 'Dynamic daily targets for Protein, Carbohydrates, and Healthy Fats calculated to match your workout demands.',
            ),
            const SizedBox(height: 12),
            _buildFeaturePreview(
              icon: Icons.qr_code_scanner_rounded,
              color: AppColors.cyan,
              title: 'Barcode & Food Logging',
              description: 'Quick local meal scanner and offline database for instant calorie and ingredient breakdown.',
            ),
            const SizedBox(height: 12),
            _buildFeaturePreview(
              icon: Icons.water_drop_rounded,
              color: AppColors.cyan,
              title: 'Hydration & Electrolytes',
              description: 'Real-time water intake tracking synchronized with your high-intensity workout sweat loss.',
            ),
            const SizedBox(height: 12),
            _buildFeaturePreview(
              icon: Icons.share_rounded,
              color: AppColors.gold,
              title: 'Meal Export & Import',
              description: 'Share custom high-protein meal preps and recipes with training partners offline via JSON.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePreview({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return VikingCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
