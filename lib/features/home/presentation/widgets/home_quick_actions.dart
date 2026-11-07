import 'package:fantasy/features/home/data/model/action_item.dart';
import 'package:fantasy/features/home/presentation/widgets/action_btn.dart';
import 'package:flutter/material.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';

class HomeQuickActions extends StatelessWidget {
  final List<ActionItem> actions;
  const HomeQuickActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              actions
                  .map(
                    (a) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: a == actions.last ? 0 : 12,
                        ),
                        child: ActionBtn(item: a),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
