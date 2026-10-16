import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/market/presentation/widgets/comparison_row.dart';
import 'package:fantasy/features/market/presentation/widgets/player_heading.dart';
import 'package:flutter/material.dart';

class MarketDockedComparisonPanel extends StatelessWidget {
  const MarketDockedComparisonPanel({
    required this.players,
    required this.expanded,
    required this.teamNames,
    required this.onToggleExpanded,
    required this.onRemove,
    super.key,
  });

  final List<PlayerModel> players;
  final Map<int, String> teamNames;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<PlayerModel> onRemove;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .48;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
        decoration: BoxDecoration(
          color: AppColors.marketPanel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.marketPanelBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .26),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onToggleExpanded,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 12, 6),
                child: Column(
                  children: [
                    Container(
                      width: 35,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.marketControl,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'TACTICAL MATRIX',
                          style: TextStyle(
                            color: AppColors.marketLavender,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.marketControl,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${players.length}/2 locked',
                            style: const TextStyle(
                              color: AppColors.marketText,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: AppColors.marketText,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarketFaceOffHeader(
                        players: players,
                        teamNames: teamNames,
                        onRemove: onRemove,
                      ),
                      const SizedBox(height: 8),
                      if (players.length == 2) ...[
                        ComparisonRow(
                          label: 'TOTAL POINTS',
                          firstValue: '${players[0].totalPoints}',
                          secondValue: '${players[1].totalPoints}',
                          firstRatio: players[0].totalPoints.toDouble(),
                          secondRatio: players[1].totalPoints.toDouble(),
                        ),
                        ComparisonRow(
                          label: 'FORM RATING',
                          firstValue: players[0].form.toStringAsFixed(1),
                          secondValue: players[1].form.toStringAsFixed(1),
                          firstRatio: players[0].form,
                          secondRatio: players[1].form,
                        ),
                        ComparisonRow(
                          label: 'OWNERSHIP',
                          firstValue: '${players[0].selectedByPercent}%',
                          secondValue: '${players[1].selectedByPercent}%',
                          firstRatio:
                              double.tryParse(players[0].selectedByPercent) ?? 0,
                          secondRatio:
                              double.tryParse(players[1].selectedByPercent) ?? 0,
                        ),
                        ComparisonRow(
                          label: 'LAST GW PTS',
                          firstValue: '${players[0].eventPoints} pts',
                          secondValue: '${players[1].eventPoints} pts',
                          firstRatio: players[0].eventPoints.toDouble(),
                          secondRatio: players[1].eventPoints.toDouble(),
                        ),
                        const ComparisonRow(
                          label: 'EXPECTED GOALS/ASSISTS',
                          firstValue: '—',
                          secondValue: '—',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: FilledButton.icon(
                            onPressed: null,
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 17,
                            ),
                            label: const Text(
                              'Confirm Transfer Switch',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.marketMint,
                              disabledBackgroundColor: AppColors.marketMint
                                  .withValues(alpha: .78),
                              disabledForegroundColor: AppColors.marketBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Transfer management is not supported by this app yet',
                          style: TextStyle(
                            color: AppColors.marketText,
                            fontSize: 9,
                          ),
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Select one more player to compare',
                            style: TextStyle(
                              color: AppColors.marketText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MarketFaceOffHeader extends StatelessWidget {
  const MarketFaceOffHeader({
    required this.players,
    required this.teamNames,
    required this.onRemove,
    super.key,
  });

  final List<PlayerModel> players;
  final Map<int, String> teamNames;
  final ValueChanged<PlayerModel> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.marketBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var index = 0; index < 2; index++) ...[
            if (index == 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.marketLavender.withValues(alpha: .16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    size: 14,
                    color: AppColors.marketLavender,
                  ),
                ),
              ),
            Expanded(
              child:
                  index < players.length
                      ? InkWell(
                        onTap: () => onRemove(players[index]),
                        child: PlayerHeading(
                          player: players[index],
                          teamName: teamNames[players[index].id] ?? '',
                        ),
                      )
                      : const MarketEmptyComparisonSlot(),
            ),
          ],
        ],
      ),
    );
  }
}

class MarketEmptyComparisonSlot extends StatelessWidget {
  const MarketEmptyComparisonSlot({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      Text(
        'Add player',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      Text(
        'Choose from market',
        style: TextStyle(color: AppColors.textMuted, fontSize: 8),
      ),
    ],
  );
}
