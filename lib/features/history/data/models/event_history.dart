// Event stats per GW
class EventHistory {
  final int event;
  final int points;
  final int totalPoints;
  final int rank;
  final int overallRank;
  final int percentileRank;
  final double bank;
  final double teamValue;
  final int transfers;
  final int transfersCost;
  final int pointsOnBench;

  EventHistory({
    required this.event,
    required this.points,
    required this.totalPoints,
    required this.rank,
    required this.overallRank,
    required this.percentileRank,
    required this.bank,
    required this.teamValue,
    required this.transfers,
    required this.transfersCost,
    required this.pointsOnBench,
  });

  factory EventHistory.fromJson(Map<String, dynamic> json) {
    return EventHistory(
      event: json['event'],
      points: json['points'],
      totalPoints: json['total_points'],
      rank: (json['rank'] ?? 0) is String ? int.tryParse(json['rank'] ?? '0') ?? 0 : json['rank'] ?? 0,
      overallRank: (json['overall_rank'] ?? 0) is String ? int.tryParse(json['overall_rank'] ?? '0') ?? 0 : json['overall_rank'] ?? 0,
      percentileRank: (json['percentile_rank'] ?? 0) is String ? int.tryParse(json['percentile_rank'] ?? '0') ?? 0 : json['percentile_rank'] ?? 0,
      bank: (json['bank'] ?? 0) / 10.0,
      teamValue: (json['value'] ?? 0) / 10.0,
      transfers: json['event_transfers'] ?? 0,
      transfersCost: json['event_transfers_cost'] ?? 0,
      pointsOnBench: json['points_on_bench'] ?? 0,
    );
  }

  factory EventHistory.dummy() {
    return EventHistory(
      event: 1,
      points: 50,
      totalPoints: 500,
      rank: 100000,
      overallRank: 100000,
      percentileRank: 50,
      bank: 10.0,
      teamValue: 100.0,
      transfers: 0,
      transfersCost: 0,
      pointsOnBench: 5,
    );
  }
}
