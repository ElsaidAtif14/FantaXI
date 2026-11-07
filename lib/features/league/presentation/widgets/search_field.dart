
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: TextStyle(color: context.appColors.leagueText, fontSize: 12),
    decoration: InputDecoration(
      hintText: 'Search manager or team name...',
      hintStyle: TextStyle(
        color: context.appColors.leagueSecondaryText,
        fontSize: 12,
      ),
      prefixIcon: const Icon(Icons.search_rounded, size: 18),
      prefixIconColor: context.appColors.leagueSecondaryText,
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded, size: 16),
              color: context.appColors.leagueSecondaryText,
            ),
      filled: true,
      fillColor: context.appColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.appColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.appColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: context.appColors.primary),
      ),
    ),
  );
}
