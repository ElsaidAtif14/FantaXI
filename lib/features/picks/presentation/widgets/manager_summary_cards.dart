import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ManagerSummaryCards extends StatelessWidget {
  const ManagerSummaryCards({
    super.key,
    required this.gameweek,
    required this.points,
    required this.overallTotal,
  });

  final int gameweek;
  final int? points;
  final int? overallTotal;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _SummaryCard(
          label: 'Gameweek Pts',
          value: points?.toString() ?? '—',
          suffix: 'pts',
          valueColor: AppColors.lineupMint,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _SummaryCard(
          label: 'Overall Total',
          value: overallTotal?.toString() ?? '—',
          suffix: 'pts',
          valueColor: AppColors.lineupText,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _SummaryCard(
          label: 'GW $gameweek Deadline',
          value: '—',
          suffix: 'Deadline unavailable',
          valueColor: AppColors.lineupLavender,
          icon: Icons.schedule_rounded,
        ),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.valueColor,
    this.icon,
  });

  final String label;
  final String value;
  final String suffix;
  final Color valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 70),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.lineupPanel.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.lineupTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: valueColor),
              const SizedBox(width: 2),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ),
            if (suffix == 'pts') ...[
              const SizedBox(width: 2),
              Text(
                suffix,
                style: TextStyle(
                  color: valueColor.withValues(alpha: .8),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        if (suffix != 'pts')
          Text(
            suffix,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.textPrimary,
              fontSize: 9,
            ),
          ),
      ],
    ),
  );
}
