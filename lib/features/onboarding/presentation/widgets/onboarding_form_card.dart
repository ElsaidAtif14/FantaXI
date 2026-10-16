import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantasy/core/theme/app_colors.dart';

class OnboardingFormCard extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final ValueChanged<String>? onFieldSubmitted;
  const OnboardingFormCard({
    super.key,
    required this.controller,
    required this.formKey,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 30),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manager ID',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onFieldSubmitted: onFieldSubmitted,
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. 1234567',
                prefixIcon: Icon(
                  Icons.tag,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter your Manager ID';
                }
                if (int.tryParse(v) == null) return 'Must be a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Find it in the FPL URL:\nfantasy.premierleague.com/entry/ID/event/1',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
