import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class BuildBadge extends StatelessWidget {
  const BuildBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.primary.withOpacity(0.3)),
      ),
      child:  Text(
        '🏆  Fantasy Premier League',
        style: TextStyle(
          color: context.appColors.primaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}