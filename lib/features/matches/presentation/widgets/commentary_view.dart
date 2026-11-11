import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/formatting/commentary_dedupe.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_empty_state.dart';
import 'package:flutter/material.dart';

/// Commentary tab: one deduplicated row per event, newest first, with a
/// load-more control so long feeds stay cheap to render.
class CommentaryView extends StatefulWidget {
  const CommentaryView({super.key, required this.details});

  final PremierLeagueMatchDetails? details;

  @override
  State<CommentaryView> createState() => _CommentaryViewState();
}

/// Rows visible before the first "Show more" tap, and the increment per tap.
const _pageSize = 20;

class _CommentaryViewState extends State<CommentaryView> {
  int _visible = _pageSize;

  static final _arabicRange = RegExp(r'[\u0600-\u06FF]');

  @override
  Widget build(BuildContext context) {
    final rows = dedupeCommentary(widget.details?.commentary ?? const []);
    if (rows.isEmpty) {
      return const SectionEmptyState(
        icon: Icons.forum_rounded,
        title: 'Commentary unavailable',
        message: 'Verified commentary is not available for this fixture.',
      );
    }

    final visibleCount = _visible.clamp(0, rows.length);
    final remaining = rows.length - visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows.take(visibleCount))
          _CommentaryRow(
            row: row,
            isRtl: _arabicRange.hasMatch(row.text ?? ''),
          ),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: MatchDetailsStyle.spaceSm,
            ),
            child: Center(
              child: TextButton(
                onPressed: () => setState(() => _visible += _pageSize),
                child: Text('Show more ($remaining)'),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentaryRow extends StatelessWidget {
  const _CommentaryRow({required this.row, required this.isRtl});

  final MatchCommentary row;
  final bool isRtl;

  String get _minute {
    final time = row.time?.trim() ?? '';
    if (time.isNotEmpty) return time;
    return 'FT';
  }

  @override
  Widget build(BuildContext context) {
    final text = row.text?.trim() ?? '';
    return Semantics(
      label:
          '${_minute == 'FT' ? 'Full time' : _minute}'
          '${row.type?.trim().isEmpty ?? true ? '' : ', ${row.type!.trim()}'}'
          ': ${text.isEmpty ? 'commentary unavailable' : text}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Text(
                _minute,
                style: TextStyle(
                  color: context.appColors.lineupLavender,
                  fontSize: MatchDetailsStyle.microSize,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  text.isEmpty ? 'Commentary unavailable' : text,
                  style: TextStyle(
                    color: context.appColors.lineupText,
                    fontSize: MatchDetailsStyle.bodySize,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
