
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class RoundAction extends StatelessWidget {
  const RoundAction({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.leagueBadgeBackground,
      shape: CircleBorder(
        side: BorderSide(color: context.appColors.leagueCardBorder),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: context.appColors.leagueText,
            size: 20,
          ),
        ),
      ),
    );
  }
}