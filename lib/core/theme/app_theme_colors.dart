import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors._({required this.values});

  final Map<String, Object> values;

  static const light = AppThemeColors._(
    values: {
      'background': AppColors.lightBackground,
      'surface': AppColors.lightSurface,
      'surfaceVariant': AppColors.lightSurfaceVariant,
      'card': AppColors.lightCard,
      'outline': AppColors.lightOutline,
      'primary': AppColors.lightPrimary,
      'primaryLight': AppColors.lightPrimaryLight,
      'electricBlue': AppColors.lightElectricBlue,
      'warmOrange': AppColors.lightWarmOrange,
      'secondary': AppColors.lightSecondary,
      'secondaryDark': AppColors.lightSecondaryDark,
      'gold': AppColors.lightGold,
      'silver': AppColors.lightSilver,
      'bronze': AppColors.lightBronze,
      'textPrimary': AppColors.lightTextPrimary,
      'textSecondary': AppColors.lightTextSecondary,
      'textMuted': AppColors.lightTextMuted,
      'rankUp': AppColors.lightRankUp,
      'rankDown': AppColors.lightRankDown,
      'rankSame': AppColors.lightRankSame,
      'pitchGreen': AppColors.lightPitchGreen,
      'pitchGreenLight': AppColors.lightPitchGreenLight,
      'pitchLine': AppColors.lightPitchLine,
      'marketBackground': AppColors.lightMarketBackground,
      'marketSurface': AppColors.lightMarketSurface,
      'marketPanel': AppColors.lightMarketPanel,
      'marketPanelBorder': AppColors.lightMarketPanelBorder,
      'marketControl': AppColors.lightMarketControl,
      'marketInput': AppColors.lightMarketInput,
      'marketText': AppColors.lightMarketText,
      'marketHint': AppColors.lightMarketHint,
      'marketMint': AppColors.lightMarketMint,
      'marketLavender': AppColors.lightMarketLavender,
      'marketSelectedText': AppColors.lightMarketSelectedText,
      'lineupBackground': AppColors.lightLineupBackground,
      'lineupSurface': AppColors.lightLineupSurface,
      'lineupPanel': AppColors.lightLineupPanel,
      'lineupControl': AppColors.lightLineupControl,
      'lineupText': AppColors.lightLineupText,
      'lineupTextSecondary': AppColors.lightLineupTextSecondary,
      'lineupMint': AppColors.lightLineupMint,
      'homeMint': AppColors.lightHomeMint,
      'lineupLavender': AppColors.lightLineupLavender,
      'lineupPurple': AppColors.lightLineupPurple,
      'lineupPitchTop': AppColors.lightLineupPitchTop,
      'lineupPitchMiddle': AppColors.lightLineupPitchMiddle,
      'lineupPitchBottom': AppColors.lightLineupPitchBottom,
      'lineupPitchLine': AppColors.lightLineupPitchLine,
      'primaryGradient': AppColors.lightPrimaryGradient,
      'cardGradient': AppColors.lightCardGradient,
      'greenGradient': AppColors.lightGreenGradient,
      'leagueCardGradient': AppColors.lightLeagueCardGradient,
      'leagueCardBorder': AppColors.lightLeagueCardBorder,
      'leagueCardShadow': AppColors.lightLeagueCardShadow,
      'leagueIconTeal': AppColors.lightLeagueIconTeal,
      'leagueIconBackground': AppColors.lightLeagueIconBackground,
      'leagueIconForeground': AppColors.lightLeagueIconForeground,
      'leagueText': AppColors.lightLeagueText,
      'leagueSecondaryText': AppColors.lightLeagueSecondaryText,
      'leagueBadgeBackground': AppColors.lightLeagueBadgeBackground,
      'leagueBadgeBorder': AppColors.lightLeagueBadgeBorder,
      'leagueBadgeText': AppColors.lightLeagueBadgeText,
      'leagueTransparent': AppColors.lightLeagueTransparent,
      'leagueWhite': AppColors.lightLeagueWhite,
      'standingBackground': AppColors.lightStandingBackground,
      'standingBorder': AppColors.lightStandingBorder,
      'standingCurrentUserBorder': AppColors.lightStandingCurrentUserBorder,
      'standingCurrentUserShadow': AppColors.lightStandingCurrentUserShadow,
      'standingCurrentUserPointsBackground':
          AppColors.lightStandingCurrentUserPointsBackground,
      'standingCurrentUserPointsBorder':
          AppColors.lightStandingCurrentUserPointsBorder,
      'standingTeamText': AppColors.lightStandingTeamText,
      'standingSecondaryText': AppColors.lightStandingSecondaryText,
      'standingCurrentGameweek': AppColors.lightStandingCurrentGameweek,
      'standingPointsText': AppColors.lightStandingPointsText,
      'standingPointsBackground': AppColors.lightStandingPointsBackground,
      'standingPointsBorder': AppColors.lightStandingPointsBorder,
      'standingPointsTextAccent': AppColors.lightStandingPointsTextAccent,
      'standingCurrentPointsText': AppColors.lightStandingCurrentPointsText,
      'standingRankGold': AppColors.lightStandingRankGold,
      'standingRankSilver': AppColors.lightStandingRankSilver,
      'standingRankBronze': AppColors.lightStandingRankBronze,
      'standingRankDefault': AppColors.lightStandingRankDefault,
      'standingRankText': AppColors.lightStandingRankText,
      'standingRankUnplacedText': AppColors.lightStandingRankUnplacedText,
      'standingYouBadgeBackground': AppColors.lightStandingYouBadgeBackground,
      'standingYouBadgeText': AppColors.lightStandingYouBadgeText,
      'standingTransparent': AppColors.lightStandingTransparent,
    },
  );

  static const dark = AppThemeColors._(
    values: {
      'background': AppColors.darkBackground,
      'surface': AppColors.darkSurface,
      'surfaceVariant': AppColors.darkSurfaceVariant,
      'card': AppColors.darkCard,
      'outline': AppColors.darkOutline,
      'primary': AppColors.darkPrimary,
      'primaryLight': AppColors.darkPrimaryLight,
      'electricBlue': AppColors.darkElectricBlue,
      'warmOrange': AppColors.darkWarmOrange,
      'secondary': AppColors.darkSecondary,
      'secondaryDark': AppColors.darkSecondaryDark,
      'gold': AppColors.darkGold,
      'silver': AppColors.darkSilver,
      'bronze': AppColors.darkBronze,
      'textPrimary': AppColors.darkTextPrimary,
      'textSecondary': AppColors.darkTextSecondary,
      'textMuted': AppColors.darkTextMuted,
      'rankUp': AppColors.darkRankUp,
      'rankDown': AppColors.darkRankDown,
      'rankSame': AppColors.darkRankSame,
      'pitchGreen': AppColors.darkPitchGreen,
      'pitchGreenLight': AppColors.darkPitchGreenLight,
      'pitchLine': AppColors.darkPitchLine,
      'marketBackground': AppColors.darkMarketBackground,
      'marketSurface': AppColors.darkMarketSurface,
      'marketPanel': AppColors.darkMarketPanel,
      'marketPanelBorder': AppColors.darkMarketPanelBorder,
      'marketControl': AppColors.darkMarketControl,
      'marketInput': AppColors.darkMarketInput,
      'marketText': AppColors.darkMarketText,
      'marketHint': AppColors.darkMarketHint,
      'marketMint': AppColors.darkMarketMint,
      'marketLavender': AppColors.darkMarketLavender,
      'marketSelectedText': AppColors.darkMarketSelectedText,
      'lineupBackground': AppColors.darkLineupBackground,
      'lineupSurface': AppColors.darkLineupSurface,
      'lineupPanel': AppColors.darkLineupPanel,
      'lineupControl': AppColors.darkLineupControl,
      'lineupText': AppColors.darkLineupText,
      'lineupTextSecondary': AppColors.darkLineupTextSecondary,
      'lineupMint': AppColors.darkLineupMint,
      'homeMint': AppColors.darkHomeMint,
      'lineupLavender': AppColors.darkLineupLavender,
      'lineupPurple': AppColors.darkLineupPurple,
      'lineupPitchTop': AppColors.darkLineupPitchTop,
      'lineupPitchMiddle': AppColors.darkLineupPitchMiddle,
      'lineupPitchBottom': AppColors.darkLineupPitchBottom,
      'lineupPitchLine': AppColors.darkLineupPitchLine,
      'primaryGradient': AppColors.darkPrimaryGradient,
      'cardGradient': AppColors.darkCardGradient,
      'greenGradient': AppColors.darkGreenGradient,
      'leagueCardGradient': AppColors.darkLeagueCardGradient,
      'leagueCardBorder': AppColors.darkLeagueCardBorder,
      'leagueCardShadow': AppColors.darkLeagueCardShadow,
      'leagueIconTeal': AppColors.darkLeagueIconTeal,
      'leagueIconBackground': AppColors.darkLeagueIconBackground,
      'leagueIconForeground': AppColors.darkLeagueIconForeground,
      'leagueText': AppColors.darkLeagueText,
      'leagueSecondaryText': AppColors.darkLeagueSecondaryText,
      'leagueBadgeBackground': AppColors.darkLeagueBadgeBackground,
      'leagueBadgeBorder': AppColors.darkLeagueBadgeBorder,
      'leagueBadgeText': AppColors.darkLeagueBadgeText,
      'leagueTransparent': AppColors.darkLeagueTransparent,
      'leagueWhite': AppColors.darkLeagueWhite,
      'standingBackground': AppColors.darkStandingBackground,
      'standingBorder': AppColors.darkStandingBorder,
      'standingCurrentUserBorder': AppColors.darkStandingCurrentUserBorder,
      'standingCurrentUserShadow': AppColors.darkStandingCurrentUserShadow,
      'standingCurrentUserPointsBackground':
          AppColors.darkStandingCurrentUserPointsBackground,
      'standingCurrentUserPointsBorder':
          AppColors.darkStandingCurrentUserPointsBorder,
      'standingTeamText': AppColors.darkStandingTeamText,
      'standingSecondaryText': AppColors.darkStandingSecondaryText,
      'standingCurrentGameweek': AppColors.darkStandingCurrentGameweek,
      'standingPointsText': AppColors.darkStandingPointsText,
      'standingPointsBackground': AppColors.darkStandingPointsBackground,
      'standingPointsBorder': AppColors.darkStandingPointsBorder,
      'standingPointsTextAccent': AppColors.darkStandingPointsTextAccent,
      'standingCurrentPointsText': AppColors.darkStandingCurrentPointsText,
      'standingRankGold': AppColors.darkStandingRankGold,
      'standingRankSilver': AppColors.darkStandingRankSilver,
      'standingRankBronze': AppColors.darkStandingRankBronze,
      'standingRankDefault': AppColors.darkStandingRankDefault,
      'standingRankText': AppColors.darkStandingRankText,
      'standingRankUnplacedText': AppColors.darkStandingRankUnplacedText,
      'standingYouBadgeBackground': AppColors.darkStandingYouBadgeBackground,
      'standingYouBadgeText': AppColors.darkStandingYouBadgeText,
      'standingTransparent': AppColors.darkStandingTransparent,
    },
  );

  Color get background => values['background']! as Color;
  Color get surface => values['surface']! as Color;
  Color get surfaceVariant => values['surfaceVariant']! as Color;
  Color get card => values['card']! as Color;
  Color get outline => values['outline']! as Color;
  Color get primary => values['primary']! as Color;
  Color get primaryLight => values['primaryLight']! as Color;
  Color get electricBlue => values['electricBlue']! as Color;
  Color get warmOrange => values['warmOrange']! as Color;
  Color get secondary => values['secondary']! as Color;
  Color get secondaryDark => values['secondaryDark']! as Color;
  Color get gold => values['gold']! as Color;
  Color get silver => values['silver']! as Color;
  Color get bronze => values['bronze']! as Color;
  Color get textPrimary => values['textPrimary']! as Color;
  Color get textSecondary => values['textSecondary']! as Color;
  Color get textMuted => values['textMuted']! as Color;
  Color get rankUp => values['rankUp']! as Color;
  Color get rankDown => values['rankDown']! as Color;
  Color get rankSame => values['rankSame']! as Color;
  Color get pitchGreen => values['pitchGreen']! as Color;
  Color get pitchGreenLight => values['pitchGreenLight']! as Color;
  Color get pitchLine => values['pitchLine']! as Color;
  Color get marketBackground => values['marketBackground']! as Color;
  Color get marketSurface => values['marketSurface']! as Color;
  Color get marketPanel => values['marketPanel']! as Color;
  Color get marketPanelBorder => values['marketPanelBorder']! as Color;
  Color get marketControl => values['marketControl']! as Color;
  Color get marketInput => values['marketInput']! as Color;
  Color get marketText => values['marketText']! as Color;
  Color get marketHint => values['marketHint']! as Color;
  Color get marketMint => values['marketMint']! as Color;
  Color get marketLavender => values['marketLavender']! as Color;
  Color get marketSelectedText => values['marketSelectedText']! as Color;
  Color get lineupBackground => values['lineupBackground']! as Color;
  Color get lineupSurface => values['lineupSurface']! as Color;
  Color get lineupPanel => values['lineupPanel']! as Color;
  Color get lineupControl => values['lineupControl']! as Color;
  Color get lineupText => values['lineupText']! as Color;
  Color get lineupTextSecondary => values['lineupTextSecondary']! as Color;
  Color get lineupMint => values['lineupMint']! as Color;
  Color get homeMint => values['homeMint']! as Color;
  Color get lineupLavender => values['lineupLavender']! as Color;
  Color get lineupPurple => values['lineupPurple']! as Color;
  Color get lineupPitchTop => values['lineupPitchTop']! as Color;
  Color get lineupPitchMiddle => values['lineupPitchMiddle']! as Color;
  Color get lineupPitchBottom => values['lineupPitchBottom']! as Color;
  Color get lineupPitchLine => values['lineupPitchLine']! as Color;
  Gradient get primaryGradient => values['primaryGradient']! as Gradient;
  Gradient get cardGradient => values['cardGradient']! as Gradient;
  Gradient get greenGradient => values['greenGradient']! as Gradient;
  Gradient get leagueCardGradient => values['leagueCardGradient']! as Gradient;
  Color get leagueCardBorder => values['leagueCardBorder']! as Color;
  Color get leagueCardShadow => values['leagueCardShadow']! as Color;
  Color get leagueIconTeal => values['leagueIconTeal']! as Color;
  Color get leagueIconBackground => values['leagueIconBackground']! as Color;
  Color get leagueIconForeground => values['leagueIconForeground']! as Color;
  Color get leagueText => values['leagueText']! as Color;
  Color get leagueSecondaryText => values['leagueSecondaryText']! as Color;
  Color get leagueBadgeBackground => values['leagueBadgeBackground']! as Color;
  Color get leagueBadgeBorder => values['leagueBadgeBorder']! as Color;
  Color get leagueBadgeText => values['leagueBadgeText']! as Color;
  Color get leagueTransparent => values['leagueTransparent']! as Color;
  Color get leagueWhite => values['leagueWhite']! as Color;
  Color get standingBackground => values['standingBackground']! as Color;
  Color get standingBorder => values['standingBorder']! as Color;
  Color get standingCurrentUserBorder =>
      values['standingCurrentUserBorder']! as Color;
  Color get standingCurrentUserShadow =>
      values['standingCurrentUserShadow']! as Color;
  Color get standingCurrentUserPointsBackground =>
      values['standingCurrentUserPointsBackground']! as Color;
  Color get standingCurrentUserPointsBorder =>
      values['standingCurrentUserPointsBorder']! as Color;
  Color get standingTeamText => values['standingTeamText']! as Color;
  Color get standingSecondaryText => values['standingSecondaryText']! as Color;
  Color get standingCurrentGameweek =>
      values['standingCurrentGameweek']! as Color;
  Color get standingPointsText => values['standingPointsText']! as Color;
  Color get standingPointsBackground =>
      values['standingPointsBackground']! as Color;
  Color get standingPointsBorder => values['standingPointsBorder']! as Color;
  Color get standingPointsTextAccent =>
      values['standingPointsTextAccent']! as Color;
  Color get standingCurrentPointsText =>
      values['standingCurrentPointsText']! as Color;
  Color get standingRankGold => values['standingRankGold']! as Color;
  Color get standingRankSilver => values['standingRankSilver']! as Color;
  Color get standingRankBronze => values['standingRankBronze']! as Color;
  Color get standingRankDefault => values['standingRankDefault']! as Color;
  Color get standingRankText => values['standingRankText']! as Color;
  Color get standingRankUnplacedText =>
      values['standingRankUnplacedText']! as Color;
  Color get standingYouBadgeBackground =>
      values['standingYouBadgeBackground']! as Color;
  Color get standingYouBadgeText => values['standingYouBadgeText']! as Color;
  Color get standingTransparent => values['standingTransparent']! as Color;

  @override
  AppThemeColors copyWith({Map<String, Object>? values}) =>
      AppThemeColors._(values: {...this.values, ...?values});

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    final interpolated = <String, Object>{};
    for (final entry in values.entries) {
      final start = entry.value;
      final end = other.values[entry.key]!;
      if (start is Color && end is Color) {
        interpolated[entry.key] = Color.lerp(start, end, t)!;
      } else if (start is Gradient && end is Gradient) {
        interpolated[entry.key] =
            Gradient.lerp(start, end, t) ?? (t < 0.5 ? start : end);
      } else {
        interpolated[entry.key] = t < 0.5 ? start : end;
      }
    }
    return AppThemeColors._(values: interpolated);
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}
