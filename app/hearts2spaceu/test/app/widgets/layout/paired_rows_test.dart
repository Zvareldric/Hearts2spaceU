import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/layout/paired_rows.dart';

Future<void> _pump(
  WidgetTester tester,
  List<Widget> children, {
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = const Size(360, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: ListView(children: [PairedRows(children: children)]),
      ),
    ),
  );
}

Widget _box(Key key, double height) =>
    Container(key: key, height: height, color: Colors.blue);

void main() {
  testWidgets('both children in a row take the taller one\'s height', (
    tester,
  ) async {
    // The even rhythm a fixed-ratio grid gave for free, without its fixed
    // height: the row is as tall as its content needs.
    await _pump(tester, [
      Container(key: const Key('short'), color: Colors.blue),
      _box(const Key('tall'), 120),
    ]);

    expect(tester.getSize(find.byKey(const Key('short'))).height, 120);
    expect(tester.getSize(find.byKey(const Key('tall'))).height, 120);
  });

  testWidgets('an odd last child keeps half the width, not the whole row', (
    tester,
  ) async {
    await _pump(tester, [
      _box(const Key('a'), 40),
      _box(const Key('b'), 40),
      _box(const Key('c'), 40),
    ]);

    expect(
      tester.getSize(find.byKey(const Key('c'))).width,
      tester.getSize(find.byKey(const Key('a'))).width,
    );
  });

  testWidgets('a row grows with 200% text instead of clipping it', (
    tester,
  ) async {
    // The whole reason this replaces the fixed-ratio grids: More, Statistics
    // and Members each overflowed as soon as their text outgrew the ratio.
    await _pump(tester, [
      const Text('A label long enough to wrap over several lines at 200%'),
      const Text('Short'),
    ], textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
