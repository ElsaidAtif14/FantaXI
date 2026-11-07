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
          'score': 0,
          'halfTimeScore': 0,
        },
        'awayTeam': {
          'id': '6',
          'name': 'Tottenham Hotspur',
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
    expect(model.awayTeam?.halfTimeScore, 0);
    expect(model.kickoff?.toUtc(), DateTime.utc(2026, 10, 24, 16, 30));
    expect(model.events.map((event) => event.kind), [
      'card',
      'substitution',
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
}
