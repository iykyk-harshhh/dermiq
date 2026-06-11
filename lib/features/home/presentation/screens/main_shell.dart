import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

class MainShellWrapper extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShellWrapper({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _BottomNav(
        selectedIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

const _navItems = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'Routine'),
  _NavItem(Icons.camera_alt_outlined, Icons.camera_alt_rounded, 'Analyze'),
  _NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Shop'),
  _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.dColors;
    return Container(
      decoration: BoxDecoration(
        color: c.navBackground,
        boxShadow: c.bottomNavShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              return _NavTab(
                item: _navItems[i],
                isSelected: i == selectedIndex,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.gradientPrimary : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.32),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 22,
                  color: isSelected ? Colors.white : context.dColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : context.dColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
