import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/reminders/data/local_notification_scheduler.dart';
import 'package:hearts2spaceu/features/reminders/data/prefs_reminder_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrefsReminderRepository', () {
    const repository = PrefsReminderRepository();

    test('what is saved is what loads, to the instant', () async {
      SharedPreferences.setMockInitialValues({});
      final fireAt = DateTime(2026, 10, 24, 9, 30);

      await repository.save({'vote:a': fireAt});

      final loaded = await repository.load();
      expect(loaded.keys, ['vote:a']);
      expect(loaded['vote:a']!.isAtSameMomentAs(fireAt), isTrue);
    });

    test('corrupt storage reads as no reminders, not a crash', () async {
      SharedPreferences.setMockInitialValues({
        PrefsReminderRepository.storageKey: '{not json',
      });
      expect(await repository.load(), isEmpty);

      SharedPreferences.setMockInitialValues({
        PrefsReminderRepository.storageKey: '["vote:a"]',
      });
      expect(await repository.load(), isEmpty);
    });

    test('one unreadable entry costs only that entry', () async {
      SharedPreferences.setMockInitialValues({
        PrefsReminderRepository.storageKey:
            '{"vote:a":"2026-10-24T02:00:00.000Z","vote:b":"soon","c":3}',
      });
      expect((await repository.load()).keys, ['vote:a']);
    });
  });

  group('notificationId', () {
    test('is the same for the same key on every launch', () {
      // A known FNV-1a value, not just "equal twice in one run":
      // String.hashCode would pass that and still change between launches,
      // and then rescheduling would add a second notification.
      expect(notificationId('a'), 0x640c292c);
      expect(notificationId('vote:mama'), notificationId('vote:mama'));
    });

    test('tells keys apart and stays a positive 32-bit int', () {
      final ids = [
        'event:tima-2026-day-1',
        'event:tima-2026-day-2',
        'vote:mama-2026-worldwide',
        'vote:mama-2026-worldwide ',
      ].map(notificationId).toList();

      expect(ids.toSet().length, ids.length);
      expect(ids.every((id) => id >= 0 && id <= 0x7fffffff), isTrue);
    });
  });
}
