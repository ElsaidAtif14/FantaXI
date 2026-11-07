import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses current and next matchweek markers from bootstrap data', () {
    final bootstrap = BootstrapModel.fromJson({
      'elements': [],
      'teams': [],
      'events': [
        {'id': 7, 'is_current': true, 'is_next': false},
        {'id': 8, 'is_current': false, 'is_next': true},
      ],
    });

    expect(bootstrap.gameweeks.first.id, 7);
    expect(bootstrap.gameweeks.first.isCurrent, isTrue);
    expect(bootstrap.gameweeks.last.id, 8);
    expect(bootstrap.gameweeks.last.isNext, isTrue);
  });

  test('parses fixture fields and nullable scores', () {
    final fixture = FixtureModel.fromJson({
      'id': 42,
      'event': 7,
      'kickoff_time': '2026-10-20T18:00:00Z',
      'team_h': 1,
      'team_a': 2,
      'team_h_score': null,
      'team_a_score': null,
      'started': false,
      'finished': false,
      'finished_provisional': false,
      'minutes': 0,
    });

    expect(fixture.id, 42);
    expect(fixture.gameweek, 7);
    expect(fixture.kickoffTime, DateTime.parse('2026-10-20T18:00:00Z'));
    expect(fixture.homeTeamId, 1);
    expect(fixture.awayTeamId, 2);
    expect(fixture.homeScore, isNull);
    expect(fixture.awayScore, isNull);
    expect(fixture.started, isFalse);
    expect(fixture.finished, isFalse);
    expect(fixture.minutes, 0);
  });

  test('tolerates absent and malformed optional values', () {
    final fixture = FixtureModel.fromJson({'id': '9'});

    expect(fixture.id, 9);
    expect(fixture.gameweek, isNull);
    expect(fixture.kickoffTime, isNull);
    expect(fixture.homeTeamId, isNull);
    expect(fixture.awayTeamId, isNull);
    expect(fixture.homeScore, isNull);
    expect(fixture.awayScore, isNull);
    expect(fixture.started, isNull);
    expect(fixture.finished, isNull);
    expect(fixture.minutes, isNull);
  });

  test('preserves FPL code separately from fixture ID', () {
    final fixture = FixtureModel.fromJson({'id': 73, 'code': 2645267});
    expect(fixture.id, 73);
    expect(fixture.code, 2645267);
  });
}
