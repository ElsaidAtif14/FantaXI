import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SquadEmptyState extends StatelessWidget {
  const SquadEmptyState({
    super.key,
    this.message = 'No squad picks are available for this gameweek.',
  });

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.lineupPanel,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.lineupTextSecondary,
        fontSize: 11,
      ),
    ),
  );
}
