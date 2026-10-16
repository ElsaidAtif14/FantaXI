import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/home/presentation/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onSettingsTap,
    this.leadingIcon = Icons.sports_soccer_rounded,
    this.isHome = false,
  });

  final String title;
  final VoidCallback? onSettingsTap;
  final IconData leadingIcon;
  final bool isHome;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.marketBackground.withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.lineupControl,
              borderRadius: BorderRadius.circular(9),
            ),
            // child: Icon(leadingIcon, size: 16, color: AppColors.lineupMint),
            child: SvgPicture.asset('assets/svg/fantaxi.svg'),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.lineupText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      actions: [
        if (isHome) ...[
          SettingsButton(onTap: onSettingsTap ?? () {}),
          const SizedBox(width: 16),
        ] else
          const SizedBox(width: 16),
      ],
    );
  }
}
