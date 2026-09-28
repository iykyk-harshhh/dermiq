import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Channel identifiers. The reminder channel is used for scheduled routine
/// reminders; the general channel is used for FCM foreground pushes and reward
/// unlock celebrations.
class NotificationChannels {
  const NotificationChannels._();

  static const reminders = 'dermiq_reminders_channel';
  static const general = 'dermiq_default_channel';
}

/// Singleton wrapper around [FlutterLocalNotificationsPlugin] for FREE,
/// backend-less local notifications: immediate messages, scheduled routine
/// reminders (optionally weekly-repeating), and cancellation. Timezone-aware so
/// scheduled times fire at the correct local wall-clock time.
///
/// Everything is guarded so a denied permission or an unsupported platform
/// never crashes the app — calls simply become no-ops.
class NotificationService {
  NotificationService._();

  /// Shared instance. `main.dart` calls `NotificationService.instance.init()`.
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize the plugin, timezone database, Android channels, and request
  /// notification permission. Safe to call more than once.
  Future<void> init() async {
    if (_initialized) return;
    try {
      // ── Timezone ────────────────────────────────────────────────────────
      tzdata.initializeTimeZones();
      try {
        // Best-effort: fall back to the DateTime offset when the platform
        // name can't be resolved (keeps zonedSchedule working).
        final offset = DateTime.now().timeZoneOffset;
        final name = _guessTimeZone(offset);
        if (name != null) {
          tz.setLocalLocation(tz.getLocation(name));
        }
      } catch (e) {
        debugPrint('[Notif] timezone resolve failed: $e');
      }

      // ── Plugin init ─────────────────────────────────────────────────────
      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );
      await _plugin.initialize(initSettings);

      // ── Android channels ────────────────────────────────────────────────
      final androidImpl =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            NotificationChannels.reminders,
            'Routine Reminders',
            description: 'Reminders for your skincare routine and check-ins.',
            importance: Importance.high,
          ),
        );
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            NotificationChannels.general,
            'General',
            description: 'Rewards, updates, and other DermIQ notifications.',
            importance: Importance.high,
          ),
        );
      }

      _initialized = true;
      // Request permission after init; never throws to the caller.
      await requestPermission();
    } catch (e) {
      debugPrint('[Notif] init failed: $e');
    }
  }

  /// Request notification permission (Android 13+ POST_NOTIFICATIONS, iOS/macOS
  /// alert/badge/sound). Returns true when granted, false otherwise; never
  /// throws.
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl =
            _plugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      }
      if (Platform.isIOS) {
        final iosImpl =
            _plugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      if (Platform.isMacOS) {
        final macImpl =
            _plugin.resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();
        final granted = await macImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[Notif] requestPermission failed: $e');
    }
    return false;
  }

  /// Show an immediate notification (FCM foreground display, reward unlocks).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String channel = NotificationChannels.general,
  }) async {
    if (!_initialized) await init();
    try {
      await _plugin.show(
        id,
        title,
        body,
        _details(channel),
      );
    } catch (e) {
      debugPrint('[Notif] showNow failed: $e');
    }
  }

  /// Schedule a reminder at [time]. When [repeatDays] (weekday ints, Mon=1…Sun=7)
  /// is non-empty, one weekly-repeating notification is scheduled per day using
  /// `matchDateTimeComponents: dayOfWeekAndTime`; the notification id for each
  /// day is derived as `id * 10 + weekday` so they can be cancelled together.
  /// With no [repeatDays], a single one-shot notification is scheduled at the
  /// next occurrence of [time].
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    List<int> repeatDays = const [],
  }) async {
    if (!_initialized) await init();
    try {
      if (repeatDays.isEmpty) {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          _nextInstanceOf(time.hour, time.minute),
          _details(NotificationChannels.reminders),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        return;
      }
      for (final weekday in repeatDays) {
        await _plugin.zonedSchedule(
          _weekdayId(id, weekday),
          title,
          body,
          _nextInstanceOfWeekday(weekday, time.hour, time.minute),
          _details(NotificationChannels.reminders),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e) {
      debugPrint('[Notif] scheduleReminder failed: $e');
    }
  }

  /// Cancel a reminder scheduled with [scheduleReminder]. Cancels both the
  /// one-shot id and any per-weekday ids derived from it.
  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
      for (var weekday = 1; weekday <= 7; weekday++) {
        await _plugin.cancel(_weekdayId(id, weekday));
      }
    } catch (e) {
      debugPrint('[Notif] cancel failed: $e');
    }
  }

  /// Cancel every pending/scheduled notification.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[Notif] cancelAll failed: $e');
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  int _weekdayId(int id, int weekday) => id * 10 + weekday;

  NotificationDetails _details(String channel) {
    final isReminder = channel == NotificationChannels.reminders;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        isReminder ? 'Routine Reminders' : 'General',
        channelDescription: isReminder
            ? 'Reminders for your skincare routine and check-ins.'
            : 'Rewards, updates, and other DermIQ notifications.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
  }

  /// Next occurrence of [hour]:[minute] today or tomorrow, in local tz.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Next occurrence of [weekday] (Mon=1…Sun=7) at [hour]:[minute], local tz.
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOf(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Best-effort IANA zone name from a UTC offset. Covers common zones; falls
  /// back to null (UTC local) when unknown. Kept lightweight — accurate wall
  /// clock only requires the offset for zonedSchedule.
  String? _guessTimeZone(Duration offset) {
    const map = <int, String>{
      -480: 'America/Los_Angeles',
      -420: 'America/Denver',
      -360: 'America/Chicago',
      -300: 'America/New_York',
      0: 'UTC',
      60: 'Europe/Paris',
      120: 'Europe/Helsinki',
      330: 'Asia/Kolkata',
      480: 'Asia/Singapore',
      540: 'Asia/Tokyo',
      600: 'Australia/Sydney',
    };
    return map[offset.inMinutes];
  }
}
