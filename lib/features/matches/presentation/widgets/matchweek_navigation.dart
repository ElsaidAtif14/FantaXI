import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class MatchweekNavigation extends StatelessWidget {
  const MatchweekNavigation({
    super.key,
    required this.gameweek,
    required this.maxGameweek,
    required this.onPrevious,
    required this.onNext,
    this.enabled = true,
    this.loading = false,
    this.subtitle,
  });

  final int? gameweek;
  final int? maxGameweek;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool enabled;
  final bool loading;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final selectedGameweek = gameweek;
    final lastGameweek = maxGameweek;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.lineupSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous matchweek',
            onPressed:
                enabled && selectedGameweek != null && selectedGameweek > 1
                    ? onPrevious
                    : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  selectedGameweek == null
                      ? loading
                          ? 'Loading matchweek'
                          : 'Matchweek unavailable'
                      : 'Matchweek $selectedGameweek',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null || !enabled)
                  Text(
                    subtitle ?? 'Premier League',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next matchweek',
            onPressed:
                enabled &&
                        lastGameweek != null &&
                        selectedGameweek != null &&
                        selectedGameweek < lastGameweek
                    ? onNext
                    : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
