import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/services/preferences_service.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/biometric_gate.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/firebase/messaging_service.dart';
import 'core/firebase/repositories/user_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/locale_provider.dart';
import 'features/settings/providers/theme_provider.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the OS launch screen up past the first Flutter frame so the splash
  // screen can decode its video before anything is shown — avoids the brief
  // static-gradient flash. SplashScreen calls FlutterNativeSplash.remove()
  // once the video is ready (with a safety timeout).
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load first-launch flags (onboarding seen / profile complete) for routing.
  await PreferencesService.init();

  // Initializes Firebase if configured; otherwise the app runs in mock mode.
  // Safe to always call — it no-ops gracefully when google-services.json /
  // firebase_options.dart aren't set up yet. Crashlytics handlers wire inside.
  await FirebaseBootstrap.init();

  // Local notifications: timezone DB, Android channels, permission request.
  // Free / on-device; safe no-op if permission is denied.
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: DermIQApp()));
}

class DermIQApp extends ConsumerStatefulWidget {
  const DermIQApp({super.key});

  @override
  ConsumerState<DermIQApp> createState() => _DermIQAppState();
}

class _DermIQAppState extends ConsumerState<DermIQApp> {
  @override
  void initState() {
    super.initState();
    // Display FCM messages that arrive while the app is foregrounded (via local
    // notifications). Once-only; no-op when Firebase isn't configured.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagingServiceProvider)?.initForeground();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Instantiate the auth service so its Firebase authStateChanges listener
    // starts mirroring sign-in state into authStateProvider.
    ref.watch(authProvider);

    // When a user signs in, register for push and persist their FCM token.
    ref.listen<AppUser?>(authStateProvider, (prev, next) {
      if (next != null && prev?.id != next.id) {
        _registerPush(next.id);
      }
    });

    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeAsync = ref.watch(themeProvider);
    final themeMode = themeAsync.valueOrNull?.flutterMode ?? ThemeMode.light;

    // Drive AppTypography's text-colour getters so bare `AppTypography.x`
    // usages (e.g. app-bar titles) are readable in dark mode. Set before the
    // tree builds this frame.
    AppTypography.isDark = themeMode == ThemeMode.dark;

    return MaterialApp.router(
      title: 'DermIQ',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Switch themes instantly — the default ~200ms cross-fade lerps every
      // colour across the whole tree each frame and felt laggy.
      themeAnimationDuration: Duration.zero,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Gate the whole app behind the biometric lock when the user enabled it.
      builder: (context, child) =>
          BiometricGate(child: child ?? const SizedBox.shrink()),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _registerPush(String uid) async {
    final messaging = ref.read(messagingServiceProvider);
    final users = ref.read(userRepositoryProvider);
    if (messaging == null || users == null) return;

    final granted = await messaging.requestPermission();
    if (!granted) return;

    final token = await messaging.getToken();
    if (token != null) await users.saveFcmToken(uid, token);

    // Keep the stored token fresh when it rotates.
    messaging.onTokenRefresh.listen((t) => users.saveFcmToken(uid, t));
  }
}
