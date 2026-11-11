/// Presentation-only catalog that turns the Premier League API's raw
/// statistics keys into readable, grouped rows.
///
/// The API currently returns around 180 keys per side, but neither the count
/// nor the key set is treated as fixed: any key that is not listed here still
/// gets a readable fallback label and a generic number format.
library;

import 'match_number_format.dart';

enum StatGroup {
  matchFlow,
  attack,
  defending,
  duels,
  goalkeeping,
  setPieces,
  other,
}

extension StatGroupLabel on StatGroup {
  String get label => switch (this) {
    StatGroup.matchFlow => 'Match flow',
    StatGroup.attack => 'Attack',
    StatGroup.defending => 'Defending',
    StatGroup.duels => 'Duels & discipline',
    StatGroup.goalkeeping => 'Goalkeeping',
    StatGroup.setPieces => 'Set pieces',
    StatGroup.other => 'Other statistics',
  };
}

enum StatUnit { count, percent, decimal, xg, distance }

class MatchStatDefinition {
  const MatchStatDefinition({
    required this.key,
    required this.label,
    required this.group,
    this.unit = StatUnit.count,
    this.decimals,
    this.higherIsBetter,
    this.headline = false,
  });

  final String key;
  final String label;
  final StatGroup group;
  final StatUnit unit;
  final int? decimals;

  /// Whether a larger value is generally better for the team. Used for
  /// descriptive semantics, not to colour values as good or bad.
  final bool? higherIsBetter;
  final bool headline;
}

const matchStatCatalog = <MatchStatDefinition>[
  // Match flow
  MatchStatDefinition(
    key: 'possessionPercentage',
    label: 'Possession',
    group: StatGroup.matchFlow,
    unit: StatUnit.percent,
    higherIsBetter: true,
    headline: true,
  ),
  MatchStatDefinition(
    key: 'totalPass',
    label: 'Passes',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
    headline: true,
  ),
  MatchStatDefinition(
    key: 'accuratePass',
    label: 'Accurate passes',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'accurateFwdZonePass',
    label: 'Accurate forward-zone passes',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'totalFinalThirdPasses',
    label: 'Final-third passes',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'finalThirdEntries',
    label: 'Final-third entries',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'touches',
    label: 'Touches',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'ballRecovery',
    label: 'Ball recoveries',
    group: StatGroup.matchFlow,
    higherIsBetter: true,
  ),

  // Attack
  MatchStatDefinition(
    key: 'totalScoringAtt',
    label: 'Total shots',
    group: StatGroup.attack,
    higherIsBetter: true,
    headline: true,
  ),
  MatchStatDefinition(
    key: 'ontargetScoringAtt',
    label: 'Shots on target',
    group: StatGroup.attack,
    higherIsBetter: true,
    headline: true,
  ),
  MatchStatDefinition(
    key: 'expectedGoals',
    label: 'Expected goals (xG)',
    group: StatGroup.attack,
    unit: StatUnit.xg,
    decimals: 2,
    higherIsBetter: true,
    headline: true,
  ),
  MatchStatDefinition(
    key: 'attIboxTarget',
    label: 'Shots on target inside box',
    group: StatGroup.attack,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'shotOffTarget',
    label: 'Shots off target',
    group: StatGroup.attack,
  ),
  MatchStatDefinition(
    key: 'blockedScoringAtt',
    label: 'Shots blocked',
    group: StatGroup.attack,
  ),
  MatchStatDefinition(
    key: 'expectedAssists',
    label: 'Expected assists (xA)',
    group: StatGroup.attack,
    unit: StatUnit.xg,
    decimals: 2,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'expectedGoalsOnTarget',
    label: 'Expected goals on target',
    group: StatGroup.attack,
    unit: StatUnit.xg,
    decimals: 2,
  ),
  MatchStatDefinition(
    key: 'bigChanceCreated',
    label: 'Big chances created',
    group: StatGroup.attack,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'bigChanceMissed',
    label: 'Big chances missed',
    group: StatGroup.attack,
  ),
  MatchStatDefinition(
    key: 'bigChanceScored',
    label: 'Big chances scored',
    group: StatGroup.attack,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'penAreaEntries',
    label: 'Penalty-area entries',
    group: StatGroup.attack,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'touchesInOppBox',
    label: 'Touches in opposition box',
    group: StatGroup.attack,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'goals',
    label: 'Goals',
    group: StatGroup.attack,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'ownGoals',
    label: 'Own goals',
    group: StatGroup.attack,
  ),
  MatchStatDefinition(
    key: 'attIboxGoal',
    label: 'Goals inside box',
    group: StatGroup.attack,
  ),
  MatchStatDefinition(
    key: 'attOboxGoal',
    label: 'Goals outside box',
    group: StatGroup.attack,
  ),
  MatchStatDefinition(
    key: 'totalOffside',
    label: 'Offsides',
    group: StatGroup.attack,
  ),

  // Defending
  MatchStatDefinition(
    key: 'totalTackle',
    label: 'Tackles',
    group: StatGroup.defending,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'wonTackle',
    label: 'Tackles won',
    group: StatGroup.defending,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'interception',
    label: 'Interceptions',
    group: StatGroup.defending,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'interceptionWon',
    label: 'Interceptions won',
    group: StatGroup.defending,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'totalClearance',
    label: 'Clearances',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'effectiveClearance',
    label: 'Effective clearances',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'headClearance',
    label: 'Headed clearances',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'blockedPass',
    label: 'Blocked passes',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'blockedCross',
    label: 'Blocked crosses',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'outfielderBlock',
    label: 'Outfielder blocks',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'effectiveBlockedCross',
    label: 'Effective blocked crosses',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'duelWon',
    label: 'Duels won',
    group: StatGroup.defending,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'duelLost',
    label: 'Duels lost',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'aerialWon',
    label: 'Aerial duels won',
    group: StatGroup.defending,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'aerialLost',
    label: 'Aerial duels lost',
    group: StatGroup.defending,
  ),
  MatchStatDefinition(
    key: 'challengeLost',
    label: 'Challenges lost',
    group: StatGroup.defending,
  ),

  // Duels & discipline
  MatchStatDefinition(
    key: 'wonContest',
    label: 'Contests won',
    group: StatGroup.duels,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'totalContest',
    label: 'Contests',
    group: StatGroup.duels,
  ),
  MatchStatDefinition(
    key: 'fkFoulWon',
    label: 'Fouls won',
    group: StatGroup.duels,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'fkFoulLost',
    label: 'Fouls conceded',
    group: StatGroup.duels,
  ),
  MatchStatDefinition(
    key: 'totalYelCard',
    label: 'Yellow cards',
    group: StatGroup.duels,
  ),
  MatchStatDefinition(
    key: 'totalRedCard',
    label: 'Red cards',
    group: StatGroup.duels,
  ),
  MatchStatDefinition(
    key: 'dispossessed',
    label: 'Dispossessed',
    group: StatGroup.duels,
  ),
  MatchStatDefinition(
    key: 'unsuccessfulTouch',
    label: 'Unsuccessful touches',
    group: StatGroup.duels,
  ),

  // Goalkeeping
  MatchStatDefinition(
    key: 'saves',
    label: 'Saves',
    group: StatGroup.goalkeeping,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'savedIbox',
    label: 'Saves inside box',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'savedObox',
    label: 'Saves outside box',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'divingSave',
    label: 'Diving saves',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'goodHighClaim',
    label: 'Good high claims',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'totalHighClaim',
    label: 'High claims',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'punches',
    label: 'Punches',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'accurateKeeperThrows',
    label: 'Accurate keeper throws',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'totalKeeperSweeper',
    label: 'Keeper sweeper actions',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'goalKicks',
    label: 'Goal kicks',
    group: StatGroup.goalkeeping,
  ),
  MatchStatDefinition(
    key: 'cleanSheet',
    label: 'Clean sheets',
    group: StatGroup.goalkeeping,
  ),

  // Set pieces
  MatchStatDefinition(
    key: 'wonCorners',
    label: 'Corners won',
    group: StatGroup.setPieces,
    higherIsBetter: true,
  ),
  MatchStatDefinition(
    key: 'lostCorners',
    label: 'Corners conceded',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'cornerTaken',
    label: 'Corners taken',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'totalCross',
    label: 'Crosses',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'accurateCross',
    label: 'Accurate crosses',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'freekickCross',
    label: 'Free-kick crosses',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'accurateFreekickCross',
    label: 'Accurate free-kick crosses',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'totalThrows',
    label: 'Throw-ins',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'accurateThrows',
    label: 'Accurate throw-ins',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'totalLongBalls',
    label: 'Long balls',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'accurateLongBalls',
    label: 'Accurate long balls',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'totalLaunches',
    label: 'Launches',
    group: StatGroup.setPieces,
  ),
  MatchStatDefinition(
    key: 'accurateLaunches',
    label: 'Accurate launches',
    group: StatGroup.setPieces,
  ),
];

final Map<String, MatchStatDefinition> _catalogByKey = {
  for (final definition in matchStatCatalog) definition.key: definition,
};

MatchStatDefinition? statDefinitionFor(String key) => _catalogByKey[key];

/// Readable fallback shown for keys that are not in the catalog yet.
String humanizeStatKey(String key) {
  final spaced =
      key
          .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (m) => '${m[1]} ${m[2]}',
          )
          .replaceAll('_', ' ')
          .trim();
  if (spaced.isEmpty) return key;
  final words = spaced.split(RegExp(r'\s+'));
  return words.map(_humanizeWord).join(' ');
}

const _abbreviations = <String, String>{
  'att': 'Attack',
  'obx': 'Outside box',
  'ibox': 'Inside box',
  'bx': 'Box',
  'lf': 'Left foot',
  'rf': 'Right foot',
  'hd': 'Header',
  'fk': 'Free kick',
  'sv': 'Save',
  'pct': '%',
  'xg': 'xG',
  'xa': 'xA',
  'obox': 'Outside box',
  'fwd': 'Forward',
  'def': 'Defensive',
  'mid': 'Middle',
  'poss': 'Possession',
  'yel': 'Yellow',
  'red': 'Red',
};

String _humanizeWord(String word) {
  final lower = word.toLowerCase();
  final abbreviation = _abbreviations[lower];
  if (abbreviation != null) return abbreviation;
  if (word.isEmpty) return word;
  return '${word[0].toUpperCase()}${word.substring(1)}';
}

/// Formats a statistics value using the catalog entry when available and a
/// safe generic format otherwise.
String formatStatValue(String key, num value) {
  final definition = statDefinitionFor(key);
  if (definition == null) return formatMatchNumber(value);
  return switch (definition.unit) {
    StatUnit.percent => formatPercentage(
      value,
      decimals: definition.decimals ?? 0,
    ),
    StatUnit.xg => formatXg(value),
    StatUnit.decimal => formatMatchNumber(
      value,
      decimals: definition.decimals ?? 1,
    ),
    StatUnit.distance => '${formatMatchNumber(value, decimals: 1)} km',
    StatUnit.count => formatMatchNumber(value),
  };
}
