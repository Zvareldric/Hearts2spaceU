import 'package:flutter/material.dart';

import '../../../../app/widgets/badges/type_badge.dart';
import '../../domain/event.dart';

/// The rounded day/month block that opens every event row.
///
/// Tinted by the event's own type, so the block and the type pill beside it are
/// the same color — the date carries the category without a second reading.
/// Shared by Schedule's card and Home's "Up next" so both stay in step.
class EventDateBlock extends StatelessWidget {
  const EventDateBlock({super.key, required this.event, this.size = 44});

  final Event event;
  final double size;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final style = typeStyleFor(event.type);
    final start = event.startDateTime;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(size / 3.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${start.day}',
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              height: 1,
              color: style.foreground,
            ),
          ),
          Text(
            _months[start.month - 1].toUpperCase(),
            style: TextStyle(
              fontSize: size * 0.195,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: 0.4,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
