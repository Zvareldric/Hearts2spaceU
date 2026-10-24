import 'reminder.dart';

/// The boundary between the reminders and the platform that shows them.
///
/// Without it every widget test would reach for a notification plugin that
/// does not exist under `flutter test` (docs/specs/reminders.md §5).
abstract interface class ReminderScheduler {
  /// Whether this platform can show scheduled notifications at all. The bell
  /// is not offered where it could never ring.
  bool get isSupported;

  /// Asks for permission to notify, and reports whether it is granted.
  ///
  /// Called on the first opt-in, never at startup: a dialog that arrives
  /// before the reader wants anything gets refused, and on Android 13+ a
  /// refusal can use up the chance to ask again.
  Future<bool> requestPermission();

  /// Schedules [reminder], replacing any pending one under the same key.
  Future<void> schedule(Reminder reminder);

  /// Withdraws the pending reminder under [key], if there is one.
  Future<void> cancel(String key);
}
