class TeamModel {
  final int id;
  final String name;
  final String shortName;
  final String code;

  TeamModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.code,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: (json['name'] ?? 'Unknown Team').toString(),
      shortName: (json['short_name'] ?? 'UNK').toString(),
      code: (json['code'] ?? '').toString(),
    );
  }

  factory TeamModel.dummy() {
    return TeamModel(
      id: 1,
      name: 'Manchester United',
      shortName: 'MUN',
      code: 'MUN',
    );
  }
}
