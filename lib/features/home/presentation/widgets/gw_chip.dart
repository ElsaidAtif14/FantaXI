import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';

class GwChip extends StatelessWidget {
  const GwChip({super.key, required this.manager});

  final FantasyManagerModel manager;

  @override
  Widget build(BuildContext context) {
    final points = manager.eventPoints;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.lineupMint.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(
            Icons.trending_up_rounded,
            size: 12,
            color: context.appColors.lineupMint,
          ),
          const SizedBox(width: 5),
          Text(
            'GW${manager.activeGW} ${points >= 0 ? '+' : ''}$points PTS',
            style:  TextStyle(
              color: context.appColors.lineupMint,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .25,
            ),
          ),
        ],
      ),
    );
  }
}
