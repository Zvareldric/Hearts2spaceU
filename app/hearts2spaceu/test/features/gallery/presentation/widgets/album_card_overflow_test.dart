import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/layout/paired_rows.dart';
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

/// Renders the albums the way AlbumsPage does — rows of two sized to their
/// content — at the given screen width and text size.
Future<void> _pumpGrid(
  WidgetTester tester,
  double width, {
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            PairedRows(
              children: [
                AlbumCard(album: _album),
                AlbumCard(album: _album),
                AlbumCard(album: _album),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('does not overflow at phone width', (tester) async {
    // Regression history: a square cover in a fixed-ratio grid cell overflowed
    // it; making the cover absorb the leftover space instead then squeezed it
    // to ~24px at 200% text. The rows now take their height from the card.
    await _pumpGrid(tester, 360);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at a cramped width', (tester) async {
    await _pumpGrid(tester, 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps a square cover at 200% text', (tester) async {
    await _pumpGrid(tester, 360, textScale: 2);
    expect(tester.takeException(), isNull);

    final cover = tester.getSize(find.byType(AspectRatio).first);
    expect(cover.width, cover.height);
    // Half a 360dp screen, less padding: the cover is a real picture, not a
    // sliver left over after the text.
    expect(cover.height, greaterThan(120));
  });
}
