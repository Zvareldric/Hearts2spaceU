import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../agenda/domain/agenda_item.dart';
import '../../domain/plan_reminders.dart';
import '../providers/reminder_providers.dart';

/// Turns a reminder on or off for one agenda row.
///
/// Lives in the feature, like `FavoriteButton`: it knows what an
/// [AgendaItem] is, so it is not a Design System component.
class ReminderButton extends ConsumerWidget {
  const ReminderButton({super.key, required this.item, required this.now});

  final AgendaItem item;

  /// The instant the row is drawn against, so whether a reminder is still
  /// possible agrees with the countdown printed beside it.
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A bell on a platform that cannot ring would be a promise it cannot keep.
    if (!ref.watch(reminderSchedulerProvider).isSupported) {
      return const SizedBox.shrink();
    }

    final isOn = ref.watch(isReminderOnProvider(reminderKey(item)));
    final possible = isOn || reminderFireTime(item, now) != null;
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      // Still tappable when it is too late: the tap is how the reader finds
      // out why, rather than meeting a control that silently does nothing.
      onPressed: () => _toggle(context, ref),
      tooltip: isOn
          ? 'Turn off reminder'
          : possible
          ? 'Remind me'
          : 'Too close for a reminder',
      icon: Icon(
        isOn
            ? Icons.notifications_active_rounded
            : possible
            ? Icons.notifications_none_rounded
            : Icons.notifications_off_outlined,
        color: isOn ? scheme.secondary : scheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(remindersProvider.notifier).toggle(item);

    final message = switch (result) {
      ReminderToggle.on => _setMessage(),
      ReminderToggle.off => null,
      // Said plainly, because a bell that stays dark with no reason given
      // reads as a broken button.
      ReminderToggle.denied =>
        'Reminders need notifications. Allow them for Hearts2spaceU in your '
            'device settings, then tap the bell again.',
      ReminderToggle.tooSoon => "It's too close now for a reminder.",
    };
    if (message == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Tells the reader when it will go off, which the bell alone cannot.
  String _setMessage() {
    final fireAt = reminderFireTime(item, DateTime.now());
    if (item.isAllDay || fireAt == null) {
      return "Reminder on — you'll hear about it the morning before.";
    }
    final hours = item.localDue.difference(fireAt).inHours;
    final lead = hours == 1 ? '1 hour' : '$hours hours';
    final verb = item.kind == AgendaKind.vote ? 'closes' : 'starts';
    return "Reminder on — you'll hear $lead before it $verb.";
  }
}
