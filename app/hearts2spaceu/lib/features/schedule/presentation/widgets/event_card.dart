import 'package:flutter/material.dart';

import '../../domain/event.dart';
import '../event_date_format.dart';

/// A single event row in the schedule list.
///
/// Presentation only: it renders an [Event] and reports taps via [onTap]; it
/// does not know where a tap leads (the page decides navigation).
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.event)),
      title: Text(event.title),
      subtitle: Text(formatEventDateTime(event.startDateTime)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
