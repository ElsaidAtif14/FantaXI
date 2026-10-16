import 'package:flutter/material.dart';
import 'package:fantasy/core/theme/app_colors.dart';

class SplashLogo extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final Animation<Offset> slideAnim;

  const SplashLogo({
    super.key,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  // ignore: deprecated_member_use
                  BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
                ],
              ),
              child: const Center(child: Text('⚽', style: TextStyle(fontSize: 56))),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.secondary],
                  ).createShader(b),
                  child: const Text('FantaXI', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                ),
                const SizedBox(height: 8),
                const Text('Fantasy Premier League Manager', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
