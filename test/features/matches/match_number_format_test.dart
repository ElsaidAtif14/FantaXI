import 'package:fantasy/features/matches/presentation/formatting/match_number_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMatchNumber', () {
    test('drops trailing decimals', () {
      expect(formatMatchNumber(55.0), '55');
      expect(formatMatchNumber(0.0), '0');
      expect(formatMatchNumber(21), '21');
    });

    test('keeps one decimal when the value is fractional', () {
      expect(formatMatchNumber(67.1), '67.1');
      expect(formatMatchNumber(1.2644), '1.26');
      expect(formatMatchNumber(0.3624), '0.36');
    });

    test('groups thousands', () {
      expect(formatMatchNumber(60000), '60,000');
      expect(formatMatchNumber(-1234), '-1,234');
      expect(formatMatchNumber(508.0), '508');
    });

    test('uses the requested decimal policy', () {
      expect(formatMatchNumber(0.3624, decimals: 2), '0.36');
      expect(formatMatchNumber(67.14, decimals: 0), '67');
      expect(formatMatchNumber(92.5, decimals: 1), '92.5');
    });

    test('renders unsafe numbers as a dash', () {
      expect(formatMatchNumber(double.nan), '—');
      expect(formatMatchNumber(double.infinity), '—');
    });
  });

  group('formatPercentage and formatXg', () {
    test('percentages include the token and round to whole numbers', () {
      expect(formatPercentage(67.1), '67%');
      expect(formatPercentage(45.5), '46%');
      expect(formatPercentage(0), '0%');
      expect(formatPercentage(32.9), '33%');
    });

    test('xG always uses two decimals', () {
      expect(formatXg(1.2644), '1.26');
      expect(formatXg(0), '0.00');
      expect(formatXg(2), '2.00');
    });
  });
}
