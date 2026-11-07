import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/presentation/widgets/player_pitch_icon.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Bench summary and player cards for the currently selected gameweek.
class SubstitutesBench extends StatelessWidget {
  const SubstitutesBench({
    super.key,
    required this.picks,
    required this.benchPoints,
    required this.bootstrap,
    this.liveData,
  });

  final List<TeamPick> picks;
  final int benchPoints;
  final BootstrapModel bootstrap;
  final LiveGWModel? liveData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 10),
      decoration: BoxDecoration(
        color: context.appColors.lineupPanel.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.lineupControl.withValues(alpha: .8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
               Icon(
                Icons.chair_alt_rounded,
                color: context.appColors.lineupLavender,
                size: 15,
              ),
              const SizedBox(width: 6),
               Expanded(
                child: Text(
                  'Substitutes Bench',
                  style: TextStyle(
                    color: context.appColors.lineupText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Bench points: $benchPoints',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
           Divider(height: 1, color: context.appColors.lineupControl),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < picks.length; index++)
                Expanded(
                  child: Center(child: _buildPlayer(picks[index], index)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(TeamPick pick, int index) {
    final player = bootstrap.getPlayer(pick.element);
    if (player == null) return const SizedBox.shrink();
    return PlayerPitchIcon(
      player: player,
      pick: pick,
      isBench: true,
      benchNumber: index + 1,
      liveData: liveData,
      bootstrap: bootstrap,
    );
  }
}
