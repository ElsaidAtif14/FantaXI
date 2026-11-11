/// Presentation-only number formatting for match statistics.
///
/// The Premier League API returns every statistic as a [num], often with a
/// trailing `.0`. These helpers keep the UI consistent without changing the
/// underlying values or their meaning.
library;

String formatMatchNumber(num value, {int? decimals, bool group = true}) {
  if (value.isNaN || value.isInfinite) return '—';

  if (decimals != null) {
    return _group(value.toStringAsFixed(decimals), group: group);
  }

  if (value == value.roundToDouble()) {
    return _group(value.toInt().toString(), group: group);
  }

  final fixed = value.toStringAsFixed(2);
  final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  return _group(trimmed, group: group);
}

String formatPercentage(num value, {int decimals = 0}) =>
    '${formatMatchNumber(value, decimals: decimals, group: false)}%';

String formatXg(num value) => value.toStringAsFixed(2);

String _group(String text, {required bool group}) {
  if (!group) return text;
  final negative = text.startsWith('-');
  final body = negative ? text.substring(1) : text;
  final parts = body.split('.');
  final integer = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  final fraction = parts.length > 1 ? '.${parts[1]}' : '';
  return '${negative ? '-' : ''}$integer$fraction';
}
