
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class StandingsColumnHeader extends StatelessWidget {
  const StandingsColumnHeader({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 3, 12, 7),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            'RANK',
            style: _columnStyle(context),
          ),
        ),
        Expanded(child: Text('MANAGER & TEAM', style: _columnStyle(context))),
        SizedBox(
          width: 55,
          child: Text(
            'GW PTS',
            textAlign: TextAlign.center,
            style: _columnStyle(context),
          ),
        ),
        SizedBox(
          width: 58,
          child: Text(
            'TOTAL',
            textAlign: TextAlign.end,
            style: _columnStyle(context),
          ),
        ),
      ],
    ),
  );

  static TextStyle _columnStyle(BuildContext context) => TextStyle(
    color: context.appColors.leagueSecondaryText,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: .2,
  );
}
