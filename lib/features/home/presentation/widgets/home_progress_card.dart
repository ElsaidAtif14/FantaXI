import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/shared/widgets/glass_panel.dart';
import 'package:flutter/material.dart';

class HomeProgressCard extends StatelessWidget {
  const HomeProgressCard({super.key, required this.manager});

  final FantasyManagerModel manager;

  @override
  Widget build(BuildContext context) {
    final completedPercent = (manager.seasonCompletion * 100).round();
    final hasPlayedGameweeks = manager.totalPlayedGWs > 0;
    final playedAll = hasPlayedGameweeks && manager.isConsistentPlayer;

    return GlassPanel(
      padding: const EdgeInsets.all(12),
      radius: 12,
      fillColor: context.appColors.lineupSurface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gameweek Progress',
                  style: TextStyle(
                    color: context.appColors.lineupText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'GW ${manager.activeGW} of 38',
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: manager.seasonCompletion,
              backgroundColor: context.appColors.lineupBackground,
              valueColor: AlwaysStoppedAnimation(context.appColors.lineupMint),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completedPercent% Completed  |  ${manager.totalPlayedGWs}/38 played',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.appColors.lineupTextSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _PlayedStatus(
                label:
                    playedAll
                        ? 'All GWs Played'
                        : hasPlayedGameweeks
                        ? 'Missed GWs'
                        : 'No GWs Played',
                isPositive: playedAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayedStatus extends StatelessWidget {
  const _PlayedStatus({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color =
        isPositive
            ? context.appColors.lineupMint
            : context.appColors.lineupLavender;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
