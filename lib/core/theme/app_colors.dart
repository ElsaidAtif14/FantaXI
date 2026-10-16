import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF111722);
  static const Color surfaceVariant = Color(0xFF192230);
  static const Color card = Color(0xFF121923);
  static const Color outline = Color(0xFF283343);

  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFBDA8FF);
  static const Color electricBlue = Color(0xFF58C7FF);
  static const Color warmOrange = Color(0xFFFFA45B);
  static const Color secondary = Color(0xFF00E676);
  static const Color secondaryDark = Color(0xFF00C853);

  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFB0BEC5);
  static const Color bronze = Color(0xFFFF6F43);

  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8A8FA8);
  static const Color textMuted = Color(0xFF555870);

  static const Color rankUp = Color(0xFF00E676);
  static const Color rankDown = Color(0xFFFF5252);
  static const Color rankSame = Color(0xFF8A8FA8);

  static const Color pitchGreen = Color(0xFF1A5C2A);
  static const Color pitchGreenLight = Color(0xFF236B33);
  static const Color pitchLine = Color(0xFF2E8040);

  static const Color marketBackground = Color(0xFF0B0E17);
  static const Color marketSurface = Color(0xFF10131C);
  static const Color marketPanel = Color(0xFF272A34);
  static const Color marketPanelBorder = Color(0xFF30333E);
  static const Color marketControl = Color(0xFF272A34);
  static const Color marketInput = Color(0xFF0B0E17);
  static const Color marketText = Color(0xFFCBC3D7);
  static const Color marketHint = Color(0xFF958EA0);
  static const Color marketMint = Color(0xFF4EDEA3);
  static const Color marketLavender = Color(0xFFA078FF);
  static const Color marketSelectedText = Color(0xFF3C0091);

  static const Color lineupBackground = Color(0xFF0B0E17);
  static const Color lineupSurface = Color(0xFF10131C);
  static const Color lineupPanel = Color(0xFF1C1F29);
  static const Color lineupControl = Color(0xFF272A34);
  static const Color lineupText = Color(0xFFE0E2EF);
  static const Color lineupTextSecondary = Color(0xFFCBC3D7);
  static const Color lineupMint = Color(0xFF4EDEA3);
  static const Color homeMint = Color(0xFF50E3C2);
  static const Color lineupLavender = Color(0xFFD0BCFF);
  static const Color lineupPurple = Color(0xFFA078FF);
  static const Color lineupPitchTop = Color(0xFF091515);
  static const Color lineupPitchMiddle = Color(0xFF0E1F1C);
  static const Color lineupPitchBottom = Color(0xFF0A141B);
  static const Color lineupPitchLine = Color(0xFF164A3B);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF3D1FBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF182230), Color(0xFF111720)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient greenGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
