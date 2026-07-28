import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/gallery/domain/album.dart';
import 'package:hearts2spaceu/features/gallery/domain/photo.dart';
import 'package:hearts2spaceu/features/gallery/presentation/widgets/album_card.dart';

const _album = Album(
  id: 'a',
  title: 'A Very Long Album Title That Wraps',
  coverUrl: 'https://example.com/c.jpg',
  year: 2026,
  photos: [Photo(id: '1', url: 'https://example.com/1.jpg')],
);

/// Renders the grid the way AlbumsPage does, at the given screen width.
Future<void> _pumpGrid(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: 4,
          itemBuilder: (_, _) => const AlbumCard(album: _album),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('does not overflow at phone width', (tester) async {
    // Regression: a fixed AspectRatio cover left no room for the two text
    // lines, overflowing the grid cell by a few pixels.
    await _pumpGrid(tester, 360);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at a cramped width', (tester) async {
    await _pumpGrid(tester, 320);
    expect(tester.takeException(), isNull);
  });
}
