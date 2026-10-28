import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeaguesHubEmptyState extends StatelessWidget {
  const LeaguesHubEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 34),
    child: Column(
      children: [
        const Icon(
          Icons.search_off_rounded,
          color: AppColors.lineupTextSecondary,
          size: 28,
        ),
        const SizedBox(height: 8),
        const Text(
          'No leagues match this search.',
          style: TextStyle(color: AppColors.lineupTextSecondary),
        ),
      ],
    ),
  );
}
