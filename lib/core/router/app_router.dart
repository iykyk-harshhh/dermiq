import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_routes.dart';
import 'route_error_screen.dart';
import '../firebase/analytics_service.dart';
import '../services/preferences_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';

// Auth
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

// Onboarding
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

// Quiz — Skin
import '../../features/profile_quiz/presentation/screens/skin_type_screen.dart';
import '../../features/profile_quiz/presentation/screens/skin_concerns_screen.dart';
import '../../features/profile_quiz/presentation/screens/skin_allergies_screen.dart';
import '../../features/profile_quiz/presentation/screens/sun_exposure_screen.dart';
import '../../features/profile_quiz/presentation/screens/skin_profile_complete_screen.dart';

// Quiz — Hair
import '../../features/profile_quiz/presentation/screens/hair_type_screen.dart';
import '../../features/profile_quiz/presentation/screens/scalp_type_screen.dart';
import '../../features/profile_quiz/presentation/screens/hair_concerns_screen.dart';
import '../../features/profile_quiz/presentation/screens/hair_treatments_screen.dart';
import '../../features/profile_quiz/presentation/screens/hair_profile_complete_screen.dart';

// Shell
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/notifications_screen.dart';

// Scan
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/scanner/presentation/screens/smart_scanner_screen.dart';
import '../../features/scan/presentation/screens/manual_search_screen.dart';
import '../../features/scan/presentation/screens/search_results_screen.dart';
import '../../features/scan/presentation/screens/product_analysis_screen.dart';

// Analysis
import '../../features/analysis/presentation/screens/analysis_results_screen.dart';

// Shelf (personal tracker)
import '../../features/shelf/presentation/screens/shelf_screen.dart';
import '../../features/shelf/presentation/screens/product_detail_screen.dart';
import '../../features/shelf/presentation/screens/add_product_screen.dart';

// Shop (e-commerce)
import '../../features/shop/data/shop_models.dart';
import '../../features/shop/presentation/screens/shop_screen.dart';
import '../../features/shop/presentation/screens/shop_product_detail_screen.dart';
import '../../features/shop/presentation/screens/cart_screen.dart';
import '../../features/shop/presentation/screens/checkout_screen.dart';
import '../../features/shop/presentation/screens/order_success_screen.dart';
import '../../features/shop/presentation/screens/order_tracking_screen.dart';
import '../../features/shop/presentation/screens/my_orders_screen.dart';

// Routine
import '../../features/routine/presentation/screens/routine_screen.dart';
import '../../features/routine/presentation/screens/routine_detail_screen.dart';
import '../../features/routine/presentation/screens/routine_builder_screen.dart';
import '../../features/routine/presentation/screens/routine_analysis_screen.dart';
import '../../features/routine/presentation/screens/routine_history_screen.dart';

// Calendar
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/calendar/presentation/screens/daily_routine_screen.dart';
import '../../features/calendar/presentation/screens/monthly_progress_screen.dart';
import '../../features/calendar/presentation/screens/streak_screen.dart';
import '../../features/calendar/presentation/screens/reminder_screen.dart';

// Specialist
import '../../features/specialist/data/specialist_models.dart';
import '../../features/specialist/presentation/screens/specialist_listing_screen.dart';
import '../../features/specialist/presentation/screens/specialist_detail_screen.dart';
import '../../features/specialist/presentation/screens/appointment_booking_screen.dart';
import '../../features/specialist/presentation/screens/appointment_confirmation_screen.dart';
import '../../features/specialist/presentation/screens/appointment_detail_screen.dart';
import '../../features/specialist/presentation/screens/my_appointments_screen.dart';
import '../../features/specialist/presentation/screens/saved_specialists_screen.dart';

// Profile
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_skin_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_hair_profile_screen.dart';
import '../../features/profile/presentation/screens/user_preferences_screen.dart';
import '../../features/profile/presentation/screens/gifts_screen.dart';

// Settings
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/theme_settings_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_settings_screen.dart';
import '../../features/settings/presentation/screens/help_support_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';

// AI features
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/ingredients/presentation/screens/ingredient_analyzer_screen.dart';

// Progress
import '../../features/progress/presentation/screens/progress_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Pure startup/redirect rule, extracted so it can be unit-tested without
/// pumping the whole app. Encodes the three flows:
///
///  • First launch  → Onboarding (once) → Login → Home
///  • Returning user (authed)        → Home
///  • Logged-out, onboarding seen    → Login → Home
String? resolveStartupRedirect({
  required bool loggedIn,
  required bool onboardingSeen,
  required String location,
}) {
  // Splash always renders; its CTA navigates to /onboarding and we reroute here.
  if (AppRoutes.isSplash(location)) return null;

  final isAuthScreen = AppRoutes.isPreAuth(location);

  if (!loggedIn) {
    if (location == AppRoutes.onboarding) {
      return onboardingSeen ? AppRoutes.login : null; // show onboarding once
    }
    if (isAuthScreen) return null; // welcome / login / register / forgot
    // Any protected screen → the correct signed-out entry point.
    return onboardingSeen ? AppRoutes.login : AppRoutes.onboarding;
  }

  // Signed in:
  if (isAuthScreen) return AppRoutes.home;
  return null;
}

/// The app router. Provides:
///  • Named, constant-driven routes (see [AppRoutes] / [RouteNames]).
///  • An authentication guard via [GoRouter.redirect] that re-runs whenever
///    auth state changes (wired through [refreshListenable]).
///  • Deep-link support — every screen is reachable by its URL, with a
///    typed 404 ([RouteErrorScreen]) for anything unknown.
final routerProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod auth state → a Listenable so GoRouter re-evaluates its
  // redirect (the guard) the moment the user signs in or out.
  final authListenable = ValueNotifier<int>(0);
  ref.onDispose(authListenable.dispose);
  ref.listen<MockUser?>(authStateProvider, (_, _) => authListenable.value++);
  ref.listen<bool>(onboardingSeenProvider, (_, _) => authListenable.value++);

  String? guard(BuildContext context, GoRouterState state) {
    return resolveStartupRedirect(
      loggedIn: ref.read(authStateProvider) != null,
      onboardingSeen: ref.read(onboardingSeenProvider),
      location: state.matchedLocation,
    );
  }

  // Automatic screen tracking when Analytics is available (no-op otherwise).
  final analyticsObserver = ref.read(analyticsServiceProvider).observer;

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    redirect: guard,
    observers: [?analyticsObserver],
    errorBuilder: (context, state) =>
        RouteErrorScreen(location: state.uri.toString()),
    routes: [
      // ── Auth flow ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash, name: RouteNames.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding, name: RouteNames.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login, name: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register, name: RouteNames.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword, name: RouteNames.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup, name: RouteNames.profileSetup,
        builder: (_, _) => const ProfileSetupScreen(),
      ),

      // ── Skin quiz ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.quizSkinType, name: RouteNames.quizSkinType,
        builder: (_, _) => const SkinTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizSkinConcerns, name: RouteNames.quizSkinConcerns,
        builder: (_, _) => const SkinConcernsScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizSkinAllergies, name: RouteNames.quizSkinAllergies,
        builder: (_, _) => const SkinAllergiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizSunExposure, name: RouteNames.quizSunExposure,
        builder: (_, _) => const SunExposureScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizSkinComplete, name: RouteNames.quizSkinComplete,
        builder: (_, _) => const SkinProfileCompleteScreen(),
      ),

      // ── Hair quiz ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.quizHairType, name: RouteNames.quizHairType,
        builder: (_, _) => const HairTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizScalpType, name: RouteNames.quizScalpType,
        builder: (_, _) => const ScalpTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizHairConcerns, name: RouteNames.quizHairConcerns,
        builder: (_, _) => const HairConcernsScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizHairTreatments, name: RouteNames.quizHairTreatments,
        builder: (_, _) => const HairTreatmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizHairComplete, name: RouteNames.quizHairComplete,
        builder: (_, _) => const HairProfileCompleteScreen(),
      ),

      // ── Main shell — bottom nav ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShellWrapper(shell: shell),
        branches: [
          // 0 — Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home, name: RouteNames.home,
              builder: (_, _) => const HomeScreen(),
            ),
          ]),
          // 1 — Routine
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.routine, name: RouteNames.routine,
              builder: (_, _) => const RoutineScreen(),
            ),
          ]),
          // 2 — Analyze (scan)
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.analyze, name: RouteNames.analyze,
              builder: (_, _) => const ScanScreen(),
            ),
          ]),
          // 3 — Shop (e-commerce). Path is '/shelf' (back-compat); the personal
          // shelf tracker is ShelfScreen at '/my-shelf'.
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.shop, name: RouteNames.shop,
              builder: (_, _) => const ShopScreen(),
            ),
          ]),
          // 4 — Profile
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile, name: RouteNames.profile,
              builder: (_, _) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // ── Notifications ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications, name: RouteNames.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),

      // ── Scan flow ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.scan, name: RouteNames.scan,
        builder: (_, _) => const ScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanIngredient, name: RouteNames.scanIngredient,
        builder: (_, _) => const SmartScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanManual, name: RouteNames.scanManual,
        builder: (_, _) => const ManualSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanResults, name: RouteNames.scanResults,
        builder: (_, _) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanAnalysisPattern, name: RouteNames.scanAnalysis,
        builder: (_, state) =>
            ProductAnalysisScreen(productId: state.pathParameters['id']!),
      ),

      // ── Analysis ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.analysis, name: RouteNames.analysis,
        builder: (_, _) => const AnalysisResultsScreen(),
      ),

      // ── Shelf detail / add ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.productDetailPattern, name: RouteNames.productDetail,
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.shelfAdd, name: RouteNames.shelfAdd,
        builder: (_, _) => const AddProductScreen(),
      ),

      // ── Routine sub-screens ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.routineAm, name: RouteNames.routineAm,
        builder: (_, _) => const RoutineDetailScreen(isAm: true),
      ),
      GoRoute(
        path: AppRoutes.routinePm, name: RouteNames.routinePm,
        builder: (_, _) => const RoutineDetailScreen(isAm: false),
      ),
      GoRoute(
        path: AppRoutes.routineBuilder, name: RouteNames.routineBuilder,
        builder: (_, _) => const RoutineBuilderScreen(),
      ),
      GoRoute(
        path: AppRoutes.routineAnalysis, name: RouteNames.routineAnalysis,
        builder: (_, _) => const RoutineAnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.routineHistory, name: RouteNames.routineHistory,
        builder: (_, _) => const RoutineHistoryScreen(),
      ),

      // ── Calendar ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.calendar, name: RouteNames.calendar,
        builder: (_, _) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendarDaily, name: RouteNames.calendarDaily,
        builder: (_, _) => const DailyRoutineScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendarMonthly, name: RouteNames.calendarMonthly,
        builder: (_, _) => const MonthlyProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendarStreak, name: RouteNames.calendarStreak,
        builder: (_, _) => const StreakScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendarReminders, name: RouteNames.calendarReminders,
        builder: (_, _) => const ReminderScreen(),
      ),

      // ── Specialist ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.specialist, name: RouteNames.specialist,
        builder: (_, state) => SpecialistListingScreen(
          initialType: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.appointments, name: RouteNames.appointments,
        builder: (_, _) => const MyAppointmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.savedSpecialists, name: RouteNames.savedSpecialists,
        builder: (_, _) => const SavedSpecialistsScreen(),
      ),
      GoRoute(
        path: AppRoutes.appointmentDetailPattern, name: RouteNames.appointmentDetail,
        builder: (_, state) {
          final appt = state.extra is Appointment
              ? state.extra as Appointment
              : myAppointmentsMock.firstWhere(
                  (a) => a.id == state.pathParameters['id'],
                  orElse: () => myAppointmentsMock.first,
                );
          return AppointmentDetailScreen(appointment: appt);
        },
      ),
      GoRoute(
        path: AppRoutes.specialistDetailPattern, name: RouteNames.specialistDetail,
        builder: (_, state) =>
            SpecialistDetailScreen(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'book', name: RouteNames.specialistBook,
            builder: (_, state) =>
                AppointmentBookingScreen(specialistId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'confirmation', name: RouteNames.specialistConfirm,
            builder: (_, state) => AppointmentConfirmationScreen(
              specialistId: state.pathParameters['id']!,
              draft: state.extra is BookingDraft ? state.extra as BookingDraft : null,
            ),
          ),
        ],
      ),

      // ── My Shelf (personal tracker) ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.myShelf, name: RouteNames.myShelf,
        builder: (_, _) => const ShelfScreen(),
      ),

      // ── Shop (e-commerce) ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.shopProductDetailPattern, name: RouteNames.shopProductDetail,
        builder: (_, state) {
          final product = state.extra as ShopProduct;
          return ShopProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.cart, name: RouteNames.cart,
        builder: (_, _) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout, name: RouteNames.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess, name: RouteNames.orderSuccess,
        builder: (_, state) {
          final order = state.extra as Order;
          return OrderSuccessScreen(order: order);
        },
      ),
      GoRoute(
        path: AppRoutes.orderTrackingPattern, name: RouteNames.orderTracking,
        builder: (_, state) {
          final order = state.extra as Order;
          return OrderTrackingScreen(order: order);
        },
      ),
      GoRoute(
        path: AppRoutes.orders, name: RouteNames.orders,
        builder: (_, _) => const MyOrdersScreen(),
      ),

      // ── Profile sub-screens ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profileEdit, name: RouteNames.profileEdit,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileEditSkin, name: RouteNames.profileEditSkin,
        builder: (_, _) => const EditSkinProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileEditHair, name: RouteNames.profileEditHair,
        builder: (_, _) => const EditHairProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profilePreferences, name: RouteNames.profilePreferences,
        builder: (_, _) => const UserPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileGifts, name: RouteNames.profileGifts,
        builder: (_, _) => const GiftsScreen(),
      ),

      // ── Settings ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings, name: RouteNames.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme, name: RouteNames.settingsTheme,
        builder: (_, _) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsNotifications, name: RouteNames.settingsNotifications,
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy, name: RouteNames.settingsPrivacy,
        builder: (_, _) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsHelp, name: RouteNames.settingsHelp,
        builder: (_, _) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAbout, name: RouteNames.settingsAbout,
        builder: (_, _) => const AboutScreen(),
      ),

      // ── AI features ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.chat, name: RouteNames.chat,
        builder: (_, _) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.ingredients, name: RouteNames.ingredients,
        builder: (_, _) => const IngredientAnalyzerScreen(),
      ),

      // ── Progress ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.progress, name: RouteNames.progress,
        builder: (_, _) => const ProgressScreen(),
      ),
    ],
  );
});
