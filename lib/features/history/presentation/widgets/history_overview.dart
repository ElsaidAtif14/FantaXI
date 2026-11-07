import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fantasy/features/history/presentation/widgets/metric_pill.dart';
import 'package:fantasy/features/history/presentation/widgets/tag.dart';
import 'package:flutter/material.dart';

class HistoryOverview extends StatelessWidget {
  const HistoryOverview({super.key, required this.history});

  final ManagerHistoryModel history;

  @override
  Widget build(BuildContext context) {
    final events = history.currentSeason;
    final bestRank = events.isEmpty
        ? 0
        : events
            .map((event) => event.overallRank)
            .where((rank) => rank > 0)
            .fold<int?>(null, (best, rank) => best == null || rank < best ? rank : best) ?? 0;
    final bestEvent = events.isEmpty
        ? null
        : events.reduce((a, b) => a.points >= b.points ? a : b);
    final firstEvent = events.isEmpty
        ? 0
        : events.map((event) => event.event).reduce((a, b) => a < b ? a : b);
    final lastEvent = events.isEmpty
        ? 0
        : events.map((event) => event.event).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:  BoxDecoration(
                color: context.appColors.lineupMint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
             Expanded(
              child: Text(
                'Overall Rank Trajectory',
                style: TextStyle(
                  color: context.appColors.lineupText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Tag(text: events.isEmpty ? 'No gameweeks' : 'GW $firstEvent - GW $lastEvent'),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              MetricPill(
                icon: Icons.trending_up_rounded,
                label: 'Best Rank',
                value: bestRank == 0 ? '—' : _formatRank(bestRank),
                valueColor: context.appColors.lineupMint,
              ),
              const SizedBox(width: 8),
              MetricPill(
                icon: Icons.bolt_rounded,
                label: 'Avg Points',
                value: history.averagePoints.toStringAsFixed(1),
                valueColor: context.appColors.lineupLavender,
              ),
              const SizedBox(width: 8),
              MetricPill(
                icon: Icons.star_rounded,
                label: 'Best GW',
                value: bestEvent == null
                    ? '—'
                    : 'GW${bestEvent.event} (${bestEvent.points}p)',
                valueColor: context.appColors.lineupMint,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatRank(int rank) {
    if (rank >= 1000000) return '${(rank / 1000000).toStringAsFixed(1)}M';
    if (rank >= 1000) return '${(rank / 1000).toStringAsFixed(1)}K';
    return rank.toString();
  }
}
