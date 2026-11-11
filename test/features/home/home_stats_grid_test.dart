import 'package:fantasy/features/home/presentation/widgets/home_stats_grid.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for the HomeStatsGrid layout defects:
/// 1. Cards overflowing (aspect-ratio-driven tile height was shorter than the
///    cards' content, clipping ~26px at ~390dp).
/// 2. A large empty area directly below the two cards (the shrinkWrap
///    GridView reserved the viewport's exposed bottom inset – dock height –
///    inside its own box when the parent Scaffold used `extendBody: true`).
///
/// Both are guarded here by pumping the grid inside the same parent shape the
/// Home screen uses and asserting geometry: content-fitted equal heights and
/// exactly the 12px sibling gap below the cards.
void main() {
  final manager = FantasyManagerModel.dummy();

  Future<void> pump(
    WidgetTester tester, {
    required double width,
    required double textScale,
  }) async {
    tester.view.physicalSize = Size(width, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
        home: Scaffold(
          // Mirrors the Home screen: the dock exposes a bottom viewport inset.
          extendBody: true,
          bottomNavigationBar: const SizedBox(height: 60),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    HomeStatsGrid(manager: manager),
                    const SizedBox(height: 12),
                    const SizedBox(
                      height: 40,
                      child: ColoredBox(color: Colors.red),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect cardColumnRect(WidgetTester tester, int index) => tester.getRect(
    find
        .descendant(
          of: find.byType(IntrinsicHeight),
          matching: find.byType(Column),
        )
        .at(index),
  );

  for (final (width, scale) in const [
    (320.0, 1.0),
    (360.0, 1.0),
    (390.0, 1.0),
    (412.0, 1.0),
    (320.0, 1.3),
    (390.0, 1.3),
    (390.0, 2.0),
  ]) {
    testWidgets('renders content-fitted equal-height cards without overflow '
        'at ${width.round()}dp textScale=$scale', (tester) async {
      await pump(tester, width: width, textScale: scale);
      expect(tester.takeException(), isNull);

      final grid = tester.getRect(find.byType(IntrinsicHeight));
      final col1 = cardColumnRect(tester, 0);
      final col2 = cardColumnRect(tester, 1);

      // Both cards are equal in height.
      expect((col1.height - col2.height).abs(), lessThan(.5));
      // Cards fill the grid exactly (padding 2x16 + border 2x1) – i.e. the
      // cards are as tall as their content, with no reserved empty area
      // below them inside the grid.
      expect((col1.height + 34 - grid.height).abs(), lessThan(1.0));
      // Content actually fits (rank card min content is ~144px).
      expect(col1.height, greaterThan(143));
      expect(col2.height, greaterThan(143));

      // Only the 12px sibling gap separates the grid from the next section;
      // no residual viewport bottom inset is reserved inside the grid.
      final next = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == Colors.red,
      );
      final nextRect = tester.getRect(next);
      expect((nextRect.top - grid.bottom - 12).abs(), lessThan(.5));
    }, timeout: const Timeout(Duration(minutes: 2)));
  }

  testWidgets('keeps a 12px gap between the two cards', (tester) async {
    await pump(tester, width: 390, textScale: 1);

    final col1 = cardColumnRect(tester, 0);
    final col2 = cardColumnRect(tester, 1);
    // The visible card gap is 12px; the content columns sit 17px (padding 16 +
    // border 1) inside each card shell, so their edge-to-edge distance is
    // 12 + 2 * 17 = 46.
    expect((col2.left - col1.right - 46).abs(), lessThanOrEqualTo(.5));
  });
}
