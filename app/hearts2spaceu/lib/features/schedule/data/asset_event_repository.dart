import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/event.dart';
import '../domain/event_repository.dart';

/// Loads events from a JSON asset bundled with the app.
///
/// Concrete implementation of [EventRepository] for Sprint 2. It keeps the
/// "how" (asset + JSON) here, so the rest of the app — which only knows the
/// [EventRepository] contract — stays unchanged if the source later becomes a
/// network API (the Data Source Boundary, docs/04).
class AssetEventRepository implements EventRepository {
  const AssetEventRepository({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath = 'assets/data/events.json';

  final String assetPath;

  @override
  Future<List<Event>> getEvents() async {
    final raw = await rootBundle.loadString(assetPath);
    return parseEvents(raw);
  }

  /// Parses the raw JSON string into [Event]s.
  ///
  /// Pure and exposed so it can be unit-tested without loading a real asset.
  /// Throws [FormatException] / [TypeError] on malformed data; the caller (a
  /// Riverpod provider) turns that into an error state.
  static List<Event> parseEvents(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('events.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _eventFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Event _eventFromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      type: json['type'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      officialUrl: json['officialUrl'] as String?,
    );
  }
}
