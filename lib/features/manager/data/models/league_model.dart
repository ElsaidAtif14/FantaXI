class LeagueModel {
  final int id;
  final String name;
  final int? rank;
  final int? lastRank;
  final int percentile;

  LeagueModel({
    required this.id,
    required this.name,
    this.rank,
    this.lastRank,
    required this.percentile,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'],
      name: json['name'],
      rank: json['entry_rank'],
      lastRank: json['entry_last_rank'],
      percentile: json['entry_percentile_rank'] ?? 0,
    );
  }

  factory LeagueModel.dummy() {
    return LeagueModel(
      id: 0,
      name: 'Loading League...',
      rank: 1000,
      lastRank: 1000,
      percentile: 50,
    );
  }

  int get rankMovement => (lastRank ?? 0) - (rank ?? 0);
}
