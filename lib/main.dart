import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/preferences_service.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/firebase/messaging_service.dart';
import 'core/firebase/repositories/user_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: DermIQApp()));
}

class DermIQApp extends ConsumerWidget {
  const DermIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Instantiate the auth service so its Firebase authStateChanges listener
    // starts mirroring sign-in state into authStateProvider.
    ref.watch(authProvider);

    // When a user signs in, register for push and persist their FCM token.
    ref.listen<AppUser?>(authStateProvider, (prev, next) {
      if (next != null && prev?.id != next.id) {
        _registerPush(ref, next.id);
      }
    });

    final router = ref.watch(routerProvider);
    final themeAsync = ref.watch(themeProvider);
    final themeMode = themeAsync.valueOrNull?.flutterMode ?? ThemeMode.light;

    return MaterialApp.router(
      title: 'DermIQ',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _registerPush(WidgetRef ref, String uid) async {
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
