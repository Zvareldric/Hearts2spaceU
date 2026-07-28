import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../shared/services/url_opener.dart';
import '../domain/award.dart';
import '../domain/award_repository.dart';

/// Loads awards from a JSON asset bundled with the app.
///
/// Bundled on purpose: an award never changes once it has been given, making
/// this the most stable data in the app — a network round trip would only add
/// a way for it to fail.
class AssetAwardRepository implements AwardRepository {
  const AssetAwardRepository({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath = 'assets/data/awards.json';

  final String assetPath;

  @override
  Future<List<Award>> getAwards() async {
    final raw = await rootBundle.loadString(assetPath);
    return parseAwards(raw);
  }

  /// Parses the raw JSON string into [Award]s.
  ///
  /// Pure and exposed so it can be unit-tested without loading a real asset.
  /// Throws [FormatException] / [TypeError] on malformed data.
  static List<Award> parseAwards(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('awards.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _awardFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Award _awardFromJson(Map<String, dynamic> json) {
    final sourceUrl = json['sourceUrl'] as String?;
    if (sourceUrl != null && !UrlOpener.isSafe(sourceUrl)) {
      // Same rule as the streaming hub: a bad link is rejected here, so it can
      // never reach the domain or the launcher.
      throw FormatException('Award sourceUrl must be https: $sourceUrl');
    }

    return Award(
      id: json['id'] as String,
      title: json['title'] as String,
      ceremony: json['ceremony'] as String,
      year: json['year'] as int,
      type: json['type'] as String? ?? Award.typeAward,
      awardedOn: _parseIsoDate(json['awardedOn'] as String?),
      work: json['work'] as String?,
      members: _parseStringList(json['members']),
      note: json['note'] as String?,
      sourceUrl: sourceUrl,
    );
  }

  static DateTime? _parseIsoDate(String? value) =>
      value == null ? null : DateTime.parse(value);

  static List<String> _parseStringList(Object? value) {
    if (value is! List) return const [];
    return value.map((e) => e as String).toList(growable: false);
  }
}
