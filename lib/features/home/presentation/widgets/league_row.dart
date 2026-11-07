import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/home/presentation/widgets/league_badge.dart';
import 'package:fantasy/features/manager/data/models/league_model.dart';
import 'package:fantasy/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeagueRow extends StatelessWidget {
  const LeagueRow({
    super.key,
    required this.league,
    this.isGlobal = false,
    this.totalPoints,
    this.gameweekPoints,
    this.badgeIcon,
    this.badgeLabel,
  });

  final LeagueModel league;
  final bool isGlobal;
  final int? totalPoints;
  final int? gameweekPoints;
  final IconData? badgeIcon;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final accent = isGlobal ? context.appColors.lineupLavender : context.appColors.lineupMint;
    final rank = league.rank;
    final hasMovement = rank != null && league.lastRank != null;
    final movement = hasMovement ? league.rankMovement : 0;
    final movementColor =
        movement > 0
            ? context.appColors.lineupMint
            : movement < 0
            ? const Color(0xFFFFB4AB)
            : context.appColors.lineupTextSecondary;
    final detail = [
      if (rank != null)
        'Rank: ${_formatRank(rank)}  |  ${league.percentile}% percentile',
      if (totalPoints != null) '$totalPoints pts',
      if (gameweekPoints != null) 'GW $gameweekPoints pts',
    ].join('  |  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        radius: 12,
        fillColor: context.appColors.lineupPanel.withValues(alpha: .92),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/league/${league.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      badgeIcon ??
                          (isGlobal
                              ? Icons.public_rounded
                              : Icons.emoji_events_rounded),
                      color: accent,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                league.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:  TextStyle(
                                  color: context.appColors.lineupText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (badgeLabel != null || rank != null) ...[
                              const SizedBox(width: 5),
                              LeagueBadge(
                                label: badgeLabel ?? 'YOU',
                                color: context.appColors.lineupLavender,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail.isEmpty ? 'Rank unavailable' : detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(
                            color: context.appColors.lineupTextSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  if (hasMovement)
                    _MovementBadge(movement: movement, color: movementColor),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.appColors.lineupTextSecondary.withValues(alpha: .7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatRank(int rank) {
    if (rank >= 1000000) return '${(rank / 1000000).toStringAsFixed(1)}M';
    if (rank >= 1000) return '${(rank / 1000).toStringAsFixed(1)}K';
    return rank.toString();
  }
}

class _MovementBadge extends StatelessWidget {
  const _MovementBadge({required this.movement, required this.color});

  final int movement;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            movement > 0
                ? Icons.arrow_upward_rounded
                : movement < 0
                ? Icons.arrow_downward_rounded
                : Icons.remove_rounded,
            color: color,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            movement.abs() == 0 ? '-' : _formatMovement(movement.abs()),
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatMovement(int movement) {
    if (movement >= 1000000) {
      return '${(movement / 1000000).toStringAsFixed(1)}M';
    }
    if (movement >= 1000) return '${(movement / 1000).toStringAsFixed(1)}K';
    return movement.toString();
  }
}
