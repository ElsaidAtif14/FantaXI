import 'package:fantasy/features/manager/data/models/league_model.dart';
import 'package:fantasy/features/manager/data/models/cup_match_model.dart';

class FantasyManagerModel {
  final int id;
  final String teamName;
  final String playerFirstName;
  final String playerLastName;
  final int totalPoints;
  final int overallRank;
  final int eventPoints;
  final int currentEvent;
  final List<int> enteredEvents;
  final double bank;
  final double teamValue;
  final List<LeagueModel> classicLeagues;
  final List<LeagueModel> globalLeagues;
  final List<CupMatchModel> cupMatches;

  FantasyManagerModel({
    required this.id,
    required this.teamName,
    required this.playerFirstName,
    required this.playerLastName,
    required this.totalPoints,
    required this.overallRank,
    required this.eventPoints,
    required this.currentEvent,
    required this.enteredEvents,
    required this.bank,
    required this.teamValue,
    required this.classicLeagues,
    required this.globalLeagues,
    required this.cupMatches,
  });

  factory FantasyManagerModel.fromJson(Map<String, dynamic> json) {
    return FantasyManagerModel(
      id: json['id'],
      teamName: json['name'],
      playerFirstName: json['player_first_name'],
      playerLastName: json['player_last_name'],
      totalPoints: json['summary_overall_points'],
      overallRank: json['summary_overall_rank'],
      eventPoints: json['summary_event_points'],
      currentEvent: json['current_event'],
      enteredEvents: List<int>.from(json['entered_events']),
      bank: (json['last_deadline_bank'] ?? 0) / 10.0,
      teamValue: (json['last_deadline_value'] ?? 0) / 10.0,
      classicLeagues: (json['leagues']['classic'] as List)
          .where((i) => i['league_type'] == 'x')
          .map((i) => LeagueModel.fromJson(i))
          .toList(),
      globalLeagues: (json['leagues']['classic'] as List)
          .where((i) => i['league_type'] == 's')
          .map((i) => LeagueModel.fromJson(i))
          .toList(),
      cupMatches: (json['leagues']['cup_matches'] as List)
          .map((i) => CupMatchModel.fromJson(i, json['id']))
          .toList(),
    );
  }

  factory FantasyManagerModel.dummy() {
    return FantasyManagerModel(
      id: 0,
      teamName: 'Loading Team...',
      playerFirstName: 'Loading',
      playerLastName: 'Manager',
      totalPoints: 1000,
      overallRank: 100000,
      eventPoints: 50,
      currentEvent: 10,
      enteredEvents: List.generate(10, (i) => i + 1),
      bank: 10.0,
      teamValue: 100.0,
      classicLeagues: List.generate(3, (_) => LeagueModel.dummy()),
      globalLeagues: List.generate(2, (_) => LeagueModel.dummy()),
      cupMatches: [],
    );
  }

  String get fullName => '$playerFirstName $playerLastName';
  int get totalPlayedGWs => enteredEvents.length;
  int get activeGW => enteredEvents.isNotEmpty ? enteredEvents.last : 0;
  bool get isConsistentPlayer => totalPlayedGWs == currentEvent;
  double get seasonCompletion => (totalPlayedGWs / 38).clamp(0.0, 1.0);
  String get rankFormatted {
    if (overallRank >= 1000000) {
      return '${(overallRank / 1000000).toStringAsFixed(1)}M';
    } else if (overallRank >= 1000) {
      return '${(overallRank / 1000).toStringAsFixed(1)}K';
    }
    return overallRank.toString();
  }
}
