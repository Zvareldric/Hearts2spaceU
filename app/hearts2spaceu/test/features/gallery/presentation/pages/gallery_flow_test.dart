import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/gallery/domain/album.dart';
import 'package:hearts2spaceu/features/gallery/domain/gallery_repository.dart';
import 'package:hearts2spaceu/features/gallery/domain/photo.dart';
import 'package:hearts2spaceu/features/gallery/presentation/pages/album_page.dart';
import 'package:hearts2spaceu/features/gallery/presentation/pages/albums_page.dart';
import 'package:hearts2spaceu/features/gallery/presentation/pages/photo_viewer_page.dart';
import 'package:hearts2spaceu/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:hearts2spaceu/features/gallery/presentation/widgets/album_card.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

class _FakeGalleryRepository implements GalleryRepository {
  _FakeGalleryRepository(this.albums);

  final List<Album> albums;

  @override
  Future<List<Album>> getAlbums() async => albums;
}

class _ThrowingGalleryRepository implements GalleryRepository {
  @override
  Future<List<Album>> getAlbums() async => throw Exception('offline');
}

Widget _app(GalleryRepository repository) {
  return ProviderScope(
    overrides: [galleryRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AlbumsPage(),
    ),
  );
}

List<Album> _albums() => const [
  Album(
    id: 'lemon-tang',
    title: 'Lemon Tang',
    coverUrl: 'https://example.com/cover.jpg',
    year: 2026,
    photos: [
      Photo(id: '01', url: 'https://example.com/01.jpg', caption: 'On stage'),
      Photo(id: '02', url: 'https://example.com/02.jpg'),
    ],
  ),
];

void main() {
  testWidgets('Data — shows a card per album', (tester) async {
    await tester.pumpWidget(_app(_FakeGalleryRepository(_albums())));
    await tester.pumpAndSettle();

    expect(find.byType(AlbumCard), findsOneWidget);
    expect(find.text('Lemon Tang'), findsOneWidget);
    expect(find.text('2026 · 2 photos'), findsOneWidget);
  });

  testWidgets('Empty — shows the empty state', (tester) async {
    await tester.pumpWidget(_app(_FakeGalleryRepository(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
  });

  testWidgets('Error — shows the error state', (tester) async {
    await tester.pumpWidget(_app(_ThrowingGalleryRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
  });

  testWidgets('Navigation — albums → grid → viewer → back → back', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeGalleryRepository(_albums())));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AlbumCard));
    await tester.pumpAndSettle();
    expect(find.byType(AlbumPage), findsOneWidget);

    // Open the second photo; the viewer must land on it, not on the first.
    await tester.tap(find.byType(Hero).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoViewerPage), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AlbumPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AlbumsPage), findsOneWidget);
  });

  testWidgets('a dead image URL breaks only its own tile', (tester) async {
    // Image.network fails in tests (no real HTTP), which is exactly the
    // dead-link case: the page must still render.
    await tester.pumpWidget(_app(_FakeGalleryRepository(_albums())));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AlbumCard), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_rounded), findsWidgets);
  });
}
