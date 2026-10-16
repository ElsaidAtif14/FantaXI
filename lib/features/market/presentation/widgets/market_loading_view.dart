import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MarketLoadingView extends StatelessWidget {
  const MarketLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
    bottom: false,
    child: Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          _MarketLoadingHeader(),
          _MarketLoadingControls(),
          Expanded(child: _MarketLoadingPlayerList()),
        ],
      ),
    ),
  );
}

class _MarketLoadingHeader extends StatelessWidget {
  const _MarketLoadingHeader();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
    child: Row(
      children: [
        Bone.square(size: 42, borderRadius: BorderRadius.all(Radius.circular(12))),
        SizedBox(width: 12),
        Expanded(child: Bone.text(words: 2, fontSize: 22)),
        Bone.square(size: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
      ],
    ),
  );
}

class _MarketLoadingControls extends StatelessWidget {
  const _MarketLoadingControls();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        Bone(width: double.infinity, height: 44, borderRadius: BorderRadius.all(Radius.circular(14))),
        SizedBox(height: 16),
        Bone(width: double.infinity, height: 38, borderRadius: BorderRadius.all(Radius.circular(12))),
        SizedBox(height: 16),
      ],
    ),
  );
}

class _MarketLoadingPlayerList extends StatelessWidget {
  const _MarketLoadingPlayerList();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    itemCount: 8,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (_, _) => const _MarketLoadingPlayerTile(),
  );
}

class _MarketLoadingPlayerTile extends StatelessWidget {
  const _MarketLoadingPlayerTile();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: AppColors.marketSurface,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      children: [
        Bone(width: 42, height: 48, borderRadius: BorderRadius.all(Radius.circular(10))),
        SizedBox(width: 10),
        Expanded(child: _PlayerDetailsBones()),
        SizedBox(width: 12),
        _PlayerStatsBones(),
        SizedBox(width: 12),
        Bone.square(size: 34, borderRadius: BorderRadius.all(Radius.circular(10))),
      ],
    ),
  );
}

class _PlayerDetailsBones extends StatelessWidget {
  const _PlayerDetailsBones();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Bone.text(words: 2),
      SizedBox(height: 5),
      Bone.text(words: 1, fontSize: 10),
      SizedBox(height: 5),
      Bone.text(words: 2, fontSize: 9),
    ],
  );
}

class _PlayerStatsBones extends StatelessWidget {
  const _PlayerStatsBones();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Bone.text(words: 1),
      SizedBox(height: 6),
      Bone.text(words: 2, fontSize: 9),
    ],
  );
}
