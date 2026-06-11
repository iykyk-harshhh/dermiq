import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dermiq/core/router/app_router.dart';
import 'package:dermiq/core/router/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('parameterised path builders', () {
      expect(AppRoutes.specialistDetail('s1'), '/specialist/s1');
      expect(AppRoutes.specialistBook('s1'), '/specialist/s1/book');
      expect(AppRoutes.specialistConfirm('s1'), '/specialist/s1/confirmation');
      expect(AppRoutes.productDetail('p9'), '/product/p9');
      expect(AppRoutes.scanAnalysis('p9'), '/scan/analysis/p9');
    });

    test('classification helpers', () {
      expect(AppRoutes.isSplash(AppRoutes.splash), isTrue);
      expect(AppRoutes.isSplash(AppRoutes.home), isFalse);
      expect(AppRoutes.isPreAuth(AppRoutes.welcome), isTrue);
      expect(AppRoutes.isPreAuth(AppRoutes.login), isTrue);
      expect(AppRoutes.isPreAuth(AppRoutes.home), isFalse);
    });
  });

  group('resolveStartupRedirect (auth + onboarding guard)', () {
    String? r({
      required bool loggedIn,
      required bool seen,
      required String at,
    }) =>
        resolveStartupRedirect(
          loggedIn: loggedIn, onboardingSeen: seen,
          location: at,
        );

    test('splash is always allowed', () {
      expect(r(loggedIn: false, seen: false, at: AppRoutes.splash), isNull);
      expect(r(loggedIn: true, seen: true, at: AppRoutes.splash), isNull);
    });

    test('first launch shows onboarding, gates the app to it', () {
      expect(r(loggedIn: false, seen: false, at: AppRoutes.onboarding), isNull);
      expect(r(loggedIn: false, seen: false, at: AppRoutes.home),
          AppRoutes.onboarding);
    });

    test('once onboarding is seen, signed-out users go to login', () {
      expect(r(loggedIn: false, seen: true, at: AppRoutes.onboarding),
          AppRoutes.login);
      expect(r(loggedIn: false, seen: true, at: AppRoutes.home),
          AppRoutes.login);
      expect(r(loggedIn: false, seen: true, at: AppRoutes.login), isNull);
    });

    test('signed-in user on auth screen goes straight to home', () {
      expect(r(loggedIn: true, seen: true, at: AppRoutes.login), AppRoutes.home);
      expect(r(loggedIn: true, seen: true, at: AppRoutes.register),
          AppRoutes.home);
    });

    test('returning user goes straight to the app', () {
      expect(r(loggedIn: true, seen: true, at: AppRoutes.home), isNull);
      expect(r(loggedIn: true, seen: true, at: AppRoutes.shelf), isNull);
    });
  });

  test('routerProvider builds a GoRouter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    expect(router, isA<GoRouter>());
  });
}
