
import 'package:flutter/material.dart';

class StandingsColumnHeader extends StatelessWidget {
  const StandingsColumnHeader({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(12, 3, 12, 7),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            'RANK',
            style: _columnStyle,
          ),
        ),
        Expanded(child: Text('MANAGER & TEAM', style: _columnStyle)),
        SizedBox(
          width: 55,
          child: Text('GW PTS', textAlign: TextAlign.center, style: _columnStyle),
        ),
        SizedBox(
          width: 58,
          child: Text('TOTAL', textAlign: TextAlign.end, style: _columnStyle),
        ),
      ],
    ),
  );

  static const _columnStyle = TextStyle(
    color: Color(0xFFCBD5E1),
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: .2,
  );
}
