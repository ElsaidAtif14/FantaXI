import 'package:fantasy/core/constants/app_constants.dart';

class PlayerModel {
  final int id;
  final String firstName;
  final String secondName;
  final String webName;
  final int team;
  final int elementType;
  final int nowCost;
  final String photo;
  final double form;
  final int totalPoints;
  final String status;
  final String news;
  final int eventPoints;
  final String selectedByPercent;

  PlayerModel({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.webName,
    required this.team,
    required this.elementType,
    required this.nowCost,
    required this.photo,
    required this.form,
    required this.totalPoints,
    required this.status,
    required this.news,
    required this.eventPoints,
    required this.selectedByPercent,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id'],
    firstName: (json['first_name'] ?? '').toString(),
    secondName: (json['second_name'] ?? '').toString(),
    webName: (json['web_name'] ?? '').toString(),
    team: json['team'],
    elementType: json['element_type'],
    nowCost: json['now_cost'],
    photo: (json['photo'] ?? '').toString(),
    form: double.tryParse(json['form'] ?? '0.0') ?? 0.0,
    totalPoints: json['total_points'],
    status: (json['status'] ?? '').toString(),
    news: (json['news'] ?? '').toString(),
    eventPoints: json['event_points'],
    selectedByPercent: (json['selected_by_percent'] ?? '0').toString(),
  );

  factory PlayerModel.dummy() {
    return PlayerModel(
      id: 0,
      firstName: 'Loading',
      secondName: 'Player',
      webName: 'Player',
      team: 1,
      elementType: 1,
      nowCost: 100,
      photo: '111111',
      form: 5.0,
      totalPoints: 100,
      status: 'a',
      news: '',
      eventPoints: 10,
      selectedByPercent: '10.0',
    );
  }

  String get formattedPrice => '£${(nowCost / 10.0).toStringAsFixed(1)}m';
  String get imageUrl =>
      '${AppConstants.playerImageBase}${photo.replaceAll('.jpg', '').replaceAll('.png', '')}.png';
  List<String> get imageUrls {
    final photoCode = photo.replaceAll('.jpg', '').replaceAll('.png', '');
    return [
      imageUrl,
      'https://resources.premierleague.com/premierleague25/photos/players/110x140/$photoCode.png',
      'https://resources.premierleague.com/premierleague/photos/players/250x250/p$photoCode.png',
    ];
  }

  String get shirtUrl => '${AppConstants.shirtImageBase}$team-110.png';
  String get positionName =>
      ['', 'GKP', 'DEF', 'MID', 'FWD'][elementType.clamp(1, 4)];
  bool get isAvailable => status == 'a';
  bool get isInjured => status == 'i';
}
