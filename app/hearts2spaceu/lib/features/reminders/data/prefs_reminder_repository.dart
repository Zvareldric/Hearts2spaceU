import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/reminder_repository.dart';

/// Stores the opt-ins as one JSON object in `shared_preferences`: each key
/// with the instant its reminder is set to fire.
///
/// An object, not the array of keys favourites use: knowing when a reminder
/// was set to fire is what tells a reminder that already went off from one
/// still waiting, and only the waiting kind may be re-planned or withdrawn.
class PrefsReminderRepository implements ReminderRepository {
  const PrefsReminderRepository();

  static const storageKey = 'reminders';

  @override
  Future<Map<String, DateTime>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final MapEntry(:key, :value) in decoded.entries)
          if (key is String && value is String) key: ?DateTime.tryParse(value),
      };
    } on FormatException {
      // Corrupt storage reads as no reminders, never a crash.
      return {};
    }
  }

  @override
  Future<void> save(Map<String, DateTime> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode({
        for (final MapEntry(:key, :value) in reminders.entries)
          key: value.toUtc().toIso8601String(),
      }),
    );
  }
}
