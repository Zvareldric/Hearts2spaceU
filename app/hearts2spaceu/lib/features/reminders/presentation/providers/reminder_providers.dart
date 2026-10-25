import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../agenda/domain/agenda_item.dart';
import '../../../agenda/presentation/providers/agenda_providers.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../../../voting/presentation/providers/voting_providers.dart';
import '../../data/local_notification_scheduler.dart';
import '../../data/prefs_reminder_repository.dart';
import '../../domain/plan_reminders.dart';
import '../../domain/reminder_repository.dart';
import '../../domain/reminder_scheduler.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return const PrefsReminderRepository();
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return LocalNotificationScheduler();
});

/// What a tap on the bell came to.
enum ReminderToggle {
  on,
  off,

  /// The reader refused notifications, so nothing was scheduled and the bell
  /// stays dark. A normal state, not an error (docs/specs/reminders.md §4).
  denied,

  /// Both the day-before and the hour-before have already passed.
  tooSoon,
}

/// The reader's reminders — each key with the instant it fires — and the only
/// place they are changed.
///
/// Every change goes through one queue. A toggle waits on a permission dialog
/// and a reconcile on the platform; run side by side, a reconcile holding an
/// old copy could re-schedule a reminder the reader had just turned off.
class RemindersNotifier extends AsyncNotifier<Map<String, DateTime>> {
  Future<void> _queue = Future.value();

  @override
  Future<Map<String, DateTime>> build() =>
      ref.watch(reminderRepositoryProvider).load();

  Future<ReminderToggle> toggle(AgendaItem item) => _serial(() async {
    final current = await future;
    final key = reminderKey(item);
    final now = DateTime.now();
    final scheduler = ref.read(reminderSchedulerProvider);

    if (current[key] case final firesAt?) {
      await _save({...current}..remove(key));
      // One that has already gone off belongs to the reader now; cancelling
      // it would also pull it out of their notification tray.
      if (firesAt.isAfter(now)) await scheduler.cancel(key);
      return ReminderToggle.off;
    }

    final fireAt = reminderFireTime(item, now);
    if (fireAt == null) return ReminderToggle.tooSoon;

    // Asked here, on the tap that wants it, never at startup. The system only
    // shows its dialog the first time; after that this just reads the answer,
    // which the reader may have changed in Settings since.
    if (!await scheduler.requestPermission()) return ReminderToggle.denied;

    await scheduler.schedule(reminderFor(item, fireAt));
    await _save({...current, key: fireAt});
    return ReminderToggle.on;
  });

  /// Brings the scheduled reminders in line with the agenda as it now stands.
  ///
  /// [loadedKinds] names the sources that loaded successfully. Only those can
  /// prove an item is gone (docs/specs/reminders.md §4).
  Future<void> reconcile(List<AgendaItem> items, Set<AgendaKind> loadedKinds) =>
      _serial(() async {
        final current = await future;
        if (current.isEmpty) return;

        final plan = planReminders(
          items: items,
          optedIn: current,
          loadedKinds: loadedKinds,
          now: DateTime.now(),
        );
        if (!mapEquals(plan.next, current)) await _save(plan.next);

        final scheduler = ref.read(reminderSchedulerProvider);
        for (final key in plan.toCancel) {
          await scheduler.cancel(key);
        }
        for (final reminder in plan.toSchedule) {
          await scheduler.schedule(reminder);
        }
      });

  Future<void> _save(Map<String, DateTime> next) async {
    state = AsyncData(next);
    await ref.read(reminderRepositoryProvider).save(next);
  }

  Future<T> _serial<T>(Future<T> Function() run) {
    final result = _queue.then((_) => run());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, Map<String, DateTime>>(
      RemindersNotifier.new,
    );

/// Whether [item] has a reminder on. False while loading, so the bell renders
/// dark rather than flickering.
final isReminderOnProvider = Provider.family<bool, String>((ref, key) {
  return ref.watch(remindersProvider).asData?.value.containsKey(key) ?? false;
});

/// Re-plans the reminders whenever the agenda's data changes: a vote whose
/// deadline moved is reminded at the new time, one that was withdrawn is not
/// reminded at all.
///
/// Watched from the app root, so it runs whether or not the Agenda is open.
/// It reads nothing until the reader has a reminder, so a reader who never
/// uses the bell never loads votes for its sake.
final reminderSyncProvider = Provider<void>((ref) {
  final hasAny = ref.watch(
    remindersProvider.select((r) => r.asData?.value.isNotEmpty ?? false),
  );
  if (!hasAny) return;

  final events = ref.watch(upcomingEventsProvider);
  final votes = ref.watch(openVotesProvider);
  final items = ref.watch(agendaProvider).asData?.value;
  if (items == null) return;

  ref.read(remindersProvider.notifier).reconcile(items, {
    if (events is AsyncData) AgendaKind.event,
    if (votes is AsyncData) AgendaKind.vote,
  });
});
