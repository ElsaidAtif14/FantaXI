class FixtureModel {
  const FixtureModel({
    required this.id,
    required this.gameweek,
    required this.kickoffTime,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeScore,
    required this.awayScore,
    required this.started,
    required this.finished,
    required this.finishedProvisional,
    required this.minutes,
    this.code,
  });

  final int id;
  final int? gameweek;
  final DateTime? kickoffTime;
  final int? homeTeamId;
  final int? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final bool? started;
  final bool? finished;
  final bool? finishedProvisional;
  final int? minutes;

  /// FPL's cross-reference code. This is not the FPL fixture [id].
  final int? code;

  /// Whether the match is over.
  ///
  /// FPL keeps [finished] false until bonus points are confirmed, while
  /// [finishedProvisional] flips as soon as the final whistle goes, so both
  /// flags must be considered before treating a fixture as still live.
  bool get isFinished => finished == true || finishedProvisional == true;

  bool get isLive => started == true && !isFinished;

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      id: _intValue(json['id']) ?? 0,
      gameweek: _intValue(json['event']),
      kickoffTime: DateTime.tryParse(json['kickoff_time']?.toString() ?? ''),
      homeTeamId: _intValue(json['team_h']),
      awayTeamId: _intValue(json['team_a']),
      homeScore: _intValue(json['team_h_score']),
      awayScore: _intValue(json['team_a_score']),
      started: json['started'] is bool ? json['started'] as bool : null,
      finished: json['finished'] is bool ? json['finished'] as bool : null,
      finishedProvisional:
          json['finished_provisional'] is bool
              ? json['finished_provisional'] as bool
              : null,
      minutes: _intValue(json['minutes']),
      code: _intValue(json['code']),
    );
  }

  static int? _intValue(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  factory FixtureModel.dummy({int? gameweek, int id = 0}) {
    return FixtureModel(
      id: id,
      gameweek: gameweek,
      kickoffTime: DateTime(2026, 1, 1, 15),
      homeTeamId: null,
      awayTeamId: null,
      homeScore: null,
      awayScore: null,
      started: false,
      finished: false,
      finishedProvisional: false,
      minutes: null,
      code: null,
    );
  }
}
