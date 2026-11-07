import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/presentation/widgets/movement_arrow.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeagueStandingRow extends StatelessWidget {
  const LeagueStandingRow({
    super.key,
    required this.standing,
    this.isCurrentUser = false,
    this.gameweekSelected = false,
  });

  final LeagueStanding standing;
  final bool isCurrentUser;
  final bool gameweekSelected;

  @override
  Widget build(BuildContext context) {
    final accent = _rankAccent(context.appColors, standing.rank, isCurrentUser);
    final points =
        gameweekSelected ? standing.eventTotal : standing.totalPoints;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.standingBackground,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color:
                isCurrentUser
                    ? context.appColors.standingCurrentUserBorder
                    : context.appColors.standingBorder,
          ),
          boxShadow:
              isCurrentUser
                  ? [
                    BoxShadow(
                      color: context.appColors.standingCurrentUserShadow,
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Material(
          color: context.appColors.standingTransparent,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => context.push('/picks?entryId=${standing.entryId}'),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(17),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 46,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _RankBadge(rank: standing.rank, accent: accent),
                                const SizedBox(height: 3),
                                MovementArrow(mov: standing.movement),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        standing.teamName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              context
                                                  .appColors
                                                  .standingTeamText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (isCurrentUser) ...[
                                      const SizedBox(width: 5),
                                      const _YouBadge(),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  standing.playerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        context.appColors.standingSecondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            width: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'GW',
                                  style: TextStyle(
                                    color:
                                        isCurrentUser
                                            ? context
                                                .appColors
                                                .standingCurrentGameweek
                                            : context
                                                .appColors
                                                .standingSecondaryText,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${standing.eventTotal}',
                                  style: TextStyle(
                                    color: context.appColors.standingPointsText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            constraints: const BoxConstraints(minWidth: 47),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isCurrentUser
                                      ? context
                                          .appColors
                                          .standingCurrentUserPointsBackground
                                      : context
                                          .appColors
                                          .standingPointsBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isCurrentUser
                                        ? context
                                            .appColors
                                            .standingCurrentUserPointsBorder
                                        : context
                                            .appColors
                                            .standingPointsBorder,
                              ),
                            ),
                            child: Text(
                              '$points',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    isCurrentUser
                                        ? context
                                            .appColors
                                            .standingCurrentPointsText
                                        : context
                                            .appColors
                                            .standingPointsTextAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _rankAccent(
    AppThemeColors colors,
    int rank,
    bool isCurrentUser,
  ) {
    if (isCurrentUser) return colors.primary;
    return switch (rank) {
      1 => colors.standingRankGold,
      2 => colors.standingRankSilver,
      3 => colors.standingRankBronze,
      _ => colors.standingRankDefault,
    };
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.accent});

  final int rank;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final podium = rank <= 3;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: podium ? accent : context.appColors.standingTransparent,
        shape: BoxShape.circle,
        border:
            podium
                ? null
                : Border.all(color: context.appColors.standingTransparent),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color:
              podium
                  ? context.appColors.standingRankText
                  : context.appColors.standingRankUnplacedText,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _YouBadge extends StatelessWidget {
  const _YouBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: context.appColors.standingYouBadgeBackground,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      'YOU',
      style: TextStyle(
        color: context.appColors.standingYouBadgeText,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
