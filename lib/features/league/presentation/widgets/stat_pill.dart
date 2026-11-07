
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: context.appColors.leagueBadgeBackground,
      border: Border.all(color: context.appColors.leagueBadgeBorder),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: context.appColors.leagueBadgeText,
        fontSize: 10,
      ),
    ),
  );
}