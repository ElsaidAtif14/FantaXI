import 'package:fantasy/core/theme/app_colors.dart';
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
        color: AppColors.lineupMint.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            size: 12,
            color: AppColors.lineupMint,
          ),
          const SizedBox(width: 5),
          Text(
            'GW${manager.activeGW} ${points >= 0 ? '+' : ''}$points PTS',
            style: const TextStyle(
              color: AppColors.lineupMint,
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
