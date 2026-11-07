import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/presentation/widgets/player_details_bottom_sheet.dart';

class LivePlayerRow extends StatelessWidget {
  final PlayerModel player;
  final TeamPick pick;
  final ElementLiveModel liveData;
  final BootstrapModel? bootstrap;

  const LivePlayerRow({
    super.key,
    required this.player,
    required this.pick,
    required this.liveData,
    this.bootstrap,
  });

  @override
  Widget build(BuildContext context) {
    final stats = liveData.stats;
    final totalPts = stats.totalPoints * pick.multiplier;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => PlayerDetailsBottomSheet(
                player: player,
                pick: pick,
                elementLive: liveData,
                bootstrap: bootstrap,
              ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                pick.isStarting
                    ? context.appColors.outline
                    : Colors.transparent,
          ),
          gradient:
              pick.isStarting
                  ? context.appColors.cardGradient
                  : LinearGradient(
                    colors: [
                      context.appColors.surfaceVariant.withOpacity(0.5),
                      context.appColors.background,
                    ],
                  ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              alignment: Alignment.center,
              child: Text(
                pick.positionName,
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        player.webName,
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (pick.isCaptain)
                        Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: _Badge('C', context.appColors.primary),
                        ),
                      if (pick.isViceCaptain)
                        Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: _Badge('V', context.appColors.textSecondary),
                        ),
                    ],
                  ),
                  Text(
                    '${stats.minutes} mins played',
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalPts pts',
                  style: TextStyle(
                    color:
                        pick.isStarting
                            ? context.appColors.electricBlue
                            : context.appColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stats.bonus > 0)
                  Text(
                    '${stats.bonus} Bonus',
                    style: TextStyle(
                      color: context.appColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String t;
  final Color c;
  const _Badge(this.t, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
