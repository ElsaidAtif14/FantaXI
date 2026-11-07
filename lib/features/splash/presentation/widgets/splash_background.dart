import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;
  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [Color(0xFF17112B), Color(0xFF101722), context.appColors.background],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        color: context.appColors.background,
      ),
      child: child,
    );
  }
}
