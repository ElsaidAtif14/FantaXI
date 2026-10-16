import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/splash/presentation/widgets/splash_background.dart';
import 'package:fantasy/features/splash/presentation/widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade, _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fade  = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _c, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));
    _c.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final entryId = prefs.getInt(AppConstants.entryIdKey);
    if (!mounted) return;
    context.go(entryId != null ? AppRouter.home : AppRouter.onboarding);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SplashBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SplashLogo(fadeAnim: _fade, scaleAnim: _scale, slideAnim: _slide),
              const SizedBox(height: 80),
              FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.6)),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
