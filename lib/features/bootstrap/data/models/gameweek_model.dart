class GameweekModel {
  const GameweekModel({
    required this.id,
    required this.isCurrent,
    required this.isNext,
  });

  final int id;
  final bool isCurrent;
  final bool isNext;

  factory GameweekModel.fromJson(Map<String, dynamic> json) {
    return GameweekModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      isCurrent: json['is_current'] == true,
      isNext: json['is_next'] == true,
    );
  }
}
