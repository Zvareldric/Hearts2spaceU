import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder.dart';
import '../domain/reminder_scheduler.dart';

/// Schedules reminders as local notifications on the device.
///
/// Nothing leaves the device and nothing needs a server: the system holds the
/// notification and shows it at the time, whether or not the app is running.
class LocalNotificationScheduler implements ReminderScheduler {
  LocalNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _ready;

  /// The platforms the app ships on. Elsewhere the bell is not offered.
  @override
  bool get isSupported =>
      !kIsWeb &&
      const {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  /// Set up on first use rather than at startup, so a reader who never turns a
  /// reminder on never pays for it. Every `request*Permission` flag is off:
  /// on Apple platforms they default to on and would put the permission
  /// dialog in front of the reader the moment the plugin starts.
  Future<bool> _init() => _ready ??= () async {
    if (!isSupported) return false;
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_reminder'),
          iOS: darwin,
          macOS: darwin,
        ),
      );
      return true;
    } on MissingPluginException {
      return false;
    }
  }();

  @override
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    final granted = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission(),
      TargetPlatform.iOS =>
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true),
      TargetPlatform.macOS =>
        _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true),
      _ => null,
    };
    return await granted ?? false;
  }

  @override
  Future<void> schedule(Reminder reminder) async {
    if (!await _init()) return;
    await _plugin.zonedSchedule(
      id: notificationId(reminder.key),
      // UTC needs no time-zone database: `fireAt` is already an instant, so
      // there is nothing for the device's zone to decide.
      scheduledDate: tz.TZDateTime.from(reminder.fireAt, tz.UTC),
      notificationDetails: _details,
      // Inexact: the system may shift it a few minutes to save battery, which
      // a reminder set a day ahead can afford. Exact alarms need a permission
      // Google Play restricts (docs/specs/reminders.md §5).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: reminder.title,
      body: reminder.body,
    );
  }

  @override
  Future<void> cancel(String key) async {
    if (!await _init()) return;
    await _plugin.cancel(id: notificationId(key));
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Reminders you turn on in the Agenda.',
      // Each one was asked for, so it may interrupt.
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );
}

/// The platform notification id for [key]: a stable 32-bit FNV-1a hash.
///
/// Stable across launches, unlike `String.hashCode`, so scheduling the same
/// key again replaces its notification instead of adding a second one.
/// Masked to a positive int, which is all Android accepts.
@visibleForTesting
int notificationId(String key) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
