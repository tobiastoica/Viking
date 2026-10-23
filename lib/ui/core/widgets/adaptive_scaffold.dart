import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final List<Widget> pages;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.pages,
    this.floatingActionButton,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavItem> _navItems = const [
    _NavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _NavItem(
      label: 'Nutrition',
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant_rounded,
      badge: 'WIP',
    ),
    _NavItem(
      label: 'Workouts',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center_rounded,
    ),
    _NavItem(
      label: 'My Plan',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 720;

        if (isLargeScreen) {
          // Large screen layout: Leftside sidebar + Content
          return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: widget.floatingActionButton,
            body: Row(
              children: [
                _buildLeftSidebar(isLargeScreen: true),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                Expanded(
                  child: IndexedStack(
                    index: widget.currentIndex,
                    children: widget.pages,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile layout: Leftside navigation drawer with top bar toggle
          return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: widget.floatingActionButton,
            drawer: Drawer(
              backgroundColor: AppColors.background,
              child: SafeArea(
                child: _buildLeftSidebar(
                  isLargeScreen: false,
                  onItemTap: () {
                    Navigator.of(context).pop(); // Close drawer on selection
                  },
                ),
              ),
            ),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.emerald),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                tooltip: 'Open navigation',
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGaze,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: AppColors.emerald, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _navItems[widget.currentIndex].label,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            body: IndexedStack(
              index: widget.currentIndex,
              children: widget.pages,
            ),
          );
        }
      },
    );
  }

  Widget _buildLeftSidebar({required bool isLargeScreen, VoidCallback? onItemTap}) {
    return Container(
      width: isLargeScreen ? 240 : double.infinity,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, color: Colors.black, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIKING',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'STRENGTH & FUEL',
                        style: TextStyle(
                          color: AppColors.emeraldLight,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Nav Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = widget.currentIndex == index;

                return InkWell(
                  onTap: () {
                    widget.onNavigationChanged(index);
                    if (onItemTap != null) onItemTap();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.emeraldGaze : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.emerald.withValues(alpha: 0.4))
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected ? AppColors.emerald : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% Offline & Private',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String? badge;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badge,
  });
}
