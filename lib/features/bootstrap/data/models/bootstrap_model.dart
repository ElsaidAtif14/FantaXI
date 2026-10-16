import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';

class BootstrapModel {
  final List<PlayerModel> players;
  final Map<int, PlayerModel> playersMap;
  final List<TeamModel> teams;
  final Map<int, TeamModel> teamsMap;

  BootstrapModel({
    required this.players,
    required this.playersMap,
    required this.teams,
    required this.teamsMap,
  });

  factory BootstrapModel.fromJson(Map<String, dynamic> json) {
    final players =
        (json['elements'] as List).map((e) => PlayerModel.fromJson(e)).toList();
    final teams =
        (json['teams'] as List?)?.map((t) => TeamModel.fromJson(t)).toList() ??
        [];

    return BootstrapModel(
      players: players,
      playersMap: {for (var p in players) p.id: p},
      teams: teams,
      teamsMap: {for (var t in teams) t.id: t},
    );
  }

  factory BootstrapModel.dummy() {
    final dummyPlayer = PlayerModel.dummy();
    final dummyTeam = TeamModel.dummy();
    return BootstrapModel(
      players: [dummyPlayer],
      playersMap: {0: dummyPlayer},
      teams: [dummyTeam],
      teamsMap: {1: dummyTeam},
    );
  }

  PlayerModel? getPlayer(int id) => playersMap[id];
  TeamModel? getTeam(int id) => teamsMap[id];
}
