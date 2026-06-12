/// Centralised navigation constants for DermIQ.
///
/// Use these instead of hardcoded path strings:
///   context.go(AppRoutes.home);
///   context.goNamed(RouteNames.home);
///   context.push(AppRoutes.specialistDetail(id));
///
/// `AppRoutes` holds the canonical paths (and builders for parameterised
/// routes). `RouteNames` holds the matching GoRouter route names so screens
/// can navigate by name with type-safe params.
library;

abstract final class AppRoutes {
  AppRoutes._();

  // ── Auth flow ──────────────────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const profileSetup = '/profile-setup';

  // ── Skin quiz ──────────────────────────────────────────────────────────────
  static const quizSkinType = '/quiz/skin-type';
  static const quizSkinConcerns = '/quiz/skin-concerns';
  static const quizSkinAllergies = '/quiz/skin-allergies';
  static const quizSunExposure = '/quiz/sun-exposure';
  static const quizSkinComplete = '/quiz/skin-profile-complete';

  // ── Hair quiz ──────────────────────────────────────────────────────────────
  static const quizHairType = '/quiz/hair-type';
  static const quizScalpType = '/quiz/scalp-type';
  static const quizHairConcerns = '/quiz/hair-concerns';
  static const quizHairTreatments = '/quiz/hair-treatments';
  static const quizHairComplete = '/quiz/hair-profile-complete';

  // ── Bottom-nav shell branches ───────────────────────────────────────────────
  static const home = '/home';
  static const routine = '/routine';
  static const analyze = '/analyze';
  // The Shop (e-commerce) tab. Path kept as '/shelf' for back-compat with the
  // many existing links; the personal shelf tracker lives at [myShelf].
  static const shop = '/shelf';
  static const profile = '/profile';

  // ── Top-level ───────────────────────────────────────────────────────────────
  static const notifications = '/notifications';
  static const analysis = '/analysis';
  static const progress = '/progress';
  static const chat = '/chat';
  static const ingredients = '/ingredients';

  // ── Scan flow ───────────────────────────────────────────────────────────────
  static const scan = '/scan';
  static const scanIngredient = '/scan/ingredient';
  static const scanManual = '/scan/manual';
  static const scanResults = '/scan/results';
  static const scanAnalysisPattern = '/scan/analysis/:id';
  static String scanAnalysis(String id) => '/scan/analysis/$id';

  // ── Shelf ───────────────────────────────────────────────────────────────────
  static const shelfAdd = '/shelf/add';
  static const productDetailPattern = '/product/:id';
  static String productDetail(String id) => '/product/$id';

  // ── Routine sub-screens ─────────────────────────────────────────────────────
  static const routineAm = '/routine/am';
  static const routinePm = '/routine/pm';
  static const routineBuilder = '/routine/builder';
  static const routineAnalysis = '/routine/analysis';
  static const routineHistory = '/routine/history';

  // ── Calendar ────────────────────────────────────────────────────────────────
  static const calendar = '/calendar';
  static const calendarDaily = '/calendar/daily';
  static const calendarMonthly = '/calendar/monthly';
  static const calendarStreak = '/calendar/streak';
  static const calendarReminders = '/calendar/reminders';

  // ── Specialist ──────────────────────────────────────────────────────────────
  static const specialist = '/specialist';
  static const savedSpecialists = '/saved-specialists';
  static const appointments = '/appointments';
  static const appointmentDetailPattern = '/appointment/:id';
  static String appointmentDetail(String id) => '/appointment/$id';
  static const specialistDetailPattern = '/specialist/:id';
  static String specialistDetail(String id) => '/specialist/$id';
  static String specialistBook(String id) => '/specialist/$id/book';
  static String specialistConfirm(String id) => '/specialist/$id/confirmation';

  // ── Shop (e-commerce) ──────────────────────────────────────────────────────
  static const myShelf = '/my-shelf';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orderTrackingPattern = '/order-tracking/:id';
  static String orderTracking(String id) => '/order-tracking/$id';
  static const orders = '/orders';
  static const shopProductDetailPattern = '/shop/product/:id';
  static String shopProductDetail(String id) => '/shop/product/$id';

  // ── Profile sub-screens ─────────────────────────────────────────────────────
  static const profileEdit = '/profile/edit';
  static const profileEditSkin = '/profile/edit-skin';
  static const profileEditHair = '/profile/edit-hair';
  static const profilePreferences = '/profile/preferences';
  static const profileGifts = '/profile/gifts';

  // ── Settings ────────────────────────────────────────────────────────────────
  static const settings = '/settings';
  static const settingsTheme = '/settings/theme';
  static const settingsNotifications = '/settings/notifications';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsHelp = '/settings/help';
  static const settingsAbout = '/settings/about';

  // ── Route classification (used by the auth guard) ───────────────────────────

  /// Screens that belong to the signed-out flow. A logged-in user landing on
  /// one of these is redirected to [home]; a logged-out user is allowed.
  static const preAuth = <String>{
    onboarding,
    welcome,
    login,
    register,
    forgotPassword,
  };

  /// `/splash` is neutral — it always renders (and routes onward itself),
  /// regardless of auth state, so the branded intro is never skipped.
  static bool isSplash(String location) => location == splash;

  static bool isPreAuth(String location) => preAuth.contains(location);
}

/// GoRouter route names — keep in lockstep with [AppRoutes].
abstract final class RouteNames {
  RouteNames._();

  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const welcome = 'welcome';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const profileSetup = 'profileSetup';

  static const quizSkinType = 'quizSkinType';
  static const quizSkinConcerns = 'quizSkinConcerns';
  static const quizSkinAllergies = 'quizSkinAllergies';
  static const quizSunExposure = 'quizSunExposure';
  static const quizSkinComplete = 'quizSkinComplete';

  static const quizHairType = 'quizHairType';
  static const quizScalpType = 'quizScalpType';
  static const quizHairConcerns = 'quizHairConcerns';
  static const quizHairTreatments = 'quizHairTreatments';
  static const quizHairComplete = 'quizHairComplete';

  static const home = 'home';
  static const routine = 'routine';
  static const analyze = 'analyze';
  static const shop = 'shop';
  static const profile = 'profile';

  static const notifications = 'notifications';
  static const analysis = 'analysis';
  static const progress = 'progress';
  static const chat = 'chat';
  static const ingredients = 'ingredients';

  static const scan = 'scan';
  static const scanIngredient = 'scanIngredient';
  static const scanManual = 'scanManual';
  static const scanResults = 'scanResults';
  static const scanAnalysis = 'scanAnalysis';

  static const shelfAdd = 'shelfAdd';
  static const productDetail = 'productDetail';

  static const routineAm = 'routineAm';
  static const routinePm = 'routinePm';
  static const routineBuilder = 'routineBuilder';
  static const routineAnalysis = 'routineAnalysis';
  static const routineHistory = 'routineHistory';

  static const calendar = 'calendar';
  static const calendarDaily = 'calendarDaily';
  static const calendarMonthly = 'calendarMonthly';
  static const calendarStreak = 'calendarStreak';
  static const calendarReminders = 'calendarReminders';

  static const specialist = 'specialist';
  static const savedSpecialists = 'savedSpecialists';
  static const appointments = 'appointments';
  static const appointmentDetail = 'appointmentDetail';
  static const specialistDetail = 'specialistDetail';
  static const specialistBook = 'specialistBook';
  static const specialistConfirm = 'specialistConfirm';

  static const myShelf = 'myShelf';
  static const cart = 'cart';
  static const checkout = 'checkout';
  static const orderSuccess = 'orderSuccess';
  static const orderTracking = 'orderTracking';
  static const orders = 'orders';
  static const shopProductDetail = 'shopProductDetail';

  static const profileEdit = 'profileEdit';
  static const profileEditSkin = 'profileEditSkin';
  static const profileEditHair = 'profileEditHair';
  static const profilePreferences = 'profilePreferences';
  static const profileGifts = 'profileGifts';

  static const settings = 'settings';
  static const settingsTheme = 'settingsTheme';
  static const settingsNotifications = 'settingsNotifications';
  static const settingsPrivacy = 'settingsPrivacy';
  static const settingsHelp = 'settingsHelp';
  static const settingsAbout = 'settingsAbout';
}
