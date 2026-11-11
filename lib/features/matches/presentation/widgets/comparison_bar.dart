import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Horizontal home/away comparison bar. Colours are always paired with the
/// numeric values and side labels rendered by the parent row, so the meaning
/// is never carried by colour alone.
class ComparisonBar extends StatelessWidget {
  const ComparisonBar({
    super.key,
    required this.homeValue,
    required this.awayValue,
    this.height = 6,
  });

  final num homeValue;
  final num awayValue;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = homeValue + awayValue;
    final fraction = total <= 0 ? null : (homeValue / total).clamp(0.0, 1.0);
    final homeColor = context.appColors.matchHome;
    final awayColor = context.appColors.matchAway;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child:
              fraction == null
                  ? ColoredBox(color: context.appColors.lineupControl)
                  : Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: context.appColors.lineupControl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fraction,
                          child: ColoredBox(color: homeColor),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 1 - fraction,
                          child: ColoredBox(color: awayColor),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
