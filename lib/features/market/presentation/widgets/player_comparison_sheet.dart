import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/market/presentation/widgets/comparison_row.dart';
import 'package:fantasy/features/market/presentation/widgets/player_heading.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class PlayerComparisonSheet extends StatelessWidget {
   final List<PlayerModel> players;
  const PlayerComparisonSheet({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
     final first = players[0];
    final second = players[1];

    return Container(
      decoration: BoxDecoration(
        gradient: context.appColors.cardGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border:  Border(top: BorderSide(color: context.appColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                'PLAYER COMPARISON',
                style: TextStyle(
                  color: context.appColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: PlayerHeading(player: first)),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      color: context.appColors.primaryLight,
                    ),
                  ),
                  Expanded(child: PlayerHeading(player: second)),
                ],
              ),
              const SizedBox(height: 18),
              ComparisonRow(
                label: 'Total points',
                firstValue: '${first.totalPoints}',
                secondValue: '${second.totalPoints}',
              ),
              ComparisonRow(
                label: 'Current form',
                firstValue: first.form.toStringAsFixed(1),
                secondValue: second.form.toStringAsFixed(1),
              ),
              ComparisonRow(
                label: 'Price',
                firstValue: first.formattedPrice,
                secondValue: second.formattedPrice,
              ),
              ComparisonRow(
                label: 'Ownership',
                firstValue: '${first.selectedByPercent}%',
                secondValue: '${second.selectedByPercent}%',
              ),
              ComparisonRow(
                label: 'Gameweek points',
                firstValue: '${first.eventPoints}',
                secondValue: '${second.eventPoints}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}