import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/commentary_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _ts1 = '2026-11-07 16:54:52';
const _ts2 = '2026-11-07 16:53:44';

Future<void> _pump(WidgetTester tester, PremierLeagueMatchDetails details) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: CommentaryView(details: details)),
        ),
      ),
    );

void main() {
  testWidgets('renders one deduplicated English row per event', (tester) async {
    final details = PremierLeagueMatchDetails.fromParts(
      match: {},
      commentaryJson: {
        'data': [
          {
            'comment': 'Final del partido, Arsenal 1, Hull City 0.',
            'time': ' ',
            'type': 'end 14',
            'timestamp': _ts1,
          },
          {
            'comment': 'Match ends, Arsenal 1, Hull City 0.',
            'time': ' ',
            'type': 'end 14',
            'timestamp': _ts1,
          },
          {
            'comment': 'المباراة انتهى, أرسنال 1, هال سيتي 0.',
            'time': ' ',
            'type': 'end 14',
            'timestamp': _ts1,
          },
        ],
      },
    );
    await _pump(tester, details);

    expect(find.text('Match ends, Arsenal 1, Hull City 0.'), findsOneWidget);
    expect(
      find.text('Final del partido, Arsenal 1, Hull City 0.'),
      findsNothing,
    );
    expect(find.text('المباراة انتهى, أرسنال 1, هال سيتي 0.'), findsNothing);
    // Whitespace-only minute falls back to 'FT'.
    expect(find.text('FT'), findsOneWidget);
    // English copy is not right-to-left.
    expect(
      tester
          .widgetList<Directionality>(find.byType(Directionality))
          .any((widget) => widget.textDirection == TextDirection.rtl),
      isFalse,
    );
  });

  testWidgets('wraps Arabic rows in a right-to-left directionality', (
    tester,
  ) async {
    final details = PremierLeagueMatchDetails.fromParts(
      match: {},
      commentaryJson: {
        'data': [
          {
            'comment': 'المباراة انتهى, أرسنال 1, هال سيتي 0.',
            'time': "90'+5'",
            'type': 'end 2',
            'timestamp': _ts2,
          },
        ],
      },
    );
    await _pump(tester, details);

    expect(
      tester
          .widgetList<Directionality>(find.byType(Directionality))
          .any((widget) => widget.textDirection == TextDirection.rtl),
      isTrue,
    );
  });

  testWidgets('minutes come from the row time', (tester) async {
    final details = PremierLeagueMatchDetails.fromParts(
      match: {},
      commentaryJson: {
        'data': [
          {
            'comment': 'Foul by Eberechi Eze (Arsenal).',
            'time': "90'+4'",
            'type': 'free kick lost',
            'timestamp': _ts2,
          },
        ],
      },
    );
    await _pump(tester, details);

    expect(find.text("90'+4'"), findsOneWidget);
    expect(find.text('Foul by Eberechi Eze (Arsenal).'), findsOneWidget);
  });

  testWidgets('loads more rows on demand', (tester) async {
    final rows = <Map<String, String>>[];
    for (var i = 0; i < 45; i++) {
      final minute = 59 - i ~/ 2;
      final second = 30 - (i % 2) * 7;
      rows.add({
        'comment': 'Event number $i of the feed.',
        'time': "$minute'",
        'type': 'test',
        'timestamp':
            '2026-11-07 16:$minute:${second.toString().padLeft(2, '0')}',
      });
    }
    final details = PremierLeagueMatchDetails.fromParts(
      match: {},
      commentaryJson: {'data': rows},
    );
    await _pump(tester, details);

    expect(find.text('Show more (25)'), findsOneWidget);
    expect(find.text('Event number 19 of the feed.'), findsOneWidget);
    expect(find.text('Event number 39 of the feed.'), findsNothing);

    await tester.ensureVisible(find.text('Show more (25)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more (25)'));
    await tester.pumpAndSettle();

    expect(find.text('Event number 39 of the feed.'), findsOneWidget);
    expect(find.text('Show more (5)'), findsOneWidget);

    await tester.ensureVisible(find.text('Show more (5)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more (5)'));
    await tester.pumpAndSettle();

    expect(find.text('Event number 44 of the feed.'), findsOneWidget);
    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('shows the empty state without commentary', (tester) async {
    await _pump(tester, PremierLeagueMatchDetails.fromParts(match: {}));

    expect(find.text('Commentary unavailable'), findsOneWidget);
  });
}
