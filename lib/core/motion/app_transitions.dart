import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_animations.dart';

/// Custom page transitions for GoRouter.
///
/// Usage in GoRoute:
///   pageBuilder: (context, state) => AppTransitions.fadeSlide(
///     key: state.pageKey,
///     child: const MyScreen(),
///   ),
class AppTransitions {
  /// Fade + subtle upward slide — used for most page pushes.
  static CustomTransitionPage<T> fadeSlide<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: AppAnimations.standard,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.enter,
        ));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      transitionDuration: AppAnimations.page,
      reverseTransitionDuration: AppAnimations.medium,
    );
  }

  /// Slide from right — used for detail screens / settings.
  static CustomTransitionPage<T> slideRight<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.enter,
        ));
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      transitionDuration: AppAnimations.page,
      reverseTransitionDuration: AppAnimations.medium,
    );
  }

  /// Scale + fade — used for modals / overlays.
  static CustomTransitionPage<T> scaleFade<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppAnimations.snap,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppAnimations.standard,
            ),
            child: child,
          ),
        );
      },
      transitionDuration: AppAnimations.medium,
    );
  }
}
