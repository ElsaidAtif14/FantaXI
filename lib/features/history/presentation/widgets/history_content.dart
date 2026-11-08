import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fantasy/features/history/presentation/widgets/history_chart.dart';
import 'package:fantasy/features/history/presentation/widgets/history_list.dart';
import 'package:fantasy/features/history/presentation/widgets/history_overview.dart';
import 'package:fantasy/features/history/presentation/widgets/history_quick_stats.dart';
import 'package:flutter/widgets.dart';

class HistoryContent extends StatelessWidget {
  const HistoryContent({
    super.key,
    required this.history,
    required this.controller,
    required this.selectedGameweek,
    required this.onGameweekSelected,
  });

  final ManagerHistoryModel history;
  final ScrollController controller;
  final int? selectedGameweek;
  final ValueChanged<int> onGameweekSelected;

  @override
  Widget build(BuildContext context) {
    final matchingEvents = history.currentSeason.where(
      (event) => event.event == selectedGameweek,
    );
    final selectedEvent = matchingEvents.isEmpty ? null : matchingEvents.first;

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryOverview(history: history),
          const SizedBox(height: 16),
          HistoryChart(
            history: history,
            selectedGameweek: selectedGameweek,
            onGameweekSelected: onGameweekSelected,
          ),
          const SizedBox(height: 16),
          HistoryQuickStats(event: selectedEvent),
          const SizedBox(height: 24),
          Row(
            children: [
               Expanded(
                child: Text(
                  'Gameweek Performance',
                  style: TextStyle(
                    color: context.appColors.lineupText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${history.currentSeason.length} played',
                style:  TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HistoryList(
            events: history.currentSeason,
            selectedGameweek: selectedGameweek,
            chips: history.usedChips,
            onGameweekSelected: onGameweekSelected,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
