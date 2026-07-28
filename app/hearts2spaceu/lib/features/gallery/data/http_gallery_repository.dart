import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/services/url_opener.dart';
import '../domain/album.dart';
import '../domain/gallery_repository.dart';
import '../domain/photo.dart';

/// Fetches the albums from a hosted JSON file.
///
/// Hosted rather than bundled so adding photos is a commit, not an app
/// release, and the binary stays small (docs/specs/gallery.md §4).
class HttpGalleryRepository implements GalleryRepository {
  HttpGalleryRepository({http.Client? client, this.url = _defaultUrl})
    : _client = client ?? http.Client();

  static const _defaultUrl =
      'https://raw.githubusercontent.com/Zvareldric/Hearts2spaceU/main/data/gallery.json';

  static const timeout = Duration(seconds: 10);

  final http.Client _client;
  final String url;

  @override
  Future<List<Album>> getAlbums() async {
    final response = await _client.get(Uri.parse(url)).timeout(timeout);

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to load the gallery (HTTP ${response.statusCode})',
        Uri.parse(url),
      );
    }

    return parseAlbums(utf8.decode(response.bodyBytes));
  }

  /// Parses the raw JSON string into [Album]s.
  ///
  /// Pure and exposed so it can be unit-tested without any network.
  static List<Album> parseAlbums(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('gallery.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _albumFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Album _albumFromJson(Map<String, dynamic> json) {
    final coverUrl = _requireHttps(json['coverUrl'] as String, 'coverUrl');

    final rawPhotos = json['photos'];
    if (rawPhotos is! List || rawPhotos.isEmpty) {
      // An album with nothing in it would render an empty grid and a dead end.
      throw FormatException('Album "${json['id']}" must have photos.');
    }

    return Album(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUrl: coverUrl,
      year: json['year'] as int?,
      photos: rawPhotos
          .map((p) => _photoFromJson(p as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static Photo _photoFromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      url: _requireHttps(json['url'] as String, 'url'),
      caption: json['caption'] as String?,
    );
  }

  /// Image URLs go straight into `Image.network`; rejecting anything but https
  /// here keeps other schemes out of the app entirely.
  static String _requireHttps(String value, String field) {
    if (!UrlOpener.isSafe(value)) {
      throw FormatException('Gallery $field must be an https URL: $value');
    }
    return value;
  }
}
