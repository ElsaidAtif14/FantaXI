
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontSize: 12),
    decoration: InputDecoration(
      hintText: 'Search manager or team name...',
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      prefixIcon: const Icon(Icons.search_rounded, size: 18),
      prefixIconColor: const Color(0xFF94A3B8),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded, size: 16),
              color: const Color(0xFF94A3B8),
            ),
      filled: true,
      fillColor: const Color(0xE6101423),
      contentPadding: const EdgeInsets.symmetric(vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
