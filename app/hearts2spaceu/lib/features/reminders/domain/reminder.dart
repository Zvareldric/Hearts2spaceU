/// One notification the app has arranged to show.
///
/// Pure and immutable. It carries no platform notification id: the plugin
/// wants an int, the domain works in keys like `vote:mama-2026`, and turning
/// one into the other is the data layer's business (docs/specs/reminders.md
/// §5).
class Reminder {
  const Reminder({
    required this.key,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  /// `<kind>:<id>` — the same flat namespace as favourites.
  final String key;

  /// The instant it goes off.
  final DateTime fireAt;

  final String title;
  final String body;
}
