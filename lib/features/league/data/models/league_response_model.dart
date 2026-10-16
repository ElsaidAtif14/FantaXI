class LeagueDetails {
  final int id;
  final String name;
  final String? created;
  final int? adminEntry;
  final bool? hasCup;

  LeagueDetails({
    required this.id,
    required this.name,
    this.created,
    this.adminEntry,
    this.hasCup,
  });

  factory LeagueDetails.fromJson(Map<String, dynamic> json) {
    return LeagueDetails(
      id: json['id'],
      name: json['name'] ?? 'Unknown League',
      created: json['created'],
      adminEntry: json['admin_entry'],
      hasCup: json['has_cup'],
    );
  }
}

class LeagueStanding {
  final int id;
  final int entryId;
  final String playerName;
  final String teamName;
  final int rank;
  final int lastRank;
  final int eventTotal;
  final int totalPoints;

  LeagueStanding({
    required this.id,
    required this.entryId,
    required this.playerName,
    required this.teamName,
    required this.rank,
    required this.lastRank,
    required this.eventTotal,
    required this.totalPoints,
  });

  factory LeagueStanding.fromJson(Map<String, dynamic> json) {
    return LeagueStanding(
      id: json['id'] ?? json['entry'],
      entryId: json['entry'],
      playerName: json['player_name'] ?? 'Unknown',
      teamName: json['entry_name'] ?? 'Unknown Team',
      rank: json['rank'] ?? 0,
      lastRank: json['last_rank'] ?? 0,
      eventTotal: json['event_total'] ?? 0,
      totalPoints: json['total'] ?? 0,
    );
  }

  factory LeagueStanding.dummy(int position) {
    return LeagueStanding(
      id: 0,
      entryId: 0,
      playerName: 'Loading Player...',
      teamName: 'Loading Team...',
      rank: position,
      lastRank: position,
      eventTotal: 50,
      totalPoints: 1000 - position,
    );
  }

  int get movement {
    if (lastRank == 0) return 1; // new player — treat as moved up
    return lastRank - rank;
  }
}

class LeagueResponseModel {
  final LeagueDetails league;
  final List<LeagueStanding> standings;
  final String lastUpdated;
  final bool hasNextPage;

  LeagueResponseModel({
    required this.league,
    required this.standings,
    required this.lastUpdated,
    required this.hasNextPage,
  });

  factory LeagueResponseModel.fromJson(Map<String, dynamic> json) {
    return LeagueResponseModel(
      league: LeagueDetails.fromJson(json['league']),
      standings: (json['standings']['results'] as List)
          .map((item) => LeagueStanding.fromJson(item))
          .toList(),
      lastUpdated: json['last_updated_data'] ?? '',
      hasNextPage: json['standings']['has_next'] ?? false,
    );
  }
}
