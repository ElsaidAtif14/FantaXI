import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeaguesHubSortButton extends StatelessWidget {
  const LeaguesHubSortButton({
    required this.ascending,
    required this.onPressed,
    super.key,
  });

  final bool ascending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: ascending ? 'Sort by rank ascending' : 'Sort by rank descending',
    child: Material(
      color: AppColors.lineupControl,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            ascending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: AppColors.lineupTextSecondary,
            size: 19,
          ),
        ),
      ),
    ),
  );
}
