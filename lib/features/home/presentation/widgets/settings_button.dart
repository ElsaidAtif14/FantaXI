import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData? icons;

  const SettingsButton({super.key, required this.onTap, this.icons});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lineupControl.withValues(alpha: .6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Icon(
            icons ?? Icons.account_circle,
            size: 17,
            color: AppColors.lineupTextSecondary,
          ),

          // child: const  Icon(
          //   Icons.account_circle,
          //   size: 17,
          //   color: AppColors.lineupTextSecondary,
          // ),
        ),
      ),
    );
  }
}
