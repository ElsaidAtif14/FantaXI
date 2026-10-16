import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';

class SquadHeader extends StatelessWidget {
  const SquadHeader({
    super.key,
    required this.manager,
    required this.gameweek,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final FantasyManagerModel manager;
  final int gameweek;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.lineupControl,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppColors.lineupLavender,
            size: 15,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                manager.teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.lineupText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'MANAGER: ${manager.fullName.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.lineupTextSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .35,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lineupControl.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GameweekArrow(
                icon: Icons.chevron_left,
                enabled: canGoPrevious,
                onPressed: onPrevious,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  'GW $gameweek',
                  style: const TextStyle(
                    color: AppColors.lineupText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _GameweekArrow(
                icon: Icons.chevron_right,
                enabled: canGoNext,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameweekArrow extends StatelessWidget {
  const _GameweekArrow({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
    padding: EdgeInsets.zero,
    onPressed: enabled ? onPressed : null,
    icon: Icon(icon, size: 16),
    color: AppColors.lineupTextSecondary,
    disabledColor: AppColors.lineupTextSecondary.withValues(alpha: .35),
  );
}
