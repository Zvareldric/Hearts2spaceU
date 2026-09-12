import 'event.dart';

/// Contract for retrieving official schedule events.
///
/// Declares *what* is needed (all events); implementations in the data layer
/// decide *where* they come from, keeping state and presentation independent of
/// the data source — the Data Source Boundary (docs/04).
abstract interface class EventRepository {
  /// Loads all events. Throws if the source cannot be read or parsed.
  ///
  /// [forceRefresh] asks a source that keeps a copy to go past it and fetch a
  /// new one. Sources with nothing to bypass — a bundled asset, a plain HTTP
  /// call — ignore it.
  Future<List<Event>> getEvents({bool forceRefresh = false});
}
