import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SquadLoadingView extends StatelessWidget {
  const SquadLoadingView({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: true,
    child: SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Bone.square(
                size: 28,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Bone.text(width: 110), Bone.text(width: 84)],
                ),
              ),
              Bone.button(
                width: 82,
                height: 30,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(child: _SummaryBone()),
              SizedBox(width: 8),
              Expanded(child: _SummaryBone()),
              SizedBox(width: 8),
              Expanded(child: _SummaryBone()),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Bone.button(width: 112, height: 25),
              SizedBox(width: 8),
              Bone.text(width: 66),
              Spacer(),
              Bone.iconButton(size: 28),
              SizedBox(width: 6),
              Bone.iconButton(size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: context.appColors.lineupPitchMiddle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                _PlayerRowBone(count: 1),
                SizedBox(height: 15),
                _PlayerRowBone(count: 4),
                SizedBox(height: 15),
                _PlayerRowBone(count: 4),
                SizedBox(height: 15),
                _PlayerRowBone(count: 2),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.appColors.lineupPanel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BenchBone(),
                _BenchBone(),
                _BenchBone(),
                _BenchBone(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _ChipBone()),
              SizedBox(width: 8),
              Expanded(child: _ChipBone()),
              SizedBox(width: 8),
              Expanded(child: _ChipBone()),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

class _SummaryBone extends StatelessWidget {
  const _SummaryBone();

  @override
  Widget build(BuildContext context) => Container(
    height: 70,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Bone.text(width: 50),
        SizedBox(height: 5),
        Bone.text(width: 42),
      ],
    ),
  );
}

class _PlayerRowBone extends StatelessWidget {
  const _PlayerRowBone({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Bone.text(width: 64),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            const _PlayerBone(),
          ],
        ],
      ),
    ],
  );
}

class _PlayerBone extends StatelessWidget {
  const _PlayerBone();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 54,
    child: Column(
      children: [
        Bone.circle(size: 35),
        SizedBox(height: 4),
        Bone.text(width: 48),
        Bone.text(width: 32),
      ],
    ),
  );
}

class _BenchBone extends StatelessWidget {
  const _BenchBone();

  @override
  Widget build(BuildContext context) => const _PlayerBone();
}

class _ChipBone extends StatelessWidget {
  const _ChipBone();

  @override
  Widget build(BuildContext context) => Container(
    height: 78,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 45),
        SizedBox(height: 6),
        Bone.text(width: 55),
        SizedBox(height: 4),
        Bone.text(width: 62),
      ],
    ),
  );
}
