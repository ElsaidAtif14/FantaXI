typedef JsonMap = Map<String, dynamic>;

class PremierLeagueMatchDetails {
  const PremierLeagueMatchDetails({
    this.matchId,
    this.competition,
    this.seasonId,
    this.matchweek,
    this.kickoff,
    this.status,
    this.homeTeam,
    this.awayTeam,
    this.stadium,
    this.attendance,
    this.referee,
    this.events = const [],
    this.statistics = const {},
    this.homeLineup,
    this.awayLineup,
    this.commentary = const [],
    this.failedSections = const {},
  });

  final int? matchId;
  final String? competition;
  final int? seasonId;
  final int? matchweek;
  final DateTime? kickoff;
  final String? status;
  final MatchTeamDetail? homeTeam;
  final MatchTeamDetail? awayTeam;
  final String? stadium;
  final int? attendance;
  final String? referee;
  final List<MatchEvent> events;
  final Map<String, Map<String, num>> statistics;
  final MatchLineup? homeLineup;
  final MatchLineup? awayLineup;
  final List<MatchCommentary> commentary;
  final Set<String> failedSections;

  factory PremierLeagueMatchDetails.fromParts({
    JsonMap? match,
    JsonMap? eventsJson,
    dynamic statsJson,
    JsonMap? lineupsJson,
    JsonMap? officialsJson,
    JsonMap? commentaryJson,
    Set<String> failedSections = const {},
  }) {
    final home = _map(match?['homeTeam']);
    final away = _map(match?['awayTeam']);
    final season = _map(match?['seasonInfo']);
    final officialRows = officialsJson?['matchOfficials'];
    String? referee;
    if (officialRows is List) {
      for (final row in officialRows) {
        final item = _map(row);
        if (item?['type']?.toString().toLowerCase() == 'referee') {
          referee = _string(_map(item?['official'])?['name']);
          break;
        }
      }
    }
    return PremierLeagueMatchDetails(
      matchId: _int(match?['matchId']),
      competition: _string(match?['competition']),
      seasonId: _int(season?['id'] ?? match?['seasonId']),
      matchweek: _int(match?['matchWeek']),
      kickoff: _parseKickoff(match),
      status: _string(match?['period']),
      homeTeam: home == null ? null : MatchTeamDetail.fromJson(home),
      awayTeam: away == null ? null : MatchTeamDetail.fromJson(away),
      stadium: _string(match?['ground']),
      attendance: _int(match?['attendance']),
      referee: referee,
      events: _parseEvents(eventsJson),
      statistics: _parseStats(statsJson),
      homeLineup: _parseLineup(_map(lineupsJson?['home_team'])),
      awayLineup: _parseLineup(_map(lineupsJson?['away_team'])),
      commentary: _parseCommentary(commentaryJson),
      failedSections: failedSections,
    );
  }
}

class MatchTeamDetail {
  const MatchTeamDetail({
    this.id,
    this.name,
    this.shortName,
    this.score,
    this.halfTimeScore,
  });
  final int? id;

  /// Official club name, e.g. `Tottenham Hotspur`.
  final String? name;

  /// Short club name, e.g. `Spurs` or `Man Utd`. FPL's `team.name` uses these
  /// short forms, so they are part of the match validation.
  final String? shortName;
  final int? score;
  final int? halfTimeScore;

  factory MatchTeamDetail.fromJson(JsonMap json) => MatchTeamDetail(
    id: _int(json['id']),
    name: _string(json['name']),
    shortName: _string(json['shortName']),
    score: _int(json['score']),
    halfTimeScore: _int(json['halfTimeScore']),
  );
}

class MatchEvent {
  const MatchEvent({
    required this.kind,
    required this.minute,
    this.period,
    this.playerId,
    this.assistPlayerId,
    this.playerOnId,
    this.playerOffId,
    this.cardType,
    this.goalType,
    this.teamId,
  });
  final String kind;
  final int? minute;
  final String? period;
  final int? playerId;
  final int? assistPlayerId;
  final int? playerOnId;
  final int? playerOffId;
  final String? cardType;
  final String? goalType;
  final int? teamId;
}

class MatchPlayer {
  const MatchPlayer({
    this.id,
    this.name,
    this.number,
    this.position,
    this.subPosition,
    this.captain = false,
  });
  final int? id;
  final String? name;
  final int? number;
  final String? position;
  final String? subPosition;
  final bool captain;

  factory MatchPlayer.fromJson(JsonMap json) => MatchPlayer(
    id: _int(json['id']),
    name:
        _string(json['knownName']) ??
        [
          _string(json['firstName']),
          _string(json['lastName']),
        ].whereType<String>().where((s) => s.isNotEmpty).join(' '),
    number: _int(json['shirtNum']),
    position: _string(json['position']),
    subPosition: _string(json['subPosition']),
    captain: json['isCaptain'] == true,
  );
}

class MatchLineup {
  const MatchLineup({
    this.players = const [],
    this.formation,
    this.formationRows = const [],
    this.substituteIds = const [],
    this.teamId,
    this.managers = const [],
  });
  final List<MatchPlayer> players;

  /// Human formation such as `4-2-3-1`.
  final String? formation;

  /// Player-ID rows from the nested formation object, ordered goalkeeper to
  /// attack. Empty when the API only provides a legacy string formation.
  final List<List<int>> formationRows;
  final List<int> substituteIds;
  final int? teamId;
  final List<MatchManager> managers;

  factory MatchLineup.fromJson(JsonMap json) {
    final players = json['players'];
    final teamId = _int(json['teamId']);
    final formationRaw = json['formation'];
    String? formationName;
    List<List<int>> rows = const [];
    List<int> subs = const [];
    int? nestedTeamId;
    if (formationRaw is Map) {
      final formation = Map<String, dynamic>.from(formationRaw);
      formationName = _string(formation['formation']);
      rows = _idRowList(formation['lineup']);
      subs = _idList(formation['subs']);
      nestedTeamId = _int(formation['teamId']);
    } else if (formationRaw is String) {
      // Legacy shape: a bare formation string.
      formationName = _string(formationRaw);
    }
    final managers = json['managers'];
    return MatchLineup(
      formation: formationName,
      formationRows: rows,
      substituteIds: subs,
      teamId: teamId ?? nestedTeamId,
      managers:
          managers is List
              ? managers
                  .whereType<Map>()
                  .map(
                    (e) => MatchManager.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : const [],
      players:
          players is List
              ? players
                  .whereType<Map>()
                  .map(
                    (e) => MatchPlayer.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : const [],
    );
  }

  List<MatchPlayer> get starters =>
      players
          .where((player) => player.position?.toLowerCase() != 'substitute')
          .toList();
  List<MatchPlayer> get substitutes =>
      players
          .where((player) => player.position?.toLowerCase() == 'substitute')
          .toList();

  MatchPlayer? playerById(int? id) =>
      id == null
          ? null
          : players.where((player) => player.id == id).firstOrNull;
}

class MatchManager {
  const MatchManager({this.id, this.name, this.type});
  final int? id;
  final String? name;
  final String? type;

  factory MatchManager.fromJson(JsonMap json) => MatchManager(
    id: _int(json['id']),
    name:
        _string(json['knownName']) ??
        [
          _string(json['firstName']),
          _string(json['lastName']),
        ].whereType<String>().where((s) => s.isNotEmpty).join(' '),
    type: _string(json['type']),
  );
}

List<List<int>> _idRowList(dynamic raw) {
  if (raw is! List) return const [];
  final rows = <List<int>>[];
  for (final row in raw.whereType<List>()) {
    final ids = _idList(row);
    // A row without resolvable IDs is kept empty so players are not shifted
    // into the wrong formation line.
    rows.add(ids);
  }
  return rows;
}

List<int> _idList(dynamic raw) {
  if (raw is! List) return const [];
  final ids = <int>[];
  for (final value in raw) {
    final id = _int(value);
    if (id != null) ids.add(id);
  }
  return ids;
}

class MatchCommentary {
  const MatchCommentary({this.text, this.time, this.type, this.timestamp});
  final String? text;
  final String? time;
  final String? type;
  final DateTime? timestamp;
}

List<MatchEvent> _parseEvents(JsonMap? json) {
  if (json == null) return const [];
  final result = <MatchEvent>[];
  for (final side in ['homeTeam', 'awayTeam']) {
    final team = _map(json[side]);
    if (team == null) continue;
    final teamId = _int(team['id']);
    for (final entry in [
      ('goals', 'goal'),
      ('cards', 'card'),
      ('subs', 'substitution'),
    ]) {
      final rows = team[entry.$1];
      if (rows is List) {
        for (final raw in rows.whereType<Map>()) {
          final row = Map<String, dynamic>.from(raw);
          result.add(
            MatchEvent(
              kind: entry.$2,
              minute: _int(row['time']),
              period: _string(row['period']),
              playerId: _int(row['playerId']),
              assistPlayerId: _int(row['assistPlayerId']),
              playerOnId: _int(row['playerOnId']),
              playerOffId: _int(row['playerOffId']),
              cardType: _string(row['type']),
              goalType: _string(row['goalType']),
              teamId: teamId,
            ),
          );
        }
      }
    }
  }
  result.sort((a, b) => (a.minute ?? 999).compareTo(b.minute ?? 999));
  return result;
}

Map<String, Map<String, num>> _parseStats(dynamic raw) {
  if (raw is! List) return const {};
  final output = <String, Map<String, num>>{};
  for (final row in raw.whereType<Map>()) {
    final side = _string(row['side']);
    final stats = _map(row['stats']);
    if (side == null || stats == null) continue;
    output[side.toLowerCase()] = {
      for (final entry in stats.entries)
        if (entry.value is num) entry.key: entry.value as num,
    };
  }
  return output;
}

MatchLineup? _parseLineup(JsonMap? json) =>
    json == null ? null : MatchLineup.fromJson(json);

List<MatchCommentary> _parseCommentary(JsonMap? json) {
  final rows = json?['data'];
  if (rows is! List) return const [];
  return rows
      .whereType<Map>()
      .take(120) // Enough for a full match page; keeps payload parsing bounded.
      .map((raw) {
        final row = Map<String, dynamic>.from(raw);
        return MatchCommentary(
          text: _string(row['comment']),
          time: _string(row['time']),
          type: _string(row['type']),
          timestamp: DateTime.tryParse(row['timestamp']?.toString() ?? ''),
        );
      })
      .toList();
}

JsonMap? _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
String? _string(dynamic value) =>
    value == null || value.toString().trim().isEmpty ? null : value.toString();
int? _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

DateTime? _parseKickoff(JsonMap? match) {
  final parsed = DateTime.tryParse(match?['kickoff']?.toString() ?? '');
  if (parsed == null) return null;
  if (parsed.isUtc) return parsed;
  // The API sends a wall-clock time without an offset, so it must not inherit
  // the device's timezone; rebuild it as UTC before applying the zone label.
  final wallClock = DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
  final zone = match?['kickoffTimezone']?.toString().toUpperCase();
  if (zone == 'BST') return wallClock.subtract(const Duration(hours: 1));
  return wallClock;
}
