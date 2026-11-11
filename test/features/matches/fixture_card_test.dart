import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/fixture_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _homeTeam = TeamModel(id: 1, name: 'Arsenal', shortName: 'ARS', code: '');
final _awayTeam = TeamModel(id: 2, name: 'Chelsea', shortName: 'CHE', code: '');

void main() {
  testWidgets('shows full time for a provisionally finished fixture', (
    tester,
  ) async {
    await _pump(
      tester,
      _fixture(
        started: true,
        finished: false,
        finishedProvisional: true,
        minutes: 90,
        homeScore: 3,
        awayScore: 1,
      ),
    );

    expect(find.text('FULL TIME'), findsOneWidget);
    expect(find.textContaining('LIVE'), findsNothing);
    expect(find.textContaining('90'), findsNothing);
  });

  testWidgets('treats a confirmed finished fixture as full time', (
    tester,
  ) async {
    await _pump(
      tester,
      _fixture(started: true, finished: true, minutes: 90, homeScore: 1),
    );

    expect(find.text('FULL TIME'), findsOneWidget);
    expect(find.textContaining('LIVE'), findsNothing);
  });

  testWidgets('shows the live minute for an active fixture', (tester) async {
    await _pump(tester, _fixture(started: true, minutes: 55));

    expect(find.text("LIVE · 55'"), findsOneWidget);
    expect(find.text('FULL TIME'), findsNothing);
  });

  testWidgets('shows stoppage time as 90+ while live', (tester) async {
    await _pump(tester, _fixture(started: true, minutes: 90));

    expect(find.text("LIVE · 90+'"), findsOneWidget);
    expect(find.text('FULL TIME'), findsNothing);
  });

  testWidgets('shows upcoming and kick off for a scheduled fixture', (
    tester,
  ) async {
    await _pump(tester, _fixture());

    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.text('KICK OFF'), findsOneWidget);
    expect(find.textContaining('LIVE'), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, FixtureModel fixture) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FixtureCard(
          fixture: fixture,
          homeTeam: _homeTeam,
          awayTeam: _awayTeam,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

FixtureModel _fixture({
  bool started = false,
  bool finished = false,
  bool finishedProvisional = false,
  int minutes = 0,
  int? homeScore,
  int? awayScore,
}) => FixtureModel(
  id: 94,
  gameweek: 10,
  kickoffTime: DateTime(2026, 11, 7, 15),
  homeTeamId: 1,
  awayTeamId: 2,
  homeScore: homeScore,
  awayScore: awayScore,
  started: started,
  finished: finished,
  finishedProvisional: finishedProvisional,
  minutes: minutes,
);
