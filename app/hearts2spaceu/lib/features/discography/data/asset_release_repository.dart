import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../shared/services/url_opener.dart';
import '../domain/release.dart';
import '../domain/release_repository.dart';

/// Loads the discography from a JSON asset bundled with the app.
///
/// Bundled on purpose, like awards: a release never changes once it is out, so
/// this is some of the most stable data in the app and a network round trip
/// would only add a way for it to fail.
class AssetReleaseRepository implements ReleaseRepository {
  const AssetReleaseRepository({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath = 'assets/data/discography.json';

  final String assetPath;

  @override
  Future<List<Release>> getReleases() async {
    final raw = await rootBundle.loadString(assetPath);
    return parseReleases(raw);
  }

  /// Parses the raw JSON string into [Release]s.
  ///
  /// Pure and exposed so it can be unit-tested without loading a real asset.
  /// Throws [FormatException] / [TypeError] on malformed data.
  static List<Release> parseReleases(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException(
        'discography.json must contain a JSON array.',
      );
    }
    return decoded
        .map((item) => _releaseFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Release _releaseFromJson(Map<String, dynamic> json) {
    final coverUrl = json['coverUrl'] as String?;
    if (coverUrl != null && !UrlOpener.isSafe(coverUrl)) {
      // Same rule as the gallery: a bad URL is rejected here, so it can never
      // reach the domain or an image loader.
      throw FormatException('Release coverUrl must be https: $coverUrl');
    }

    return Release(
      id: json['id'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
      type: json['type'] as String?,
      releaseDate: switch (json['releaseDate']) {
        final String date => DateTime.parse(date),
        _ => null,
      },
      note: json['note'] as String?,
      coverUrl: coverUrl,
      tracks: _parseTracks(json['tracks']),
    );
  }

  static List<Track> _parseTracks(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item as Map<String, dynamic>)
        .map(
          (json) => Track(
            title: json['title'] as String,
            isTitleTrack: json['isTitleTrack'] as bool? ?? false,
            duration: _parseDuration(json['duration']),
          ),
        )
        .toList(growable: false);
  }

  /// Reads a `m:ss` running time, the form every source prints it in.
  ///
  /// Rejected here rather than rendered, for the same reason as [coverUrl]: a
  /// typo like `2:6` should fail the asset test on a laptop, not quietly show a
  /// wrong running time on a fan's phone.
  static Duration? _parseDuration(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Track duration must be a "m:ss" string: $value');
    }
    final match = RegExp(r'^(\d{1,2}):([0-5]\d)$').firstMatch(value);
    if (match == null) {
      throw FormatException('Track duration must look like "2:43": $value');
    }
    return Duration(
      minutes: int.parse(match.group(1)!),
      seconds: int.parse(match.group(2)!),
    );
  }
}
