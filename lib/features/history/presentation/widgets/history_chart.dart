import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryChart extends StatelessWidget {
  const HistoryChart({
    super.key,
    required this.history,
    required this.selectedGameweek,
    required this.onGameweekSelected,
  });

  final ManagerHistoryModel history;
  final int? selectedGameweek;
  final ValueChanged<int> onGameweekSelected;

  @override
  Widget build(BuildContext context) {
    final events = [...history.currentSeason]
      ..sort((a, b) => a.event.compareTo(b.event));
    final rankedEvents =
        events.where((event) => event.overallRank > 0).toList();
    final selected = events.where((event) => event.event == selectedGameweek);
    final selectedEvent = selected.isEmpty ? null : selected.first;
    final ranks = rankedEvents.map((event) => event.overallRank).toList();
    final bestRank = ranks.isEmpty ? 0 : ranks.reduce((a, b) => a < b ? a : b);
    final worstRank = ranks.isEmpty ? 0 : ranks.reduce((a, b) => a > b ? a : b);
    final rankRange = worstRank - bestRank;
    final spots =
        rankedEvents
            .map(
              (event) => FlSpot(
                event.event.toDouble(),
                rankRange == 0 ? 1 : (worstRank - event.overallRank).toDouble(),
              ),
            )
            .toList();
    final currentRank = selectedEvent?.overallRank ?? 0;
    final previousEvents =
        events
            .where((event) => event.event < (selectedEvent?.event ?? 0))
            .toList();
    final previousRank =
        previousEvents.isEmpty ? null : previousEvents.last.overallRank;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.lineupSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT GAMEWEEK RANK',
                      style: TextStyle(
                        color: context.appColors.lineupTextSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentRank == 0 ? '—' : _formatRank(currentRank),
                          style: TextStyle(
                            color: context.appColors.lineupText,
                            fontSize: 27,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.6,
                          ),
                        ),
                        if (previousRank != null && previousRank > 0) ...[
                          const SizedBox(width: 8),
                          Icon(
                            currentRank < previousRank
                                ? Icons.trending_up_rounded
                                : currentRank > previousRank
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded,
                            size: 14,
                            color:
                                currentRank < previousRank
                                    ? context.appColors.lineupMint
                                    : currentRank > previousRank
                                    ? const Color(0xFFFFB4AB)
                                    : context.appColors.lineupTextSecondary,
                          ),
                          Text(
                            _formatRank((currentRank - previousRank).abs()),
                            style: TextStyle(
                              color:
                                  currentRank < previousRank
                                      ? context.appColors.lineupMint
                                      : const Color(0xFFFFB4AB),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (selectedEvent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.lineupControl,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: context.appColors.lineupMint,
                        size: 7,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'GW${selectedEvent.event} Selected',
                        style: TextStyle(
                          color: context.appColors.lineupText,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (spots.isEmpty)
            SizedBox(
              height: 176,
              child: Center(
                child: Text(
                  'Rank history is not available',
                  style: TextStyle(
                    color: context.appColors.lineupTextSecondary,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  minX: spots.first.x,
                  maxX:
                      spots.last.x == spots.first.x
                          ? spots.first.x + 1
                          : spots.last.x,
                  minY: 0,
                  maxY: rankRange == 0 ? 2 : rankRange.toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        rankRange == 0 ? 1 : (rankRange / 2).toDouble(),
                    getDrawingHorizontalLine:
                        (_) => const FlLine(
                          color: Color(0x33494454),
                          strokeWidth: 1,
                          dashArray: [3, 4],
                        ),
                  ),
                  titlesData: const FlTitlesData(
                    show: false,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems:
                          (spots) =>
                              spots.map((spot) {
                                final event = rankedEvents.firstWhere(
                                  (item) => item.event == spot.x.toInt(),
                                );
                                return LineTooltipItem(
                                  'GW${event.event} · ${_formatRank(event.overallRank)}',
                                  TextStyle(
                                    color: context.appColors.lineupText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }).toList(),
                    ),
                    touchCallback: (event, response) {
                      final chartSpots = response?.lineBarSpots;
                      if (!event.isInterestedForInteractions ||
                          chartSpots == null ||
                          chartSpots.isEmpty) {
                        return;
                      }
                      onGameweekSelected(chartSpots.first.x.toInt());
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: context.appColors.lineupMint,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, _, _, _) => FlDotCirclePainter(
                              radius:
                                  spot.x.toInt() == selectedGameweek ? 4 : 2.5,
                              color:
                                  spot.x.toInt() == selectedGameweek
                                      ? context.appColors.lineupLavender
                                      : context.appColors.lineupMint,
                              strokeWidth:
                                  spot.x.toInt() == selectedGameweek ? 2 : 0,
                              strokeColor: context.appColors.lineupSurface,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            context.appColors.lineupPurple.withValues(
                              alpha: .3,
                            ),
                            context.appColors.lineupPurple.withValues(alpha: 0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final event in events)
                    InkWell(
                      onTap: () => onGameweekSelected(event.event),
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: events.length > 8 ? 42 : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 4,
                          ),
                          child: Text(
                            'GW${event.event}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  event.event == selectedGameweek
                                      ? context.appColors.lineupLavender
                                      : context.appColors.lineupTextSecondary,
                              fontSize: 9,
                              fontWeight:
                                  event.event == selectedGameweek
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatRank(int rank) {
    if (rank >= 1000000) return '${(rank / 1000000).toStringAsFixed(1)}M';
    if (rank >= 1000) return '${(rank / 1000).toStringAsFixed(1)}K';
    return rank.toString();
  }
}
