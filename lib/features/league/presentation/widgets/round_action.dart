
import 'package:flutter/material.dart';

class RoundAction extends StatelessWidget {
  const RoundAction({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xA6161B2E),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x1AFFFFFF)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: const Color(0xFFCBD5E1), size: 20),
        ),
      ),
    );
  }
}