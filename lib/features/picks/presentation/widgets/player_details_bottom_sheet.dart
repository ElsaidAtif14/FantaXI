import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';

class PlayerDetailsBottomSheet extends StatelessWidget {
  final PlayerModel player;
  final TeamPick pick;
  final ElementLiveModel? elementLive;
  final BootstrapModel? bootstrap;

  const PlayerDetailsBottomSheet({
    super.key,
    required this.player,
    required this.pick,
    this.elementLive,
    this.bootstrap,
  });

  @override
  Widget build(BuildContext context) {
    final liveStats = elementLive?.stats;
    int points = (liveStats?.totalPoints ?? 0) * pick.multiplier;
    if (elementLive == null) {
      points = player.eventPoints * pick.multiplier;
    }

    final teamName = bootstrap?.getTeam(player.team)?.name ?? 'Unknown Club';

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPlayerImage(player.imageUrls),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.webName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${player.positionName}  ·  $teamName',
                          style: const TextStyle(
                            color: AppColors.electricBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          player.formattedPrice,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.42),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'GW PTS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$points',
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'SEASON SNAPSHOT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'TOTAL POINTS',
                      '${player.totalPoints}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetric('FORM', player.form.toStringAsFixed(1)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'OWNERSHIP',
                      '${player.selectedByPercent}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetric('PRICE', player.formattedPrice)),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'GAMEWEEK PERFORMANCE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Minutes played',
                liveStats?.minutes.toString() ?? '0',
              ),
              _buildStatRow(
                'Goals scored',
                liveStats?.goalsScored.toString() ?? '0',
              ),
              _buildStatRow('Assists', liveStats?.assists.toString() ?? '0'),
              _buildStatRow(
                'Clean sheets',
                liveStats?.cleanSheets.toString() ?? '0',
              ),
              _buildStatRow('Bonus points', liveStats?.bonus.toString() ?? '0'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerImage(List<String> urls, [int index = 0]) {
    if (index >= urls.length) {
      return const Icon(Icons.sports_soccer, size: 40, color: Colors.white54);
    }

    return CachedNetworkImage(
      imageUrl: urls[index],
      height: 80,
      width: 80,
      fit: BoxFit.contain,
      placeholder:
          (context, url) =>
              const Icon(Icons.sports_soccer, size: 40, color: Colors.white54),
      errorWidget: (context, url, error) => _buildPlayerImage(urls, index + 1),
    );
  }
}
