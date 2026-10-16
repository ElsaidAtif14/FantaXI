class LiveStats {
  final int minutes;
  final int goalsScored;
  final int assists;
  final int cleanSheets;
  final int goalsConceded;
  final int ownGoals;
  final int penaltiesSaved;
  final int penaltiesMissed;
  final int yellowCards;
  final int redCards;
  final int saves;
  final int bonus;
  final int bps;
  final int totalPoints;

  LiveStats({
    required this.minutes,
    required this.goalsScored,
    required this.assists,
    required this.cleanSheets,
    required this.goalsConceded,
    required this.ownGoals,
    required this.penaltiesSaved,
    required this.penaltiesMissed,
    required this.yellowCards,
    required this.redCards,
    required this.saves,
    required this.bonus,
    required this.bps,
    required this.totalPoints,
  });

  factory LiveStats.fromJson(Map<String, dynamic> json) {
    return LiveStats(
      minutes: json['minutes'] ?? 0,
      goalsScored: json['goals_scored'] ?? 0,
      assists: json['assists'] ?? 0,
      cleanSheets: json['clean_sheets'] ?? 0,
      goalsConceded: json['goals_conceded'] ?? 0,
      ownGoals: json['own_goals'] ?? 0,
      penaltiesSaved: json['penalties_saved'] ?? 0,
      penaltiesMissed: json['penalties_missed'] ?? 0,
      yellowCards: json['yellow_cards'] ?? 0,
      redCards: json['red_cards'] ?? 0,
      saves: json['saves'] ?? 0,
      bonus: json['bonus'] ?? 0,
      bps: json['bps'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
    );
  }

  factory LiveStats.dummy() {
    return LiveStats(
      minutes: 90,
      goalsScored: 1,
      assists: 0,
      cleanSheets: 0,
      goalsConceded: 1,
      ownGoals: 0,
      penaltiesSaved: 0,
      penaltiesMissed: 0,
      yellowCards: 0,
      redCards: 0,
      saves: 0,
      bonus: 3,
      bps: 30,
      totalPoints: 10,
    );
  }
}

class ElementLiveModel {
  final int id;
  final LiveStats stats;

  ElementLiveModel({required this.id, required this.stats});

  factory ElementLiveModel.fromJson(Map<String, dynamic> json) {
    return ElementLiveModel(
      id: json['id'],
      stats: LiveStats.fromJson(json['stats']),
    );
  }

  factory ElementLiveModel.dummy() {
    return ElementLiveModel(
      id: 0,
      stats: LiveStats.dummy(),
    );
  }
}

class LiveGWModel {
  final Map<int, ElementLiveModel> liveDataMap;

  LiveGWModel({required this.liveDataMap});

  factory LiveGWModel.fromJson(Map<String, dynamic> json) {
    final elements = json['elements'] as List;
    final map = {
      for (var item in elements)
        item['id'] as int: ElementLiveModel.fromJson(item)
    };
    return LiveGWModel(liveDataMap: map);
  }

  factory LiveGWModel.dummy() {
    return LiveGWModel(
      liveDataMap: {0: ElementLiveModel.dummy()},
    );
  }

  ElementLiveModel? getPlayer(int id) => liveDataMap[id];
}
