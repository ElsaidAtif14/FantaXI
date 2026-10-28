import 'package:fantasy/core/theme/app_colors.dart';
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
      color: AppColors.lineupPanel,
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
                  color: AppColors.lineupLavender.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.lineupLavender,
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
                            style: const TextStyle(
                              color: AppColors.lineupText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const LeagueBadge(
                          label: 'INVITATIONAL',
                          color: AppColors.lineupLavender,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vs ${cup.opponentName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.lineupTextSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${cup.myPoints} pts  •  ${cup.opponentPoints} pts',
                      style: const TextStyle(
                        color: AppColors.lineupLavender,
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
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: AppColors.lineupTextSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'GW ${cup.event}',
                    style: const TextStyle(
                      color: AppColors.lineupText,
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
