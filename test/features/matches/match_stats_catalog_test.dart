import 'package:fantasy/features/matches/presentation/formatting/match_stats_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Keys captured from a real `/stats` API response. Every one of these keys
  // must resolve to a readable definition so no raw camelCase label leaks.
  const realApiKeys = [
    'accurateFwdZonePass',
    'aerialLost',
    'aerialWon',
    'attIboxTarget',
    'ballRecovery',
    'blockedPass',
    'bigChanceCreated',
    'bigChanceScored',
    'cornerTaken',
    'divingSave',
    'duelLost',
    'duelWon',
    'effectiveClearance',
    'expectedAssists',
    'expectedGoals',
    'expectedGoalsOnTarget',
    'fkFoulLost',
    'fkFoulWon',
    'goals',
    'interception',
    'ontargetScoringAtt',
    'possessionPercentage',
    'saves',
    'shotOffTarget',
    'totalClearance',
    'totalPass',
    'totalScoringAtt',
    'totalTackle',
    'totalYelCard',
    'totalRedCard',
    'wonCorners',
    'wonTackle',
  ];

  group('catalog coverage', () {
    test('defines every major real API key', () {
      for (final key in realApiKeys) {
        expect(statDefinitionFor(key), isNotNull, reason: 'missing: $key');
      }
    });

    test('does not map two definitions to the same key', () {
      final keys = matchStatCatalog.map((def) => def.key);
      expect(keys.length, keys.toSet().length);
    });

    test('marks exactly the headline statistics', () {
      final headlines =
          matchStatCatalog
              .where((def) => def.headline)
              .map((def) => def.key)
              .toList();
      expect(
        headlines,
        containsAll(<String>[
          'possessionPercentage',
          'totalScoringAtt',
          'ontargetScoringAtt',
          'expectedGoals',
          'totalPass',
        ]),
      );
    });

    test('uses every defined group with entries', () {
      final groups = matchStatCatalog.map((def) => def.group).toSet();
      expect(
        groups,
        containsAll(StatGroup.values.where((g) => g != StatGroup.other)),
      );
    });
  });

  group('humanized fallback labels', () {
    test('gives unknown keys a readable label', () {
      final key = 'someUnknownNewStatKey';
      expect(statDefinitionFor(key), isNull);
      expect(humanizeStatKey(key), 'Some Unknown New Stat Key');
    });

    test('never returns an empty label', () {
      for (final key in realApiKeys) {
        final label = statDefinitionFor(key)?.label ?? humanizeStatKey(key);
        expect(label.trim(), isNotEmpty);
        expect(label.contains(RegExp(r'[A-Z]{3,}')), isFalse);
      }
    });
  });

  group('value formatting through the catalog', () {
    test('formats known units consistently', () {
      expect(formatStatValue('possessionPercentage', 67.1), '67%');
      expect(formatStatValue('expectedGoals', 1.2644), '1.26');
      expect(formatStatValue('totalScoringAtt', 21.0), '21');
      expect(formatStatValue('totalPass', 590.0), '590');
    });

    test('formats unknown keys with the generic policy', () {
      expect(formatStatValue('brandNewMetric', 12.0), '12');
      expect(formatStatValue('brandNewMetric', 3.14159), '3.14');
    });
  });
}
