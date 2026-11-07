import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';

class TitleColumn extends StatelessWidget {
  const TitleColumn({super.key, required this.manager});

  final FantasyManagerModel manager;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          manager.teamName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(
            color: context.appColors.lineupText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          manager.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
