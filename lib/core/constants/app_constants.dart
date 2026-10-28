class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://fantasy.premierleague.com/api';

  // Endpoints
  static const String bootstrapStatic = '/bootstrap-static/';
  static const String fixtures = '/fixtures/';
  static String entry(int entryId) => '/entry/$entryId/';
  static String entryHistory(int entryId) => '/entry/$entryId/history/';
  static String entryPicks(int entryId, int gw) =>
      '/entry/$entryId/event/$gw/picks/';
  static String leagueStandings(int leagueId) =>
      '/leagues-classic/$leagueId/standings/';
  static String liveGW(int gw) => '/event/$gw/live/';

  // Local Storage Keys
  static const String entryIdKey = 'entry_id';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  // Player image base
  static const String playerImageBase =
      'https://resources.premierleague.com/premierleague26/photos/players/110x140/';
  static const String shirtImageBase =
      'https://fantasy.premierleague.com/dist/img/shirts/standard/shirt_';
  static const String teamBadgeBase =
      'https://resources.premierleague.com/premierleague/badges/70/t';
}
