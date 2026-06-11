import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_routes.dart';

/// Shown when a deep link or navigation resolves to an unknown route.
/// Wired into GoRouter via `errorBuilder`.
class RouteErrorScreen extends StatelessWidget {
  final String? location;
  const RouteErrorScreen({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.explore_off_rounded,
                      color: AppColors.primary, size: 42),
                ),
                const SizedBox(height: 24),
                Text('Page not found', style: AppTypography.h3),
                const SizedBox(height: 10),
                Text(
                  location == null
                      ? "We couldn't find the screen you were looking for."
                      : "We couldn't find a screen for:\n$location",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(height: 1.5),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Back to Home',
                            style: AppTypography.button.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go(AppRoutes.home),
                  child: Text('Go back',
                      style: AppTypography.buttonSmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
