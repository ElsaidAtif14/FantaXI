import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final suffixIcon =
        controller.text.isNotEmpty
            ? IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
              icon: const Icon(Icons.close, size: 18),
            )
            : null;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style:  TextStyle(color: context.appColors.lineupText, fontSize: 12),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:  TextStyle(color: context.appColors.textMuted, fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        prefixIconColor: context.appColors.lineupTextSecondary,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.appColors.marketInput,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide:  BorderSide(color: context.appColors.lineupPurple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide:  BorderSide(color: context.appColors.lineupPurple),
        ),
      ),
    );
  }
}
