import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

/// Top-level FCM background handler. Must be a top-level (or static) function
/// so the OS can invoke it in a separate isolate. Registered in
/// [FirebaseBootstrap.init]. Keep it lightweight — heavy work risks an ANR.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // A separate isolate: if you need Firebase here, call
  // `Firebase.initializeApp()` first. For now we just log.
  debugPrint('[FCM] background message: ${message.messageId}');
}

/// Push-notification service: permissions, token, foreground/opened streams,
/// topic subscriptions. Wrap-only — UI display of foreground messages can be
/// layered on with flutter_local_notifications later.
class MessagingService {
  MessagingService(this._fm);

  final FirebaseMessaging _fm;

  StreamSubscription<RemoteMessage>? _foregroundSub;

  /// Subscribe to foreground FCM messages and display them via
  /// [NotificationService] (FCM itself does NOT show a system notification while
  /// the app is in the foreground). Call after `NotificationService.instance.init()`.
  /// Idempotent — a second call replaces the existing subscription.
  void initForeground() {
    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(
      (message) {
        final n = message.notification;
        if (n == null) return;
        final title = n.title ?? 'DermIQ';
        final body = n.body ?? '';
        NotificationService.instance.showNow(
          id: message.messageId?.hashCode ??
              DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channel: NotificationChannels.general,
        );
      },
      onError: (Object e) => debugPrint('[FCM] onMessage error: $e'),
    );
  }

  /// Stop listening for foreground messages.
  void disposeForeground() {
    _foregroundSub?.cancel();
    _foregroundSub = null;
  }

  /// Ask the user for notification permission (iOS + Android 13+).
  Future<bool> requestPermission() async {
    final settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// The device's current FCM registration token (store it against the user).
  Future<String?> getToken() => _fm.getToken();

  /// Emits a new token whenever it rotates — persist it to the user document.
  Stream<String> get onTokenRefresh => _fm.onTokenRefresh;

  /// Messages received while the app is in the foreground.
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Fired when the user taps a notification that opened the app.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// The notification that cold-started the app, if any.
  Future<RemoteMessage?> initialMessage() => _fm.getInitialMessage();

  Future<void> subscribeToTopic(String topic) => _fm.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      _fm.unsubscribeFromTopic(topic);
}

/// Null when Firebase isn't configured, so callers degrade gracefully.
final messagingServiceProvider = Provider<MessagingService?>((ref) {
  try {
    return MessagingService(FirebaseMessaging.instance);
  } catch (_) {
    return null;
  }
});
