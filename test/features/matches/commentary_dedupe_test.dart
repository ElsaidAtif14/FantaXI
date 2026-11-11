import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/formatting/commentary_dedupe.dart';
import 'package:flutter_test/flutter_test.dart';

const _ts1 = '2026-11-07 16:54:52';
const _ts2 = '2026-11-07 16:53:44';

DateTime? _ts(String value) => DateTime.tryParse(value);

MatchCommentary _row(
  String text, {
  String? timestamp,
  String? type,
  String? time,
}) => MatchCommentary(
  text: text,
  timestamp: _ts(timestamp ?? _ts1),
  type: type,
  time: time,
);

void main() {
  group('language triples from the real feed', () {
    test(
      'collapses the Spanish/English/Arabic triple into the English row',
      () {
        final result = dedupeCommentary([
          _row(
            'Final del partido, Arsenal 1, Hull City 0.',
            type: 'end 14',
            time: ' ',
          ),
          _row(
            'Match ends, Arsenal 1, Hull City 0.',
            type: 'end 14',
            time: ' ',
          ),
          _row(
            'المباراة انتهى, أرسنال 1, هال سيتي 0.',
            type: 'end 14',
            time: ' ',
          ),
        ]);

        expect(result, hasLength(1));
        expect(result.single.text, 'Match ends, Arsenal 1, Hull City 0.');
      },
    );

    test('keeps Spanish over Arabic when no English variant exists', () {
      final result = dedupeCommentary([
        _row('Final del partido, Arsenal 1, Hull City 0.', type: 'end 14'),
        _row('المباراة انتهى, أرسنال 1, هال سيتي 0.', type: 'end 14'),
      ]);

      expect(result, hasLength(1));
      expect(result.single.text, 'Final del partido, Arsenal 1, Hull City 0.');
    });

    test('keeps Arabic when it is the only language for an event', () {
      final result = dedupeCommentary([
        _row('المباراة انتهى, أرسنال 1, هال سيتي 0.', type: 'end 14'),
        _row('المباراة انتهى, أرسنال 1, هال سيتي 0.', type: 'end 14'),
      ]);

      expect(result, hasLength(1));
      expect(result.single.text, 'المباراة انتهى, أرسنال 1, هال سيتي 0.');
    });

    test('prefers English even when it arrives after the Spanish row', () {
      final result = dedupeCommentary([
        _row('Segunda parte terminada, Arsenal 1, Hull City 0.', type: 'end 2'),
        _row('Second Half ends, Arsenal 1, Hull City 0.', type: 'end 2'),
      ]);

      expect(result.single.text, 'Second Half ends, Arsenal 1, Hull City 0.');
    });
  });

  group('event separation', () {
    test('keeps two different free kicks that share a timestamp', () {
      // Real feed: a won and a lost free kick registered in the same second.
      final result = dedupeCommentary([
        _row(
          'Falta de Mikel Merino (Arsenal).',
          type: 'free kick lost',
          time: "90'+2'",
        ),
        _row(
          'Foul by Mikel Merino (Arsenal).',
          type: 'free kick lost',
          time: "90'+2'",
        ),
        _row(
          'خطأ بواسطة ميكيل ميرينو (أرسنال).',
          type: 'free kick lost',
          time: "90'+2'",
        ),
        _row(
          'X (Hull City) ha recibido una falta.',
          type: 'free kick won',
          time: "90'+2'",
        ),
        _row(
          'X (Hull City) wins a free kick.',
          type: 'free kick won',
          time: "90'+2'",
        ),
        _row('X تحصّل على ركلة حرة.', type: 'free kick won', time: "90'+2'"),
      ]);

      expect(result, hasLength(2));
      expect(
        result.map((row) => row.type),
        everyElement(isIn(['free kick lost', 'free kick won'])),
      );
      expect(
        result.map((row) => row.text),
        containsAll(<String>[
          'Foul by Mikel Merino (Arsenal).',
          'X (Hull City) wins a free kick.',
        ]),
      );
    });

    test('keeps events with different timestamps apart', () {
      final result = dedupeCommentary([
        _row('Attempt missed', type: 'miss', timestamp: _ts1),
        _row('Attempt missed', type: 'miss', timestamp: _ts2),
      ]);

      expect(result, hasLength(2));
    });
  });

  group('safety properties', () {
    test('never merges rows without a timestamp', () {
      final result = dedupeCommentary([
        MatchCommentary(text: 'Free kick lost.', type: 'free kick lost'),
        MatchCommentary(text: 'Free kick lost.', type: 'free kick lost'),
      ]);

      expect(result, hasLength(2));
    });

    test('preserves first-occurrence order across interleaved events', () {
      final result = dedupeCommentary([
        _row('Goal! Arsenal 1, Hull City 0.', type: 'goal', timestamp: _ts2),
        _row('Comienza la segunda parte.', type: 'halfway', timestamp: _ts1),
        _row('Gol! Arsenal 1.', type: 'goal', timestamp: _ts2),
        _row('Second half begins.', type: 'halfway', timestamp: _ts1),
      ]);

      expect(result, hasLength(2));
      expect(result[0].type, 'goal');
      // The group keeps the position of its first row but upgrades content.
      expect(result[0].text, 'Goal! Arsenal 1, Hull City 0.');
      expect(result[1].text, 'Second half begins.');
    });

    test('tolerates an empty feed', () {
      expect(dedupeCommentary(const []), isEmpty);
    });
  });
}
