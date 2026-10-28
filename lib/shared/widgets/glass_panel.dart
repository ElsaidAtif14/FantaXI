
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fantasy/core/theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? glowColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 18,
    this.fillColor,
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final cornerRadius = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(
        borderRadius: cornerRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: -4,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: cornerRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor ?? AppColors.surface.withValues(alpha: 0.78),
              borderRadius: cornerRadius,
              border: Border.all(
                color: borderColor ?? AppColors.outline.withValues(alpha: 0.88),
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
