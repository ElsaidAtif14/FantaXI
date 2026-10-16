import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/presentation/widgets/substitutes_bench.dart';
import 'package:fantasy/features/picks/presentation/widgets/tactical_pitch_field.dart';
import 'package:flutter/material.dart';

/// Composes the starting XI pitch and substitutes for the selected gameweek.
class PitchView extends StatelessWidget {
  final GameWeekPicksModel picksModel;
  final BootstrapModel bootstrap;
  final LiveGWModel? liveData;

  const PitchView({
    super.key,
    required this.picksModel,
    required this.bootstrap,
    this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    if (picksModel.picks.isEmpty) return const _EmptyPitch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TacticalPitchField(
          picks: picksModel.startingXI,
          bootstrap: bootstrap,
          liveData: liveData,
        ),
        if (picksModel.bench.isNotEmpty) ...[
          const SizedBox(height: 10),
          SubstitutesBench(
            picks: picksModel.bench,
            benchPoints: picksModel.stats.pointsOnBench,
            bootstrap: bootstrap,
            liveData: liveData,
          ),
        ],
      ],
    );
  }
}

class _EmptyPitch extends StatelessWidget {
  const _EmptyPitch();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.lineupPitchBottom,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.lineupPitchLine),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.sports_soccer_rounded,
          color: AppColors.lineupMint,
          size: 28,
        ),
        SizedBox(height: 8),
        Text(
          'No squad picks for this gameweek',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.lineupTextSecondary, fontSize: 11),
        ),
      ],
    ),
  );
}
