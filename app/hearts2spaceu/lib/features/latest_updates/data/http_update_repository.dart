import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/update.dart';
import '../domain/update_repository.dart';

/// Fetches updates from a hosted JSON file over the network.
///
/// First implementation in the app to reach outside the bundle. It keeps the
/// "how" (HTTP + JSON) here, so the providers and pages above — which only know
/// the [UpdateRepository] contract — are identical in shape to the asset-backed
/// features (the Data Source Boundary, docs/04).
class HttpUpdateRepository implements UpdateRepository {
  HttpUpdateRepository({http.Client? client, this.url = _defaultUrl})
    : _client = client ?? http.Client();

  static const _defaultUrl =
      'https://raw.githubusercontent.com/Zvareldric/Hearts2spaceU/main/data/updates.json';

  /// Give up rather than leave the UI spinning forever.
  static const timeout = Duration(seconds: 10);

  final http.Client _client;
  final String url;

  @override
  Future<List<Update>> getUpdates() async {
    final response = await _client.get(Uri.parse(url)).timeout(timeout);

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to load updates (HTTP ${response.statusCode})',
        Uri.parse(url),
      );
    }

    // bodyBytes + utf8: response.body guesses latin-1 when the server omits a
    // charset, which would mangle non-ASCII titles.
    return parseUpdates(utf8.decode(response.bodyBytes));
  }

  /// Parses the raw JSON string into [Update]s.
  ///
  /// Pure and exposed so it can be unit-tested without any network.
  /// Throws [FormatException] / [TypeError] on malformed data; the caller (a
  /// Riverpod provider) turns that into an error state.
  static List<Update> parseUpdates(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('updates.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _updateFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Update _updateFromJson(Map<String, dynamic> json) {
    return Update(
      id: json['id'] as String,
      title: json['title'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      summary: json['summary'] as String?,
      body: json['body'] as String?,
      category: json['category'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
