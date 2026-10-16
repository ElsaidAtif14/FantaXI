import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_models.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_movement_chip.dart';
import 'package:flutter/material.dart';

class LeaguesHubLeagueCard extends StatelessWidget {
  const LeaguesHubLeagueCard({
    required this.item,
    required this.managerPoints,
    required this.currentGameweek,
    required this.isFeatured,
    required this.onTap,
    super.key,
  });

  final LeaguesHubLeagueItem item;
  final int managerPoints;
  final int currentGameweek;
  final bool isFeatured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final league = item.league;
    final rank = league.rank;
    final hasMovement = rank != null && league.lastRank != null;
    final accent = item.isGlobal ? AppColors.lineupMint : AppColors.lineupLavender;
    final highlighted = isFeatured && !item.isGlobal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xD91D2232), Color(0xF2121520)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: .07)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: .25),
                          const Color(0xFF0F766E).withValues(alpha: .2),
                          const Color(0xFF0F172A),
                        ],
                      ),
                      border: Border.all(color: accent.withValues(alpha: .4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.isGlobal ? Icons.public_rounded : Icons.diamond_rounded,
                      color: const Color(0xFFF1F5F9),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                league.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.375,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _AccessBadge(label: _badgeLabel(item), color: accent),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rank == null
                              ? 'Rank not available'
                              : 'Rank: ${_formatRank(rank)}${league.percentile > 0 ? ' • Top ${league.percentile}% Percentile' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (hasMovement)
                                LeaguesHubMovementChip(movement: league.rankMovement),
                              Text(
                                '$managerPoints pts',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.lineupTextSecondary.withValues(alpha: .75),
                        ),
                        Text(
                          highlighted
                              ? 'Active GW$currentGameweek'
                              : rank == null
                              ? '—'
                              : '#${_formatRank(rank)}',
                          style: TextStyle(
                            color: highlighted ? AppColors.lineupMint : Colors.white,
                            fontSize: highlighted ? 10 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: highlighted ? 0 : -.4,
                          ),
                        ),
                      ],
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

  String _badgeLabel(LeaguesHubLeagueItem item) {
    final name = item.league.name.toLowerCase();
    if (item.isGlobal) {
      return name.contains('overall') || name.contains('world') ? 'WORLDWIDE' : 'NATIONAL';
    }
    if (name.contains('invitational')) return 'INVITATIONAL';
    if (isFeatured && item.league.rank != null) {
      return 'YOU #${_formatRank(item.league.rank!)}';
    }
    return 'PRIVATE';
  }

  static String _formatRank(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF242B3D),
        border: Border.all(color: const Color(0x80334155)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: color == AppColors.lineupMint ? const Color(0xFFCBD5E1) : color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
