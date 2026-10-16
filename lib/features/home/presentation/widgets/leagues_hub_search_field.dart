import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeaguesHubSearchField extends StatelessWidget {
  const LeaguesHubSearchField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: AppColors.lineupText, fontSize: 12),
    decoration: InputDecoration(
      hintText: 'Search leagues & cups...',
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      prefixIcon: const Icon(Icons.search_rounded, size: 18),
      prefixIconColor: AppColors.lineupTextSecondary,
      filled: true,
      fillColor: const Color(0xFF0D1018),
      contentPadding: const EdgeInsets.symmetric(vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.lineupPurple),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.lineupPurple),
      ),
    ),
  );
}
