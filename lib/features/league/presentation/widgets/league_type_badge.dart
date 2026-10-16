
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeagueTypeBadge extends StatelessWidget {
  const LeagueTypeBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .2),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.primary.withValues(alpha: .4)),
    ),
    child: const Text(
      'Mini-League',
      style: TextStyle(
        color: Color(0xFF8B5CF6),
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
