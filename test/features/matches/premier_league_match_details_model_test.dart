import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses goals, own goals, cards, substitutions and detail sections', () {
    final model = PremierLeagueMatchDetails.fromParts(
      match: {
        'matchId': '2645267',
        'competition': 'Premier League',
        'seasonInfo': {'id': '2026'},
        'matchWeek': 8,
        'kickoff': '2026-10-24 17:30:00',
        'kickoffTimezone': 'BST',
        'period': 'FullTime',
        'ground': 'Stamford Bridge',
        'attendance': 10,
        'homeTeam': {
          'id': '8',
          'name': 'Chelsea',
          'shortName': 'Chelsea',
          'score': 0,
          'halfTimeScore': 0,
        },
        'awayTeam': {
          'id': '6',
          'name': 'Tottenham Hotspur',
          'shortName': 'Spurs',
          'score': 2,
          'halfTimeScore': 0,
        },
      },
      eventsJson: {
        'homeTeam': {'id': '8', 'goals': [], 'cards': [], 'subs': []},
        'awayTeam': {
          'id': '6',
          'goals': [
            {
              'time': '77',
              'playerId': '9',
              'goalType': 'Own',
              'period': 'SecondHalf',
            },
          ],
          'cards': [
            {'time': '67', 'playerId': '4', 'type': 'Yellow'},
          ],
          'subs': [
            {'time': '51', 'playerOnId': '10', 'playerOffId': '11'},
          ],
        },
      },
      statsJson: [
        {
          'side': 'Home',
          'stats': {'totalScoringAtt': 8, 'ignored': 'x'},
        },
      ],
      lineupsJson: {
        'home_team': {
          'formation': '4-3-3',
          'players': [
            {
              'id': '9',
              'firstName': 'A',
              'lastName': 'Player',
              'shirtNum': '10',
            },
            {
              'id': '12',
              'firstName': 'Bench',
              'lastName': 'Player',
              'position': 'Substitute',
              'subPosition': 'Forward',
            },
          ],
        },
      },
      officialsJson: {
        'matchOfficials': [
          {
            'type': 'Referee',
            'official': {'name': 'Official'},
          },
        ],
      },
      commentaryJson: {
        'data': [
          {
            'comment': 'Full time',
            'time': '90',
            'timestamp': '2026-10-24T19:24:32Z',
          },
        ],
      },
    );

    expect(model.homeTeam?.score, 0);
    expect(model.homeTeam?.shortName, 'Chelsea');
    expect(model.awayTeam?.shortName, 'Spurs');
    expect(model.awayTeam?.halfTimeScore, 0);
    expect(model.kickoff?.toUtc(), DateTime.utc(2026, 10, 24, 16, 30));
    expect(model.events.map((event) => event.kind), [
      'substitution',
      'card',
      'goal',
    ]);
    expect(model.events.last.goalType, 'Own');
    expect(model.statistics['home']?['totalScoringAtt'], 8);
    expect(model.homeLineup?.starters.single.name, 'A Player');
    expect(model.homeLineup?.formation, '4-3-3');
    expect(model.homeLineup?.substitutes.single.subPosition, 'Forward');
    expect(model.referee, 'Official');
    expect(model.commentary.single.text, 'Full time');
  });

  test('tolerates missing or malformed optional fields', () {
    final model = PremierLeagueMatchDetails.fromParts(
      match: {'unexpected': true},
      eventsJson: {'homeTeam': 'invalid'},
      statsJson: {'unexpected': true},
      lineupsJson: {
        'home_team': {'players': 'bad'},
      },
      officialsJson: {},
      commentaryJson: {},
    );
    expect(model.matchId, isNull);
    expect(model.events, isEmpty);
    expect(model.statistics, isEmpty);
    expect(model.homeLineup?.players, isEmpty);
    expect(model.referee, isNull);
    expect(model.commentary, isEmpty);
  });

  test('caps commentary parsing at 120 raw rows', () {
    final rows = [
      for (var i = 0; i < 150; i++)
        {
          'comment': 'Row $i',
          'time': '$i',
          'type': 'test',
          'timestamp':
              '2026-11-07 16:${(59 - i ~/ 2).toString().padLeft(2, '0')}:'
              '${(30 - (i % 2) * 7).toString().padLeft(2, '0')}',
        },
    ];
    final model = PremierLeagueMatchDetails.fromParts(
      match: {},
      commentaryJson: {'data': rows},
    );
    expect(model.commentary, hasLength(120));
    expect(model.commentary.first.text, 'Row 0');
    expect(model.commentary.last.text, 'Row 119');
  });

  group('lineup formation mapping', () {
    const nestedFormation = {
      'formation': '4-2-3-1',
      'teamId': '3',
      'lineup': [
        ['154561'],
        ['445122', '199798', '226597', '466075'],
        ['208706', '204480'],
        ['248857', '184029', '439509'],
        ['219847'],
      ],
      'subs': ['109745', '500040'],
    };

    test(
      'parses the nested formation object into name, rows and substitutes',
      () {
        final lineup = _homeLineup({'formation': nestedFormation}).homeLineup;
        expect(lineup?.formation, '4-2-3-1');
        expect(lineup?.teamId, 3);
        expect(lineup?.formationRows, [
          [154561],
          [445122, 199798, 226597, 466075],
          [208706, 204480],
          [248857, 184029, 439509],
          [219847],
        ]);
        expect(lineup?.substituteIds, [109745, 500040]);
        expect(lineup?.playerById(154561)?.name, 'A Player');
        expect(lineup?.managers.single.name, 'Mikel Arteta');
      },
    );

    test('keeps the legacy bare-string formation shape working', () {
      final lineup = _homeLineup({'formation': '4-3-3'}).homeLineup;
      expect(lineup?.formation, '4-3-3');
      expect(lineup?.formationRows, isEmpty);
      expect(lineup?.substituteIds, isEmpty);
    });

    test('handles a missing formation', () {
      final lineup = _homeLineup({}).homeLineup;
      expect(lineup?.formation, isNull);
      expect(lineup?.formationRows, isEmpty);
    });

    test('handles a malformed formation value', () {
      final lineup = _homeLineup({'formation': 42}).homeLineup;
      expect(lineup?.formation, isNull);
      expect(lineup?.formationRows, isEmpty);
    });

    test('handles malformed lineup rows and substitutes', () {
      final lineup =
          _homeLineup({
            'formation': {
              'formation': '3-4-3',
              'lineup': 'bad',
              'subs': {'unexpected': true},
            },
          }).homeLineup;
      expect(lineup?.formation, '3-4-3');
      expect(lineup?.formationRows, isEmpty);
      expect(lineup?.substituteIds, isEmpty);
    });

    test('skips unparseable ids but keeps the row structure', () {
      final lineup =
          _homeLineup({
            'formation': {
              'formation': '4-4-2',
              'lineup': [
                ['x'],
                ['21'],
              ],
            },
          }).homeLineup;
      expect(lineup?.formationRows, [
        <int>[],
        [21],
      ]);
    });

    test('falls back to the top-level team id', () {
      final lineup =
          _homeLineup({
            'teamId': '88',
            'formation': {'formation': '5-3-2'},
          }).homeLineup;
      expect(lineup?.teamId, 88);
    });

    test('handles a missing manager list', () {
      final details = PremierLeagueMatchDetails.fromParts(
        match: {},
        lineupsJson: {
          'home_team': {
            'players': [
              {'id': '1', 'firstName': 'A', 'lastName': 'Player'},
            ],
          },
        },
      );
      expect(details.homeLineup?.managers, isEmpty);
    });
  });
}

PremierLeagueMatchDetails _homeLineup(Map<String, dynamic> homeTeamJson) =>
    PremierLeagueMatchDetails.fromParts(
      match: {},
      lineupsJson: {
        'home_team': {
          'teamId': '3',
          'players': [
            {'id': '154561', 'firstName': 'A', 'lastName': 'Player'},
          ],
          'managers': [
            {'id': '51018', 'firstName': 'Mikel', 'lastName': 'Arteta'},
          ],
          ...homeTeamJson,
        },
      },
    );
