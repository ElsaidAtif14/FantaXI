import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/league/presentation/widgets/league_type_badge.dart';
import 'package:fantasy/features/league/presentation/widgets/round_action.dart';
import 'package:flutter/material.dart';

class LeagueHeader extends StatelessWidget {
  const LeagueHeader({super.key, 
    required this.name,
    required this.managerCount,
    required this.onBack,
    required this.onShare,
  });

  final String name;
  final int managerCount;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          RoundAction(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.appColors.leagueText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const LeagueTypeBadge(),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '$managerCount Managers • League Standings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.appColors.leagueSecondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          RoundAction(icon: Icons.ios_share_rounded, onTap: onShare),
        ],
      ),
    );
  }
}