import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/presentation/event_date_format.dart';

void main() {
  final august = DateTime(2026, 8, 5, 20, 28);

  test('shows date and time by default', () {
    expect(formatEventDateTime(august), '05/08/2026 · 20:28');
  });

  test('omits the time for an all-day event', () {
    expect(formatEventDateTime(august, allDay: true), '05/08/2026');
  });

  test('never prints a misleading 00:00 for an all-day event', () {
    // The whole reason `allDay` exists: a date-only entry stored as midnight
    // must not claim the event happens at midnight.
    final midnight = DateTime(2026, 8, 12);

    expect(formatEventDateTime(midnight, allDay: true), '12/08/2026');
    expect(formatEventDateTime(midnight), '12/08/2026 · 00:00');
  });

  test('pads single-digit day, month, hour and minute', () {
    expect(
      formatEventDateTime(DateTime(2026, 1, 2, 3, 4)),
      '02/01/2026 · 03:04',
    );
  });
}
