import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/home/presentation/widgets/league_badge.dart';
import 'package:fantasy/features/manager/data/models/cup_match_model.dart';
import 'package:flutter/material.dart';

class LeaguesHubCupMatchCard extends StatelessWidget {
  const LeaguesHubCupMatchCard({
    required this.cup,
    required this.onTap,
    super.key,
  });

  final CupMatchModel cup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.appColors.lineupLavender.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child:  Icon(
                  Icons.emoji_events_rounded,
                  color: context.appColors.lineupLavender,
                  size: 23,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cup.knockoutName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:  TextStyle(
                              color: context.appColors.lineupText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                         LeagueBadge(
                          label: 'INVITATIONAL',
                          color: context.appColors.lineupLavender,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vs ${cup.opponentName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        color: context.appColors.lineupTextSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${cup.myPoints} pts  •  ${cup.opponentPoints} pts',
                      style:  TextStyle(
                        color: context.appColors.lineupLavender,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: context.appColors.lineupTextSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'GW ${cup.event}',
                    style:  TextStyle(
                      color: context.appColors.lineupText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
