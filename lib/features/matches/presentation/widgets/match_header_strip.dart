import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:flutter/material.dart';

/// Competition and matchweek strip. Match status lives only in the scoreboard
/// so the same information is never rendered twice.
class MatchHeaderStrip extends StatelessWidget {
  const MatchHeaderStrip({
    super.key,
    required this.competition,
    this.matchweek,
  });

  final String competition;
  final int? matchweek;

  @override
  Widget build(BuildContext context) {
    final week = matchweek;
    final label = week == null ? competition : '$competition · MW $week';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MatchDetailsStyle.gutter,
        MatchDetailsStyle.spaceSm,
        MatchDetailsStyle.gutter,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: context.appColors.matchLive,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w700,
                letterSpacing: .7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
