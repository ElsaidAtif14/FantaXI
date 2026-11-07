

import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class PointsGap extends StatelessWidget {
  const PointsGap({super.key, required this.pointsBehind});
  final int? pointsBehind;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        'POINTS TO #1',
        style: TextStyle(
          color: context.appColors.leagueSecondaryText,
          fontSize: 10,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: context.appColors.leagueIconTeal.withValues(alpha: .1),
          border: Border.all(
            color: context.appColors.leagueIconTeal.withValues(alpha: .2),
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          pointsBehind == null ? '— pts' : '-$pointsBehind pts',
          style: TextStyle(
            color: context.appColors.leagueIconTeal,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}
