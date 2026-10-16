import 'package:fantasy/core/theme/app_colors.dart';
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
    final accent = _rankAccent(standing.rank, isCurrentUser);
    final points = gameweekSelected ? standing.eventTotal : standing.totalPoints;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10131D),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isCurrentUser
                ? AppColors.primary.withValues(alpha: .85)
                : const Color(0xFF283343),
          ),
          boxShadow: isCurrentUser
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .22),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => context.push('/picks?entryId=${standing.entryId}'),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
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
                                        style: const TextStyle(
                                          color: Color(0xFFF8FAFC),
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
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
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
                                    color: isCurrentUser
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${standing.eventTotal}',
                                  style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
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
                              color: isCurrentUser
                                  ? AppColors.primary.withValues(alpha: .17)
                                  : const Color(0xFF0E2A35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentUser
                                    ? AppColors.primary.withValues(alpha: .65)
                                    : const Color(0xFF07566A),
                              ),
                            ),
                            child: Text(
                              '$points',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isCurrentUser
                                    ? const Color(0xFFEDE9FE)
                                    : const Color(0xFF67E8F9),
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

  static Color _rankAccent(int rank, bool isCurrentUser) {
    if (isCurrentUser) return AppColors.primary;
    return switch (rank) {
      1 => const Color(0xFFFACC15),
      2 => const Color(0xFFCBD5E1),
      3 => const Color(0xFFC2410C),
      _ => const Color(0xFF30394B),
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
        color: podium ? accent : Colors.transparent,
        shape: BoxShape.circle,
        border: podium ? null : Border.all(color: Colors.transparent),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color: podium ? const Color(0xFF111827) : const Color(0xFFCBD5E1),
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
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(5),
    ),
    child: const Text(
      'YOU',
      style: TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
