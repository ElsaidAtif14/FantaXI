import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:flutter/material.dart';

class MarketPlayerTile extends StatelessWidget {
  final PlayerModel player;
  final String teamName;
  final bool selected;
  final VoidCallback onTap;

  const MarketPlayerTile({
    super.key,
    required this.player,
    required this.teamName,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final availabilityColor = player.isAvailable ? AppColors.marketMint : AppColors.warmOrange;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.marketSurface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: selected ? AppColors.marketLavender : AppColors.marketPanelBorder),
          ),
          child: Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _playerImage(player.imageUrls),
              ),
              Positioned(
                bottom: -3,
                left: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.marketLavender, borderRadius: BorderRadius.circular(5)),
                  child: Text(player.positionName, style: const TextStyle(
                    color: AppColors.marketSelectedText, fontSize: 8, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(player.webName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(teamName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.marketHint, fontSize: 9)),
              const SizedBox(height: 3),
              Text('${player.totalPoints} pts', style: const TextStyle(
                color: AppColors.marketMint, fontSize: 8, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(width: 6),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(player.formattedPrice, style: const TextStyle(
                color: AppColors.marketText, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text('Form: ${player.form.toStringAsFixed(1)}', style: const TextStyle(
                color: AppColors.marketMint, fontSize: 8, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(width: 8),
            Container(width: 34, height: 34,
              decoration: BoxDecoration(
                color: selected ? AppColors.marketLavender : AppColors.marketPanel,
                borderRadius: BorderRadius.circular(10)),
              child: Icon(selected ? Icons.check_rounded : Icons.add_rounded,
                color: selected ? AppColors.marketSelectedText : availabilityColor, size: 18)),
          ]),
        ),
      ),
    );
  }

  Widget _portraitFallback() => Container(
    width: 42,
    height: 48,
    color: AppColors.marketControl,
    child: const Icon(Icons.person, color: AppColors.marketHint, size: 24),
  );

  Widget _playerImage(List<String> urls, [int index = 0]) {
    if (index >= urls.length) return _portraitFallback();
    return CachedNetworkImage(
      imageUrl: urls[index],
      width: 42,
      height: 48,
      fit: BoxFit.contain,
      placeholder: (_, _) => _portraitFallback(),
      errorWidget: (_, _, _) => _playerImage(urls, index + 1),
    );
  }
}
