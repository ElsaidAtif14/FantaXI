import 'package:flutter/material.dart';
import 'package:fantasy/core/theme/app_colors.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;
  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF17112B), Color(0xFF101722), AppColors.background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
