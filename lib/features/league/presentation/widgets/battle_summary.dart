import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/presentation/widgets/points_gap.dart';
import 'package:fantasy/features/league/presentation/widgets/position_info.dart';
import 'package:fantasy/features/league/presentation/widgets/stat_pill.dart';
import 'package:fantasy/features/league/presentation/widgets/summary_tab.dart';
import 'package:flutter/material.dart';

class BattleSummary extends StatelessWidget {
  const BattleSummary({super.key, 
    required this.standings,
    required this.current,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final List<LeagueStanding> standings;
  final LeagueStanding? current;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final ordered = [...standings]..sort((a, b) => a.rank.compareTo(b.rank));
    final leader = ordered.isEmpty ? null : ordered.first;
    final average = standings.isEmpty
        ? 0
        : (standings.fold<int>(0, (sum, item) => sum + item.eventTotal) /
                  standings.length)
              .round();
    final pointsBehind = current == null || leader == null
        ? null
        : (leader.totalPoints - current!.totalPoints)
              .clamp(0, 1 << 30)
              .toInt();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF161B2E), Color(0xFF101423), Color(0xFF0B0E17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x41000000),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'LEAGUE STANDINGS',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
              ),
              StatPill(label: 'AVG: $average pts'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0x1AFFFFFF)),
          ),
          Row(
            children: [
              Expanded(
                child: PositionInfo(
                  label: 'YOUR POSITION',
                  value: current == null ? '—' : '#${current!.rank}',
                  detail: current?.playerName,
                ),
              ),
              const SizedBox(width: 8),
              PointsGap(pointsBehind: pointsBehind),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xCC07090E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: .05)),
            ),
            child: Row(
              children: [
                SummaryTab(
                  title: 'Overall Standings',
                  selected: selectedTab == 0,
                  onTap: () => onTabChanged(0),
                ),
                SummaryTab(
                  title: 'Gameweek Points',
                  selected: selectedTab == 1,
                  onTap: () => onTabChanged(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}