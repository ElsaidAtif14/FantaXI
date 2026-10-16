import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';

class HomeManagerCard extends StatelessWidget {
  const HomeManagerCard({
    super.key,
    required this.manager,
    this.onRefresh,
    this.onShare,
  });

  final FantasyManagerModel manager;
  final VoidCallback? onRefresh;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final average = manager.totalPlayedGWs == 0
        ? 0.0
        : manager.totalPoints / manager.totalPlayedGWs;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface,
            AppColors.homeMint.withValues(alpha: .13),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withValues(alpha: .8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: .4)),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.primaryLight, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            manager.teamName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Pill(label: 'GW${manager.activeGW}', color: AppColors.primaryLight),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manager.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _IconAction(icon: Icons.refresh_rounded, onPressed: onRefresh, label: 'Refresh manager'),
              const SizedBox(width: 8),
              _IconAction(icon: Icons.share_rounded, onPressed: onShare, label: 'Share manager'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: AppColors.outline),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SEASON TOTAL',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        _Pill(label: 'Rank ${manager.rankFormatted}', color: AppColors.warmOrange),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatPoints(manager.totalPoints),
                              style: theme.textTheme.displayLarge?.copyWith(fontSize: 46, height: 1, color: AppColors.primaryLight),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text('PTS', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                label: '${manager.eventPoints >= 0 ? '+' : ''}${manager.eventPoints} PTS (GW${manager.activeGW})',
                color: AppColors.homeMint,
                prominent: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Avg: ${average.toStringAsFixed(1)}/GW', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              const Icon(Icons.trending_up_rounded, size: 17, color: AppColors.homeMint),
              const SizedBox(width: 3),
              Text('Form', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.homeMint, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatPoints(int points) {
    final digits = points.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return points < 0 ? '-$digits' : digits;
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.prominent = false});

  final String label;
  final Color color;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: prominent ? 12 : 9, vertical: prominent ? 9 : 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: prominent ? .16 : .13),
      borderRadius: BorderRadius.circular(99),
      border: prominent ? Border.all(color: color.withValues(alpha: .55)) : null,
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: prominent ? 12 : 10, fontWeight: FontWeight.w700)),
  );
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onPressed, required this.label});

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: label,
    style: IconButton.styleFrom(
      backgroundColor: AppColors.surfaceVariant,
      foregroundColor: AppColors.textPrimary,
      fixedSize: const Size(40, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    icon: Icon(icon, size: 20),
  );
}
