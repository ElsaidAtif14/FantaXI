import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/presentation/widgets/player_details_bottom_sheet.dart';
import 'package:flutter/material.dart';

class PlayerPitchIcon extends StatelessWidget {
  final PlayerModel player;
  final TeamPick pick;
  final bool isBench;
  final int? benchNumber;
  final LiveGWModel? liveData;
  final BootstrapModel? bootstrap;

  const PlayerPitchIcon({
    super.key,
    required this.player,
    required this.pick,
    this.isBench = false,
    this.benchNumber,
    this.liveData,
    this.bootstrap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredWidth = isBench ? 66.0 : 60.0;
        final cardWidth =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth.clamp(38.0, preferredWidth).toDouble()
                : preferredWidth;
        final portraitSize = (cardWidth - 12).clamp(30.0, 44.0).toDouble();
        final livePlayer = liveData?.getPlayer(player.id);
        final basePoints = livePlayer?.stats.totalPoints ?? player.eventPoints;
        final points = basePoints * pick.multiplier;
        final teamShortName = bootstrap?.getTeam(player.team)?.shortName;

        return SizedBox(
          width: cardWidth,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showDetails(context, livePlayer),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: portraitSize + 4,
                    height: portraitSize + 4,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.lineupControl,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color:
                                    pick.isCaptain || pick.isViceCaptain
                                        ? AppColors.lineupLavender
                                        : AppColors.lineupPitchLine,
                              ),
                              boxShadow:
                                  pick.isCaptain || pick.isViceCaptain
                                      ? [
                                        BoxShadow(
                                          color: AppColors.lineupPurple
                                              .withValues(alpha: .32),
                                          blurRadius: 9,
                                        ),
                                      ]
                                      : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildPlayerImage(
                                player.imageUrls,
                                portraitSize,
                              ),
                            ),
                          ),
                        ),
                        if (pick.isCaptain || pick.isViceCaptain)
                          Positioned(
                            top: 1,
                            right: 1,
                            child: _MiniBadge(
                              label: pick.isCaptain ? 'C' : 'V',
                              color: AppColors.lineupPurple,
                            ),
                          ),
                        if (isBench && benchNumber != null)
                          Positioned(
                            top: 1,
                            left: 1,
                            child: _MiniBadge(
                              label: '$benchNumber',
                              color: AppColors.lineupControl,
                            ),
                          ),
                        if (teamShortName != null)
                          Positioned(
                            bottom: 1,
                            left: 1,
                            child: _MiniBadge(
                              label: teamShortName,
                              color: AppColors.lineupMint,
                              textColor: AppColors.lineupBackground,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.webName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.lineupText,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isBench
                              ? AppColors.lineupControl.withValues(alpha: .85)
                              : AppColors.lineupBackground.withValues(
                                alpha: .88,
                              ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '$points pts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isBench
                                ? AppColors.lineupTextSecondary
                                : AppColors.lineupMint,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, ElementLiveModel? livePlayer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => PlayerDetailsBottomSheet(
            player: player,
            pick: pick,
            elementLive: livePlayer,
            bootstrap: bootstrap,
          ),
    );
  }

  Widget _buildPlayerImage(List<String> urls, double size, [int index = 0]) {
    if (index >= urls.length) {
      return Container(
        width: size,
        height: size,
        color: AppColors.lineupControl,
        child: const Icon(
          Icons.person,
          color: AppColors.lineupTextSecondary,
          size: 20,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder:
          (_, _) => const Center(
            child: Icon(
              Icons.person,
              color: AppColors.lineupTextSecondary,
              size: 20,
            ),
          ),
      errorWidget: (_, _, _) => _buildPlayerImage(urls, size, index + 1),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.color,
    this.textColor = AppColors.lineupText,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: AppColors.lineupBackground),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: TextStyle(
        color: textColor,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
