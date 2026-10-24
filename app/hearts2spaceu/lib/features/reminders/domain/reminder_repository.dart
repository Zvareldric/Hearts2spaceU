/// Where the reader's reminder opt-ins are kept: each key with the instant its
/// reminder is set to fire.
abstract interface class ReminderRepository {
  Future<Map<String, DateTime>> load();

  Future<void> save(Map<String, DateTime> reminders);
}
