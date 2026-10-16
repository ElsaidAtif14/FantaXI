import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/presentation/widgets/chip_dashboard.dart';
import 'package:fantasy/features/picks/presentation/widgets/formation_actions.dart';
import 'package:fantasy/features/picks/presentation/widgets/manager_summary_cards.dart';
import 'package:fantasy/features/picks/presentation/widgets/pitch_view.dart';
import 'package:fantasy/features/picks/presentation/widgets/squad_empty_state.dart';
import 'package:fantasy/features/picks/presentation/widgets/squad_header.dart';
import 'package:flutter/material.dart';

class SquadContentView extends StatelessWidget {
  const SquadContentView({
    super.key,
    required this.gameweek,
    required this.manager,
    required this.bootstrap,
    required this.picks,
    required this.live,
    this.liveError,
    required this.onPreviousGameweek,
    required this.onNextGameweek,
  });

  final int gameweek;
  final FantasyManagerModel manager;
  final BootstrapModel bootstrap;
  final GameWeekPicksModel? picks;
  final LiveGWModel? live;
  final String? liveError;
  final VoidCallback onPreviousGameweek;
  final VoidCallback onNextGameweek;

  @override
  Widget build(BuildContext context) {
    final startingXI = picks?.startingXI ?? const <TeamPick>[];
    final formation = _StartingFormation.fromPicks(startingXI);
    final played = _playedCount(startingXI);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SquadHeader(
                manager: manager,
                gameweek: gameweek,
                canGoPrevious: gameweek > 1,
                canGoNext: gameweek < manager.currentEvent,
                onPrevious: onPreviousGameweek,
                onNext: onNextGameweek,
              ),
              const SizedBox(height: 8),
              ManagerSummaryCards(
                gameweek: gameweek,
                points: picks?.stats.points,
                overallTotal: picks?.stats.totalPoints,
              ),
              const SizedBox(height: 12),
              FormationActions(
                defenders: formation.defenders,
                midfielders: formation.midfielders,
                forwards: formation.forwards,
                played: played,
                startingCount: startingXI.length,
              ),
              const SizedBox(height: 8),
              _SquadPitch(picks: picks, bootstrap: bootstrap, live: live),
              if (liveError != null) ...[
                const SizedBox(height: 8),
                const SquadEmptyState(
                  message:
                      'Live points could not be refreshed. Showing points from the picks data.',
                ),
              ],
              const SizedBox(height: 12),
              ChipDashboard(picks: picks),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  int? _playedCount(List<TeamPick> startingXI) {
    final liveData = live;
    if (picks == null || liveData == null) return null;
    return startingXI
        .where(
          (pick) => (liveData.getPlayer(pick.element)?.stats.minutes ?? 0) > 0,
        )
        .length;
  }
}

class _SquadPitch extends StatelessWidget {
  const _SquadPitch({required this.picks, required this.bootstrap, required this.live});

  final GameWeekPicksModel? picks;
  final BootstrapModel bootstrap;
  final LiveGWModel? live;

  @override
  Widget build(BuildContext context) {
    if (picks == null) {
      return const SquadEmptyState(
        message: 'Squad data is unavailable for this gameweek.',
      );
    }
    if (picks!.picks.isEmpty) return const SquadEmptyState();
    return PitchView(picksModel: picks!, bootstrap: bootstrap, liveData: live);
  }
}

class _StartingFormation {
  const _StartingFormation({
    required this.defenders,
    required this.midfielders,
    required this.forwards,
  });

  final int defenders;
  final int midfielders;
  final int forwards;

  factory _StartingFormation.fromPicks(List<TeamPick> picks) =>
      _StartingFormation(
        defenders: picks.where((pick) => pick.elementType == 2).length,
        midfielders: picks.where((pick) => pick.elementType == 3).length,
        forwards: picks.where((pick) => pick.elementType == 4).length,
      );
}
