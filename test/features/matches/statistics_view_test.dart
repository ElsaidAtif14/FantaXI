import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders headline stats with formatted values', (tester) async {
    await _pump(tester, _details());

    expect(find.text('Possession'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('1.26'), findsOneWidget);
    expect(find.text('0.36'), findsOneWidget);
    expect(find.text('Total shots'), findsOneWidget);
  });

  testWidgets('groups remaining statistics into collapsible sections', (
    tester,
  ) async {
    await _pump(tester, _details());

    expect(find.text('MATCH FLOW'), findsOneWidget);
    // Match flow starts expanded.
    expect(find.text('Accurate passes'), findsOneWidget);
    expect(find.text('508'), findsOneWidget);
    await tester.tap(find.text('MATCH FLOW'));
    await tester.pumpAndSettle();
    final collapsed = tester.widget<AnimatedCrossFade>(
      find.byType(AnimatedCrossFade).first,
    );
    expect(collapsed.crossFadeState, CrossFadeState.showFirst);
  });

  testWidgets('show all toggles reveal every statistic', (tester) async {
    tester.view.physicalSize = const Size(390, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pump(tester, _details());

    expect(find.text('Show all statistics'), findsOneWidget);
    await tester.tap(find.text('Show all statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Show fewer statistics'), findsOneWidget);
    // Match flow and the unknown-key group stay (or become) expanded.
    expect(find.byType(AnimatedCrossFade), findsNWidgets(2));
  });

  testWidgets('unknown API keys stay visible under other statistics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pump(tester, _details());

    expect(find.text('OTHER STATISTICS'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade).last)
          .crossFadeState,
      CrossFadeState.showFirst,
    );
    await tester.tap(find.text('Show all statistics'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade).last)
          .crossFadeState,
      CrossFadeState.showSecond,
    );
  });

  testWidgets('shows an unavailable state without statistics data', (
    tester,
  ) async {
    final details = PremierLeagueMatchDetails.fromParts(match: {});
    await _pump(tester, details);
    expect(find.text('Stats unavailable'), findsOneWidget);
  });
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Future<void> _pump(WidgetTester tester, PremierLeagueMatchDetails details) =>
    tester.pumpWidget(
      _wrap(StatisticsView(details: details, homeTeam: null, awayTeam: null)),
    );

PremierLeagueMatchDetails _details() => PremierLeagueMatchDetails.fromParts(
  match: {},
  statsJson: [
    {
      'side': 'Home',
      'stats': {
        'possessionPercentage': 67.1,
        'expectedGoals': 1.2644,
        'totalScoringAtt': 21.0,
        'ontargetScoringAtt': 10.0,
        'totalPass': 590.0,
        'accuratePass': 508.0,
        'brandNewMetric': 2.0,
      },
    },
    {
      'side': 'Away',
      'stats': {
        'possessionPercentage': 32.9,
        'expectedGoals': 0.3624,
        'totalScoringAtt': 7.0,
        'ontargetScoringAtt': 2.0,
        'totalPass': 279.0,
      },
    },
  ],
);
