import 'package:fantasy/features/history/data/models/manager_history_model.dart';

class AutoSub {
  final int elementIn;
  final int elementOut;
  final int event;

  AutoSub({
    required this.elementIn,
    required this.elementOut,
    required this.event,
  });

  factory AutoSub.fromJson(Map<String, dynamic> json) {
    return AutoSub(
      elementIn: json['element_in'],
      elementOut: json['element_out'],
      event: json['event'],
    );
  }
}

class TeamPick {
  final int element;
  final int position;
  final int multiplier;
  final bool isCaptain;
  final bool isViceCaptain;
  final int elementType;

  TeamPick({
    required this.element,
    required this.position,
    required this.multiplier,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.elementType,
  });

  factory TeamPick.fromJson(Map<String, dynamic> json) {
    return TeamPick(
      element: json['element'],
      position: json['position'],
      multiplier: json['multiplier'],
      isCaptain: json['is_captain'],
      isViceCaptain: json['is_vice_captain'],
      elementType: json['element_type'],
    );
  }

  factory TeamPick.dummy(int position, int elementType) {
    return TeamPick(
      element: 0,
      position: position,
      multiplier: 1,
      isCaptain: position == 1,
      isViceCaptain: position == 2,
      elementType: elementType,
    );
  }

  bool get isStarting => position <= 11;
  bool get isOnBench => position > 11;

  String get positionName {
    switch (elementType) {
      case 1:
        return 'GKP';
      case 2:
        return 'DEF';
      case 3:
        return 'MID';
      case 4:
        return 'FWD';
      default:
        return '???';
    }
  }
}

class GameWeekPicksModel {
  final String? activeChip;
  final List<AutoSub> autoSubs;
  final List<TeamPick> picks;
  final EventHistory stats;

  GameWeekPicksModel({
    this.activeChip,
    required this.autoSubs,
    required this.picks,
    required this.stats,
  });

  factory GameWeekPicksModel.fromJson(Map<String, dynamic> json) {
    return GameWeekPicksModel(
      activeChip: json['active_chip'],
      autoSubs: (json['automatic_subs'] as List)
          .map((s) => AutoSub.fromJson(s))
          .toList(),
      picks: (json['picks'] as List)
          .map((p) => TeamPick.fromJson(p))
          .toList(),
      stats: EventHistory.fromJson(json['entry_history']),
    );
  }

  factory GameWeekPicksModel.dummy() {
    final Map<int, int> positionToType = {
      1: 1, // GK
      2: 2, 3: 2, 4: 2, 5: 2, // DEF
      6: 3, 7: 3, 8: 3, 9: 3, // MID
      10: 4, 11: 4, // FWD
      12: 1, 13: 2, 14: 3, 15: 4, // BENCH
    };

    return GameWeekPicksModel(
      activeChip: null,
      autoSubs: [],
      picks: List.generate(15, (i) => TeamPick.dummy(i + 1, positionToType[i + 1]!)),
      stats: EventHistory.dummy(),
    );
  }

  List<TeamPick> get startingXI => picks.where((p) => p.isStarting).toList();
  List<TeamPick> get bench => picks.where((p) => p.isOnBench).toList();
  TeamPick get captain => picks.firstWhere((p) => p.isCaptain);
  bool get hadSubs => autoSubs.isNotEmpty;
}
