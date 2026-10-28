import 'package:fantasy/features/manager/data/models/league_model.dart';

enum LeaguesHubFilterGroup { all, global, private }

class LeaguesHubLeagueItem {
  const LeaguesHubLeagueItem({required this.league, required this.isGlobal});

  final LeagueModel league;
  final bool isGlobal;
}
