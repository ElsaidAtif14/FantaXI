import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:flutter/material.dart';

class ChipDashboard extends StatelessWidget {
  const ChipDashboard({super.key, required this.picks});

  final GameWeekPicksModel? picks;

  @override
  Widget build(BuildContext context) {
    final activeChip = picks?.activeChip?.toLowerCase();
    return Row(
      children: [
        Expanded(
          child: _ChipCard(
            title: 'Free Transfers',
            value: '— FT',
            detail:
                picks == null
                    ? 'Bank unavailable'
                    : '£${picks!.stats.bank.toStringAsFixed(1)}m in bank',
            accent: AppColors.lineupMint,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ChipCard(
            title: 'Wildcard',
            value: activeChip == 'wildcard' ? 'ACTIVE' : 'Unavailable',
            detail: 'Chip availability unavailable',
            accent: AppColors.lineupLavender,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ChipCard(
            title: 'Triple Captain',
            value: activeChip == '3xc' ? 'ACTIVE' : 'Not active',
            detail:
                activeChip == '3xc'
                    ? 'Active this gameweek'
                    : 'Current gameweek state',
            accent: AppColors.lineupPurple,
          ),
        ),
      ],
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final String title;
  final String value;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 78),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.lineupPanel.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.lineupTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detail,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimary,
            fontSize: 9,
            height: 1.15,
          ),
        ),
      ],
    ),
  );
}
