import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient:  LinearGradient(
                colors: [context.appColors.lineupControl, Color(0xFF32343F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(size * .25),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.lineupLavender.withValues(alpha: .12),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Center(
              child: Text('⚽', style: TextStyle(fontSize: 56)),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: size * .3,
              height: size * .3,
              decoration:  BoxDecoration(
                color: context.appColors.lineupMint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: size * .18,
                color: context.appColors.lineupBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
