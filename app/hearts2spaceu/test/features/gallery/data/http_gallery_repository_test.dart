import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/gallery/data/http_gallery_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _oneAlbum = '''
[
  {
    "id": "lemon-tang",
    "title": "Lemon Tang",
    "year": 2026,
    "coverUrl": "https://example.com/cover.jpg",
    "photos": [
      { "id": "01", "url": "https://example.com/01.jpg", "caption": "On stage" },
      { "id": "02", "url": "https://example.com/02.jpg" }
    ]
  }
]
''';

void main() {
  group('parseAlbums', () {
    test('parses an album with its nested photos', () {
      final album = HttpGalleryRepository.parseAlbums(_oneAlbum).single;

      expect(album.id, 'lemon-tang');
      expect(album.title, 'Lemon Tang');
      expect(album.year, 2026);
      expect(album.coverUrl, 'https://example.com/cover.jpg');
      expect(album.photos, hasLength(2));
      expect(album.photos.first.caption, 'On stage');
      expect(album.photos.last.caption, isNull);
    });

    test('rejects an album with no photos', () {
      // An empty album is a dead end: a grid with nothing and no way forward.
      const raw =
          '[{"id":"a","title":"A","coverUrl":"https://e.com/c.jpg","photos":[]}]';

      expect(
        () => HttpGalleryRepository.parseAlbums(raw),
        throwsFormatException,
      );
    });

    test('rejects a non-https cover URL', () {
      const raw =
          '[{"id":"a","title":"A","coverUrl":"http://e.com/c.jpg","photos":[{"id":"1","url":"https://e.com/1.jpg"}]}]';

      expect(
        () => HttpGalleryRepository.parseAlbums(raw),
        throwsFormatException,
      );
    });

    test('rejects a non-https photo URL', () {
      const raw =
          '[{"id":"a","title":"A","coverUrl":"https://e.com/c.jpg","photos":[{"id":"1","url":"javascript:alert(1)"}]}]';

      expect(
        () => HttpGalleryRepository.parseAlbums(raw),
        throwsFormatException,
      );
    });

    test('throws when a required field is missing', () {
      const raw =
          '[{"title":"No id","coverUrl":"https://e.com/c.jpg","photos":[{"id":"1","url":"https://e.com/1.jpg"}]}]';

      expect(
        () => HttpGalleryRepository.parseAlbums(raw),
        throwsA(isA<TypeError>()),
      );
    });

    test('returns empty for an empty array', () {
      expect(HttpGalleryRepository.parseAlbums('[]'), isEmpty);
    });
  });

  group('getAlbums', () {
    test('returns albums on HTTP 200', () async {
      final repository = HttpGalleryRepository(
        client: MockClient((_) async => http.Response(_oneAlbum, 200)),
      );

      expect(await repository.getAlbums(), hasLength(1));
    });

    test('throws on a non-200 response', () async {
      final repository = HttpGalleryRepository(
        client: MockClient((_) async => http.Response('nope', 404)),
      );

      expect(repository.getAlbums(), throwsA(isA<http.ClientException>()));
    });
  });
}
