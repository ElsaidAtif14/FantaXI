import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class ComparisonRow extends StatelessWidget {
  final String label;
  final String firstValue;
  final String secondValue;
  final double? firstRatio;
  final double? secondRatio;

  const ComparisonRow(
   {
    super.key,
    required this.label,
    required this.firstValue,
    required this.secondValue,
    this.firstRatio,
    this.secondRatio,
  });

  @override
  Widget build(BuildContext context) {
    final first = _validRatio(firstRatio);
    final second = _validRatio(secondRatio);
    final firstFlex = _flex(first, second);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(children: [
        Row(children: [
          Text(firstValue, style:  TextStyle(color: context.appColors.marketMint, fontSize: 9, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(label, style:  TextStyle(color: context.appColors.marketText, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: .25)),
          const Spacer(),
          Text(secondValue, style:  TextStyle(color: context.appColors.marketLavender, fontSize: 9, fontWeight: FontWeight.w700)),
        ]),
        if (first + second > 0) ...[
          const SizedBox(height: 3),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: Row(children: [
            Expanded(flex: firstFlex, child: Container(height: 4, color: context.appColors.marketMint)),
            const SizedBox(width: 2),
            Expanded(flex: 1000 - firstFlex, child: Container(height: 4, color: context.appColors.marketLavender)),
          ])),
        ],
      ]),
    );
  }

  double _validRatio(double? ratio) =>
      ratio != null && ratio.isFinite && ratio > 0 ? ratio : 0;

  int _flex(double first, double second) {
    final total = first + second;
    if (total == 0 || !total.isFinite) return 500;
    return (first / total * 1000).round().clamp(1, 999);
  }
}
