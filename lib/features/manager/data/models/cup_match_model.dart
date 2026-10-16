class CupMatchModel {
  final int event;
  final String opponentName;
  final int myPoints;
  final int opponentPoints;
  final bool isWinner;
  final String knockoutName;

  CupMatchModel({
    required this.event,
    required this.opponentName,
    required this.myPoints,
    required this.opponentPoints,
    required this.isWinner,
    required this.knockoutName,
  });

  factory CupMatchModel.fromJson(Map<String, dynamic> json, int myId) {
    bool iAmEntry1 = json['entry_1_entry'] == myId;
    return CupMatchModel(
      event: json['event'],
      opponentName:
          iAmEntry1 ? json['entry_2_player_name'] : json['entry_1_player_name'],
      myPoints:
          iAmEntry1 ? json['entry_1_points'] : json['entry_2_points'],
      opponentPoints:
          iAmEntry1 ? json['entry_2_points'] : json['entry_1_points'],
      isWinner: json['winner'] == myId,
      knockoutName: json['knockout_name'] ?? '',
    );
  }
}
