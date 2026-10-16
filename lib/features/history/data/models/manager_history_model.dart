import 'package:fantasy/features/history/data/models/event_history.dart';
import 'package:fantasy/features/history/data/models/chip_usage.dart';

export 'event_history.dart';
export 'chip_usage.dart';

class ManagerHistoryModel {
  final List<EventHistory> currentSeason;
  final List<ChipUsage> usedChips;

  ManagerHistoryModel({
    required this.currentSeason,
    required this.usedChips,
  });

  factory ManagerHistoryModel.fromJson(Map<String, dynamic> json) {
    return ManagerHistoryModel(
      currentSeason: (json['current'] as List)
          .map((e) => EventHistory.fromJson(e))
          .toList(),
      usedChips: (json['chips'] as List)
          .map((c) => ChipUsage.fromJson(c))
          .toList(),
    );
  }

  int get highestPoints => currentSeason.isEmpty
      ? 0
      : currentSeason.map((e) => e.points).reduce((a, b) => a > b ? a : b);

  int get totalTransfersCost =>
      currentSeason.fold(0, (sum, item) => sum + item.transfersCost);

  bool hasUsedChip(String chipName) =>
      usedChips.any((c) => c.name == chipName);

  double get averagePoints => currentSeason.isEmpty
      ? 0
      : currentSeason.map((e) => e.points).reduce((a, b) => a + b) /
          currentSeason.length;

  factory ManagerHistoryModel.dummy() {
    return ManagerHistoryModel(
      currentSeason: List.generate(5, (_) => EventHistory.dummy()),
      usedChips: [],
    );
  }
}
