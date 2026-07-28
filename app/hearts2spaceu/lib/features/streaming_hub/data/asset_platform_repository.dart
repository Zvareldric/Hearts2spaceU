import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../shared/services/url_opener.dart';
import '../domain/official_platform.dart';
import '../domain/platform_repository.dart';

/// Loads the official platforms from a JSON asset bundled with the app.
///
/// Deliberately bundled rather than fetched: official channel URLs barely
/// change, and this hub is most useful exactly when the connection is poor
/// (docs/specs/streaming-hub.md §4).
class AssetPlatformRepository implements PlatformRepository {
  const AssetPlatformRepository({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath = 'assets/data/platforms.json';

  final String assetPath;

  @override
  Future<List<OfficialPlatform>> getPlatforms() async {
    final raw = await rootBundle.loadString(assetPath);
    return parsePlatforms(raw);
  }

  /// Parses the raw JSON string into [OfficialPlatform]s.
  ///
  /// Pure and exposed so it can be unit-tested without loading a real asset.
  /// Throws [FormatException] / [TypeError] on malformed data.
  static List<OfficialPlatform> parsePlatforms(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('platforms.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _platformFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static OfficialPlatform _platformFromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    if (!UrlOpener.isSafe(url)) {
      // Rejected at the boundary rather than at tap time: a bad link should
      // never make it into the domain in the first place.
      throw FormatException('Platform URL must be a valid https URL: $url');
    }

    return OfficialPlatform(
      id: json['id'] as String,
      name: json['name'] as String,
      url: url,
      category: json['category'] as String,
      handle: json['handle'] as String?,
    );
  }
}
