import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/lineups_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const homeFormationJson = {
  'formation': '4-2-2',
  'teamId': '47',
  'lineup': [
    ['101'],
    ['102', '103', '104', '105'],
    ['106', '107'],
    ['108'],
  ],
  'subs': ['110', '111'],
};

const homePlayersJson = [
  {
    'id': '101',
    'knownName': 'Aaron Ramsdale',
    'shirtNum': '1',
    'position': 'Goalkeeper',
  },
  {
    'id': '102',
    'knownName': 'Ben White',
    'shirtNum': '2',
    'position': 'Defender',
  },
  {
    'id': '103',
    'knownName': 'William Saliba',
    'shirtNum': '3',
    'position': 'Defender',
  },
  {
    'id': '104',
    'knownName': 'Gabriel Magalhaes',
    'shirtNum': '4',
    'position': 'Defender',
  },
  {
    'id': '105',
    'knownName': 'Oleksandr Zinchenko',
    'shirtNum': '5',
    'position': 'Defender',
  },
  {
    'id': '106',
    'knownName': 'Martin Odegaard',
    'shirtNum': '8',
    'isCaptain': true,
  },
  {'id': '107', 'knownName': 'Declan Rice', 'shirtNum': '6'},
  {'id': '108', 'knownName': 'Gabriel Jesus', 'shirtNum': '9'},
  {
    'id': '110',
    'knownName': 'Theo One',
    'shirtNum': '12',
    'position': 'Substitute',
  },
  {
    'id': '111',
    'knownName': 'Theo Two',
    'shirtNum': '13',
    'position': 'Substitute',
  },
];

const awayPlayersJson = [
  {
    'id': '201',
    'knownName': 'Nick Pope',
    'shirtNum': '1',
    'position': 'Goalkeeper',
  },
  {
    'id': '202',
    'knownName': 'Dan Burn',
    'shirtNum': '2',
    'position': 'Defender',
  },
  {
    'id': '203',
    'knownName': 'Sven Botman',
    'shirtNum': '3',
    'position': 'Defender',
  },
  {
    'id': '204',
    'knownName': 'Kieran Trippier',
    'shirtNum': '4',
    'isCaptain': true,
  },
  {
    'id': '205',
    'knownName': 'Tino Krafth',
    'shirtNum': '5',
    'position': 'Defender',
  },
  {
    'id': '206',
    'knownName': 'Joelinton Silva',
    'shirtNum': '6',
    'position': 'Midfielder',
  },
  {
    'id': '207',
    'knownName': 'Bruno Guimaraes',
    'shirtNum': '7',
    'position': 'Midfielder',
  },
  {
    'id': '208',
    'knownName': 'Joe Willock',
    'shirtNum': '8',
    'position': 'Midfielder',
  },
  {
    'id': '209',
    'knownName': 'Alexander Isak',
    'shirtNum': '9',
    'position': 'Forward',
  },
  {
    'id': '210',
    'knownName': 'Callum Wilson',
    'shirtNum': '10',
    'position': 'Forward',
  },
  {
    'id': '220',
    'knownName': 'Sub Bench',
    'shirtNum': '20',
    'position': 'Substitute',
  },
];

PremierLeagueMatchDetails _details() => PremierLeagueMatchDetails.fromParts(
  match: {},
  lineupsJson: {
    'home_team': {
      'teamId': '47',
      'players': homePlayersJson,
      'formation': homeFormationJson,
      'managers': [
        {'knownName': 'Mikel Arteta'},
        {'knownName': 'Vera Pauw'},
      ],
    },
    'away_team': {'players': awayPlayersJson, 'formation': '5-3-2'},
  },
);

Future<void> _pump(
  WidgetTester tester,
  PremierLeagueMatchDetails details, {
  Size size = const Size(800, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LineupsView(details: details, homeTeam: null, awayTeam: null),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the selected team from real formation IDs', (
    tester,
  ) async {
    await _pump(tester, _details());

    // Home is shown first, from formationRows row 1 = goalkeeper.
    expect(find.text('H · 4-2-2'), findsOneWidget);
    expect(find.text('Ramsdale'), findsOneWidget);
    expect(find.text('Odegaard'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    // The other team's players never leak onto this pitch.
    expect(find.text('Pope'), findsNothing);
    expect(find.text('Isak'), findsNothing);
    // Substitutes resolve through substituteIds.
    expect(find.text('Theo One'), findsOneWidget);
    expect(find.text('Theo Two'), findsOneWidget);
    // Managers are listed.
    expect(find.text('Mikel Arteta, Vera Pauw'), findsOneWidget);
  });

  testWidgets('formation rows are ordered goalkeeper to attack', (
    tester,
  ) async {
    await _pump(tester, _details());

    final gkCenter = tester.getCenter(find.text('Ramsdale'));
    final forwardCenter = tester.getCenter(find.text('Jesus'));
    final midCenter = tester.getCenter(find.text('Rice'));
    expect(gkCenter.dy, lessThan(midCenter.dy));
    expect(midCenter.dy, lessThan(forwardCenter.dy));
  });

  testWidgets(
    'falls back to position grouping when formation rows are absent',
    (tester) async {
      await _pump(tester, _details());

      await tester.tap(find.text('AWAY · A'));
      await tester.pumpAndSettle();

      expect(find.text('A · Positions'), findsOneWidget);
      expect(find.text('formation unavailable'), findsOneWidget);
      // Grouped by position rather than by formation row.
      expect(find.text('Pope'), findsOneWidget);
      expect(find.text('Burn'), findsOneWidget);
      expect(find.text('Guimaraes'), findsOneWidget);
      expect(find.text('Isak'), findsOneWidget);
      expect(find.text('Wilson'), findsOneWidget);
      // Home players cannot leak onto the away pitch.
      expect(find.text('Ramsdale'), findsNothing);
      expect(find.text('Odegaard'), findsNothing);
      // Substitutes fall back to the position-marked substitutes.
      expect(find.text('Sub Bench'), findsOneWidget);
    },
  );

  testWidgets('shows an honest empty state when one side is missing', (
    tester,
  ) async {
    final details = PremierLeagueMatchDetails.fromParts(
      match: {},
      lineupsJson: {
        'home_team': {
          'teamId': '47',
          'players': homePlayersJson,
          'formation': homeFormationJson,
        },
      },
    );
    await _pump(tester, details);

    // Home renders normally.
    expect(find.text('Ramsdale'), findsOneWidget);
    // Switching to the missing away side shows its own empty state.
    await tester.tap(find.text('AWAY · A'));
    await tester.pumpAndSettle();
    expect(find.text('AWAY lineup unavailable'), findsOneWidget);
  });

  testWidgets('shows the full empty state without lineups', (tester) async {
    await _pump(tester, PremierLeagueMatchDetails.fromParts(match: {}));

    expect(find.text('Lineups unavailable'), findsOneWidget);
  });

  testWidgets('does not overflow at 320dp', (tester) async {
    await _pump(tester, _details(), size: const Size(320, 1400));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('AWAY · A'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
