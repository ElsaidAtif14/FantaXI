import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/history/data/models/chip_usage.dart';
import 'package:fantasy/features/history/data/models/event_history.dart';
import 'package:fantasy/features/history/presentation/widgets/gw_badge.dart';
import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.events,
    required this.selectedGameweek,
    required this.chips,
    required this.onGameweekSelected,
  });

  final List<EventHistory> events;
  final List<ChipUsage> chips;
  final int? selectedGameweek;
  final ValueChanged<int> onGameweekSelected;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return  Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No gameweek history available',
            style: TextStyle(color: context.appColors.lineupTextSecondary),
          ),
        ),
      );
    }

    final newestFirst = [...events]..sort((a, b) => b.event.compareTo(a.event));
    final bestPoints = events
        .map((event) => event.points)
        .fold<int>(0, (best, points) => points > best ? points : best);

    return Column(
      children: [
        for (final event in newestFirst)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _GameweekCard(
              event: event,
              isSelected: event.event == selectedGameweek,
              bestPoints: bestPoints,
              chip: _chipForEvent(chips, event.event),
              onTap: () => onGameweekSelected(event.event),
            ),
          ),
      ],
    );
  }

  ChipUsage? _chipForEvent(List<ChipUsage> chips, int gameweek) {
    for (final chip in chips) {
      if (chip.event == gameweek) return chip;
    }
    return null;
  }
}

class _GameweekCard extends StatelessWidget {
  const _GameweekCard({
    required this.event,
    required this.isSelected,
    required this.bestPoints,
    required this.chip,
    required this.onTap,
  });

  final EventHistory event;
  final bool isSelected;
  final int bestPoints;
  final ChipUsage? chip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = bestPoints <= 0 ? 0.0 : event.points / bestPoints;
    final rank = event.overallRank;
    final gameweekChip = chip;

    return Material(
      color: context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? context.appColors.lineupPurple.withValues(alpha: .7)
                      : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.appColors.lineupSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          'GW',
                          style: TextStyle(
                            color: context.appColors.lineupTextSecondary,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          event.event.toString().padLeft(2, '0'),
                          style:  TextStyle(
                            color: context.appColors.lineupText,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 3,
                          children: [
                            Text(
                              '${event.points} Points',
                              style:  TextStyle(
                                color: context.appColors.lineupText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (gameweekChip != null)
                              GWBadge(
                                text: _chipName(gameweekChip.name),
                                color: context.appColors.lineupMint,
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Global Rank: ${rank > 0 ? _formatRank(rank) : '-'} | Bench: ${event.pointsOnBench} pts',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(
                            color: context.appColors.lineupTextSecondary,
                            fontSize: 10,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GWBadge(
                        text: '${event.transfers} Transfers',
                        color: context.appColors.lineupTextSecondary,
                        background: context.appColors.lineupBackground,
                      ),
                      if (event.transfersCost > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '-${event.transfersCost} hit pts',
                          style: const TextStyle(
                            color: Color(0xFFFFB4AB),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0).toDouble(),
                  minHeight: 5,
                  backgroundColor: context.appColors.lineupBackground,
                  valueColor:  AlwaysStoppedAnimation(
                    context.appColors.lineupMint,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${event.totalPoints} pts',
                    style:  TextStyle(
                      color: context.appColors.lineupTextSecondary,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    isSelected ? 'Selected' : 'GW ${event.event}',
                    style: TextStyle(
                      color:
                          isSelected
                              ? context.appColors.lineupLavender
                              : context.appColors.lineupTextSecondary,
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
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

  static String _chipName(String name) {
    switch (name) {
      case 'wildcard':
        return 'Wildcard';
      case 'freehit':
        return 'Free Hit';
      case 'bboost':
        return 'Bench Boost';
      case '3xc':
        return 'Triple Captain';
      default:
        return name;
    }
  }
}
