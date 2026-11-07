import 'package:fantasy/features/onboarding/presentation/widgets/build_badge.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/features/onboarding/presentation/widgets/onboarding_form_card.dart';
import 'package:fantasy/features/onboarding/presentation/widgets/onboarding_cta_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  Future<void> _saveAndGo() async {
    if (!_formKey.currentState!.validate()) return;
    final id = int.tryParse(_controller.text.trim());
    if (id == null) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.entryIdKey, id);
    if (!mounted) return;
    context.go(AppRouter.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                BuildBadge(),
                const SizedBox(height: 24),
                 Text(
                  'Track Your\nFPL Journey',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.textPrimary,
                    height: 1.15,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                 Text(
                  'Enter your Manager ID to see live points,\noverall rank, league standings and more.',
                  style: TextStyle(
                    fontSize: 15,
                    color: context.appColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                OnboardingFormCard(
                  onFieldSubmitted: (_) => _saveAndGo(),
                  controller: _controller,
                  formKey: _formKey,
                ),
                const SizedBox(height: 24),
                OnboardingCtaButton(isLoading: _isLoading, onTap: _saveAndGo),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
