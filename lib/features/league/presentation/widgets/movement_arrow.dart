import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MovementArrow extends StatelessWidget {
  final int mov;
  const MovementArrow({super.key, required this.mov});

  @override
  Widget build(BuildContext context) {
    if (mov == 0) {
      return const Icon(
        Icons.remove_rounded,
        color: AppColors.rankSame,
        size: 16,
      );
    }
    return Row(
      children: [
        Icon(
          mov > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: mov > 0 ? AppColors.rankUp : AppColors.rankDown,
          size: 14,
        ),
        Text(
          '${mov.abs()}',
          style: TextStyle(
            color: mov > 0 ? AppColors.rankUp : AppColors.rankDown,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
