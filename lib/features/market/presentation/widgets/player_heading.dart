import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:flutter/material.dart';

class PlayerHeading extends StatelessWidget {
  final PlayerModel player;
  final String teamName;
  const PlayerHeading({super.key, required this.player, this.teamName = ''});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _playerImage(player.imageUrls),
          ),
          const SizedBox(height: 3),
          Text(
            player.webName,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          if (teamName.isNotEmpty)
            Text(teamName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.marketText, fontSize: 8)),
          Text(
            '£${(player.nowCost / 10).toStringAsFixed(1)}m · ${player.positionName}',
            style: const TextStyle(color: AppColors.marketMint, fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _playerImage(List<String> urls, [int index = 0]) {
    if (index >= urls.length) {
      return Container(
        width: 32,
        height: 34,
        color: AppColors.marketControl,
        child: const Icon(Icons.person, color: AppColors.marketHint, size: 20),
      );
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      width: 32,
      height: 34,
      fit: BoxFit.contain,
      placeholder: (_, _) => Container(
        width: 32,
        height: 34,
        color: AppColors.marketControl,
        child: const Icon(Icons.person, color: AppColors.marketHint, size: 20),
      ),
      errorWidget: (_, _, _) => _playerImage(urls, index + 1),
    );
  }
}
