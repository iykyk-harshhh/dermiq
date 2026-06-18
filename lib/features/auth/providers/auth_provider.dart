import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/analytics_service.dart';
import '../../../core/firebase/crashlytics_service.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/repositories/user_repository.dart';
import '../../../core/services/preferences_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AUTH PROVIDER
//
//  `authStateProvider`  — source of truth: the signed-in user, or null. Kept in
//                         sync with Firebase Auth's authStateChanges stream.
//  `authProvider`       — the AuthService (sign in / up / out actions). Resolves
//                         to a real Firebase implementation when configured, and
//                         a mock implementation otherwise (offline dev / no
//                         google-services.json yet) — same surface either way.
// ─────────────────────────────────────────────────────────────────────────────

final authStateProvider = StateProvider<AppUser?>((ref) => null);

final authProvider = Provider<AuthService>((ref) {
  if (FirebaseBootstrap.isAvailable) return FirebaseAuthService(ref);
  // Firebase unavailable: in debug use the offline mock for development, but in
  // a release build NEVER silently fall back to passwordless mock auth — that
  // would let anyone in if Firebase init failed. Surface a clear error instead.
  return kReleaseMode ? UnavailableAuthService(ref) : MockAuthService(ref);
});

/// The current user (or null). Convenience read-only selector.
final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authStateProvider));

/// Whether someone is signed in — used by the router's redirect guard.
final isAuthenticatedProvider =
    Provider<bool>((ref) => ref.watch(authStateProvider) != null);

/// App-level user model (decoupled from the Firebase `User` type so the UI
/// never imports firebase_auth). `MockUser` kept as an alias for back-compat.
class AppUser {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isAnonymous;

  const AppUser({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isAnonymous = false,
  });

  factory AppUser.fromFirebase(fb.User u) => AppUser(
        id: u.uid,
        displayName: u.displayName,
        email: u.email,
        photoUrl: u.photoURL,
        isAnonymous: u.isAnonymous,
      );
}

typedef MockUser = AppUser;

// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthService {
  AppUser? get currentUser;

  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password,
      {String? displayName, String? gender});
  Future<void> signInWithGoogle();
  Future<void> signInAsGuest();

  /// Sends a password-reset email via Firebase. The user completes the reset
  /// through the link Firebase emails them.
  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  /// Permanently deletes the account: Firestore data + Firebase user + local
  /// cache. Leaves the user signed out.
  Future<void> deleteAccount();
}

// ── Firebase implementation ──────────────────────────────────────────────────

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._ref) : _auth = fb.FirebaseAuth.instance {
    // Mirror Firebase auth state into authStateProvider so the router guard and
    // screens stay reactive without importing firebase_auth.
    final sub = _auth.authStateChanges().listen(_onAuthChanged);
    _ref.onDispose(sub.cancel);
  }

  final Ref _ref;
  final fb.FirebaseAuth _auth;

  @override
  AppUser? get currentUser => _ref.read(authStateProvider);

  Future<void> _onAuthChanged(fb.User? user) async {
    final appUser = user == null ? null : AppUser.fromFirebase(user);
    _ref.read(authStateProvider.notifier).state = appUser;

    await _ref.read(crashlyticsServiceProvider).setUserId(user?.uid ?? '');
    await _ref.read(analyticsServiceProvider).setUserId(user?.uid);

    if (user != null) {
      final repo = _ref.read(userRepositoryProvider);
      // Register the account on first auth (creates users/{uid}).
      await repo?.ensureCreated(
            uid: user.uid,
            name: user.displayName,
            email: user.email,
            photoUrl: user.photoURL,
          );
      // Record this login: username, email, and the login date/time. Runs on
      // every sign-in (and session restore) so the doc always reflects the
      // latest login.
      await repo?.updateFields(user.uid, {
        if (user.displayName != null) 'name': user.displayName,
        if (user.email != null) 'email': user.email,
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ref.read(analyticsServiceProvider).logLogin('password');
  }

  @override
  Future<void> signUpWithEmail(String email, String password,
      {String? displayName, String? gender}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (displayName != null) await cred.user?.updateDisplayName(displayName);
    await _ref.read(analyticsServiceProvider).logSignUp('password');
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user cancelled
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    await _ref.read(analyticsServiceProvider).logLogin('google');
  }

  @override
  Future<void> signInAsGuest() async {
    await _auth.signInAnonymously();
    await _ref.read(analyticsServiceProvider).logLogin('anonymous');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() async {
    // Google sign-out can throw/no-op (e.g. the user signed in with email) —
    // never let it block the Firebase sign-out, which is what flips authState
    // to null and drives the router back to /login.
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _ref.read(userRepositoryProvider)?.delete(user.uid);
      try {
        await user.delete();
      } catch (_) {
        // Deletion can require a recent login; sign out as a fallback.
        await _auth.signOut();
      }
    }
    await GoogleSignIn().signOut();
    await PreferencesService.clearAll();
    _ref.read(profileCompleteProvider.notifier).state = false;
    _ref.read(onboardingSeenProvider.notifier).state = false;
  }
}

// ── Mock implementation (offline / pre-Firebase-config) ──────────────────────

class MockAuthService implements AuthService {
  MockAuthService(this._ref);
  final Ref _ref;

  void _set(AppUser? u) => _ref.read(authStateProvider.notifier).state = u;

  @override
  AppUser? get currentUser => _ref.read(authStateProvider);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _set(AppUser(id: 'user_1', email: email, displayName: email.split('@').first));
  }

  @override
  Future<void> signUpWithEmail(String email, String password,
      {String? displayName, String? gender}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _set(AppUser(
        id: 'user_1',
        email: email,
        displayName: displayName ?? email.split('@').first));
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _set(const AppUser(
        id: 'user_google', displayName: 'Google User', email: 'user@gmail.com'));
  }

  @override
  Future<void> signInAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _set(const AppUser(id: 'guest', displayName: 'Guest', isAnonymous: true));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600)); // no-op in mock mode
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> deleteAccount() async {
    await PreferencesService.clearAll();
    _ref.read(profileCompleteProvider.notifier).state = false;
    _ref.read(onboardingSeenProvider.notifier).state = false;
    _set(null);
  }
}

// ── Unavailable (release build where Firebase failed to initialize) ───────────
//
// Guards against the silent auth-bypass: rather than logging anyone in via the
// mock, every action throws a clear error so the failure is visible instead of
// granting unauthenticated access.

class UnavailableAuthService implements AuthService {
  UnavailableAuthService(this._ref);
  final Ref _ref;

  Never _fail() => throw StateError(
      'Authentication is unavailable — please check your connection and '
      'restart the app.');

  @override
  AppUser? get currentUser => _ref.read(authStateProvider);

  @override
  Future<void> signInWithEmail(String email, String password) async => _fail();

  @override
  Future<void> signUpWithEmail(String email, String password,
          {String? displayName, String? gender}) async =>
      _fail();

  @override
  Future<void> signInWithGoogle() async => _fail();

  @override
  Future<void> signInAsGuest() async => _fail();

  @override
  Future<void> sendPasswordReset(String email) async => _fail();

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async => _fail();
}
