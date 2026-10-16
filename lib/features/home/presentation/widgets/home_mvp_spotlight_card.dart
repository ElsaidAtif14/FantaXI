import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:flutter/material.dart';

class HomeMvpSpotlightCard extends StatelessWidget {
  const HomeMvpSpotlightCard({
    super.key,
    required this.gameweek,
    this.picks,
    this.bootstrap,
    this.liveData,
    this.isLoading = false,
    this.unavailableMessage,
  });

  final int gameweek;
  final GameWeekPicksModel? picks;
  final BootstrapModel? bootstrap;
  final LiveGWModel? liveData;
  final bool isLoading;
  final String? unavailableMessage;

  _MvpPlayer? _getMvp() {
    final currentPicks = picks;
    final players = bootstrap;
    final currentLiveData = liveData;
    if (currentPicks == null || players == null || currentLiveData == null) {
      return null;
    }

    _MvpPlayer? mvp;
    for (final pick in currentPicks.picks) {
      if (pick.multiplier == 0) continue;

      final player = players.getPlayer(pick.element);
      final stats = currentLiveData.getPlayer(pick.element)?.stats;
      if (player == null || stats == null) continue;

      final points = stats.totalPoints * pick.multiplier;
      if (mvp == null || points > mvp.points) {
        mvp = _MvpPlayer(
          name: player.webName,
          points: points,
          isCaptain: pick.multiplier > 1,
        );
      }
    }
    return mvp;
  }

  @override
  Widget build(BuildContext context) {
    final mvp = _getMvp();
    final subtitle =
        isLoading
            ? 'Loading live points…'
            : unavailableMessage ??
                (mvp == null
                    ? 'Live points are not available yet'
                    : '${mvp.points} Pts${mvp.isCaptain ? ' · Captain haul' : ' · Live points'}');

    return AspectRatio(
      aspectRatio: 2.12,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/stadium_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'GAMEWEEK $gameweek MVP',
                              style: TextStyle(
                                color: Color(0xFFC084FC),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mvp?.name ?? 'Your Gameweek MVP',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF4ADE80),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1F2937).withOpacity(0.8),
                          border: Border.all(
                            color: const Color(0xFF374151),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFC084FC),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MvpPlayer {
  const _MvpPlayer({
    required this.name,
    required this.points,
    required this.isCaptain,
  });

  final String name;
  final int points;
  final bool isCaptain;
}
