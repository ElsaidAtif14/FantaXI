import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';

/// Groups multi-language commentary rows that describe the same event and
/// returns one row per event, preferring English text.
///
/// The feed ships each event up to three times (Spanish, English and Arabic)
/// sharing an identical (timestamp, type) pair. Deduplication is deliberately
/// conservative:
/// - Rows without a timestamp are NEVER merged, a missing timestamp can hide
///   genuinely different events.
/// - Groups keep their first-occurrence position so chronology is unchanged.
/// - Within a group the best available language wins: English first, then any
///   other non-Arabic language, then Arabic.
final _arabicRange = RegExp(r'[\u0600-\u06FF]');

/// Word-boundary markers that unmistakably identify Spanish copy. Arabic rows
/// are detected separately by their Unicode range.
final _spanishMarkers = RegExp(
  r'\b(del|la|el|los|las|una|unos|unas|partido|parte|segunda|primer|'
  r'remate|falta|cambio|tarjeta|árbitro|córner|concede|recibido|zona|'
  r'[Aa]nunciado|tiempo|despeje|empate|gol)\b',
  caseSensitive: false,
);

enum _Language { englishOrOther, nonArabicSpanish, arabic, empty }

_Language _classify(String text) {
  if (text.isEmpty) return _Language.empty;
  if (_arabicRange.hasMatch(text)) return _Language.arabic;
  if (_spanishMarkers.hasMatch(text)) return _Language.nonArabicSpanish;
  // English (or any other non-Arabic language) is preferred.
  return _Language.englishOrOther;
}

int _rankOf(MatchCommentary row) => _classify(row.text?.trim() ?? '').index;

bool _isBetter(MatchCommentary candidate, MatchCommentary current) =>
    _rankOf(candidate) < _rankOf(current);

String? _groupKey(MatchCommentary row) {
  final timestamp = row.timestamp;
  if (timestamp == null) return null;
  return '${timestamp.millisecondsSinceEpoch}'
      '|${row.type?.trim() ?? ''}'
      '|${row.time?.trim() ?? ''}';
}

List<MatchCommentary> dedupeCommentary(List<MatchCommentary> rows) {
  final result = <MatchCommentary>[];
  final keyIndex = <String, int>{};
  for (final row in rows) {
    final key = _groupKey(row);
    if (key == null) {
      result.add(row);
      continue;
    }
    final index = keyIndex[key];
    if (index == null) {
      keyIndex[key] = result.length;
      result.add(row);
    } else if (_isBetter(row, result[index])) {
      result[index] = row;
    }
  }
  return result;
}
