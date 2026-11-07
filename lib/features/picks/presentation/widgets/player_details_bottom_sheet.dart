import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        gradient: context.appColors.cardGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border:  Border(top: BorderSide(color: context.appColors.outline)),
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
                  _buildPlayerImage(context, player.imageUrls),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.webName,
                          style:  TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${player.positionName}  ·  $teamName',
                          style:  TextStyle(
                            color: context.appColors.electricBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          player.formattedPrice,
                          style:  TextStyle(
                            color: context.appColors.textSecondary,
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
                      color: context.appColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.appColors.primary.withOpacity(0.42),
                      ),
                    ),
                    child: Column(
                      children: [
                         Text(
                          'GW PTS',
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$points',
                          style:  TextStyle(
                            color: context.appColors.primaryLight,
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
               Text(
                'SEASON SNAPSHOT',
                style: TextStyle(
                  color: context.appColors.textMuted,
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
                      context,
                      'TOTAL POINTS',
                      '${player.totalPoints}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetric(
                      context,
                      'FORM',
                      player.form.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      context,
                      'OWNERSHIP',
                      '${player.selectedByPercent}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetric(context, 'PRICE', player.formattedPrice),
                  ),
                ],
              ),
              const SizedBox(height: 22),
               Text(
                'GAMEWEEK PERFORMANCE',
                style: TextStyle(
                  color: context.appColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context,
                'Minutes played',
                liveStats?.minutes.toString() ?? '0',
              ),
              _buildStatRow(
                context,
                'Goals scored',
                liveStats?.goalsScored.toString() ?? '0',
              ),
              _buildStatRow(
                context,
                'Assists',
                liveStats?.assists.toString() ?? '0',
              ),
              _buildStatRow(
                context,
                'Clean sheets',
                liveStats?.cleanSheets.toString() ?? '0',
              ),
              _buildStatRow(
                context,
                'Bonus points',
                liveStats?.bonus.toString() ?? '0',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.textSecondary,
                    minimumSize: const Size.fromHeight(48),
                    side:  BorderSide(color: context.appColors.outline),
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

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: context.appColors.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:  TextStyle(
              color: context.appColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style:  TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:  TextStyle(
              color: context.appColors.textSecondary,
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

  Widget _buildPlayerImage(
    BuildContext context,
    List<String> urls, [
    int index = 0,
  ]) {
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
      errorWidget: (context, url, error) =>
          _buildPlayerImage(context, urls, index + 1),
    );
  }
}
