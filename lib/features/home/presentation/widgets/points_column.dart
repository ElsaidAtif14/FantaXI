import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';

class PointsColumn extends StatelessWidget {
  const PointsColumn({super.key, required this.manager});

  final FantasyManagerModel manager;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SEASON TOTAL',
          style: TextStyle(
            color: Color(0xFF958EA0),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatPoints(manager.totalPoints),
              style:  TextStyle(
                color: context.appColors.lineupText,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(width: 6),
             Text(
              'PTS',
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPoints(int points) {
    final digits = points.abs().toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return points < 0 ? '-$grouped' : grouped;
  }
}
