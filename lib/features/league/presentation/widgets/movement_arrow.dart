import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class MovementArrow extends StatelessWidget {
  final int mov;
  const MovementArrow({super.key, required this.mov});

  @override
  Widget build(BuildContext context) {
    if (mov == 0) {
      return  Icon(
        Icons.remove_rounded,
        color: context.appColors.rankSame,
        size: 16,
      );
    }
    return Row(
      children: [
        Icon(
          mov > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: mov > 0 ? context.appColors.rankUp : context.appColors.rankDown,
          size: 14,
        ),
        Text(
          '${mov.abs()}',
          style: TextStyle(
            color: mov > 0 ? context.appColors.rankUp : context.appColors.rankDown,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
