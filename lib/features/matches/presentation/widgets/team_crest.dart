import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:flutter/material.dart';

/// Team badge with a readable initials fallback when the badge is unavailable.
class TeamCrest extends StatelessWidget {
  const TeamCrest({
    super.key,
    required this.team,
    required this.size,
    this.background,
    this.borderColor,
  });

  final TeamModel? team;
  final double size;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final teamCode = int.tryParse(team?.code ?? '');
    final fallback = _InitialsBadge(
      team: team,
      size: size,
      background: background,
      borderColor: borderColor,
    );
    if (teamCode == null || teamCode <= 0) return fallback;
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: '${AppConstants.teamBadgeBase}$teamCode.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        memCacheWidth: (size * MediaQuery.of(context).devicePixelRatio).round(),
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({
    required this.team,
    required this.size,
    this.background,
    this.borderColor,
  });

  final TeamModel? team;
  final double size;
  final Color? background;
  final Color? borderColor;

  String get _initials {
    final short = team?.shortName.trim() ?? '';
    if (short.isNotEmpty) {
      return short.length > 3 ? short.substring(0, 3) : short;
    }
    final name = team?.name.trim() ?? '';
    if (name.isEmpty) return '';
    final words = name.split(RegExp(r'\s+'));
    if (words.length == 1) {
      final word = words.first;
      return word.length > 3 ? word.substring(0, 3) : word;
    }
    return words.take(2).map((word) => word[0]).join();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.appColors.lineupControl,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              borderColor ??
              context.appColors.lineupLavender.withValues(alpha: .28),
        ),
      ),
      child:
          initials.isEmpty
              ? Icon(
                Icons.shield_rounded,
                color: context.appColors.lineupLavender,
                size: size * .5,
              )
              : Text(
                initials,
                maxLines: 1,
                style: TextStyle(
                  color: context.appColors.lineupLavender,
                  fontSize: size * .3,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),
    );
  }
}
