
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class LeagueTypeBadge extends StatelessWidget {
  const LeagueTypeBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: context.appColors.primary.withValues(alpha: .2),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: context.appColors.primary.withValues(alpha: .4)),
    ),
    child: Text(
      'Mini-League',
      style: TextStyle(
        color: context.appColors.primary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
