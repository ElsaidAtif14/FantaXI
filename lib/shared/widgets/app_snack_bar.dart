import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

enum AppSnackBarType { info, success, warning, error }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final color = switch (type) {
      AppSnackBarType.info => context.appColors.electricBlue,
      AppSnackBarType.success => context.appColors.secondary,
      AppSnackBarType.warning => context.appColors.warmOrange,
      AppSnackBarType.error => context.appColors.rankDown,
    };
    final icon = switch (type) {
      AppSnackBarType.info => Icons.info_outline,
      AppSnackBarType.success => Icons.check_circle_outline,
      AppSnackBarType.warning => Icons.warning_amber_rounded,
      AppSnackBarType.error => Icons.error_outline,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.appColors.surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:  BorderSide(color: context.appColors.outline),
        ),
      ),
    );
  }
}
