import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_empty_state.dart';
import 'package:flutter/material.dart';

enum _Side { home, away }

/// Lineups tab: one formation pitch per team with a home/away switch, plus
/// substitutes and managers when the API provides them.
class LineupsView extends StatefulWidget {
  const LineupsView({
    super.key,
    required this.details,
    required this.homeTeam,
    required this.awayTeam,
  });

  final PremierLeagueMatchDetails? details;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;

  @override
  State<LineupsView> createState() => _LineupsViewState();
}

class _LineupsViewState extends State<LineupsView> {
  _Side _selected = _Side.home;

  MatchLineup? get _selectedLineup =>
      _side == _Side.home
          ? widget.details?.homeLineup
          : widget.details?.awayLineup;

  _Side get _side => _selected;

  TeamModel? get _selectedModel =>
      _side == _Side.home ? widget.homeTeam : widget.awayTeam;

  bool _hasContent(MatchLineup? lineup) =>
      lineup != null &&
      (lineup.players.isNotEmpty || lineup.formationRows.isNotEmpty);

  static String _label(TeamModel? team, String fallback) {
    final short = team?.shortName.trim() ?? '';
    return short.isEmpty ? fallback : short;
  }

  @override
  Widget build(BuildContext context) {
    final home = widget.details?.homeLineup;
    final away = widget.details?.awayLineup;
    if (!_hasContent(home) && !_hasContent(away)) {
      return const SectionEmptyState(
        icon: Icons.sports_soccer_rounded,
        title: 'Lineups unavailable',
        message:
            'Confirmed lineups are not included in the available match data.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SidePicker(
          homeLabel: _label(widget.homeTeam, 'HOME'),
          awayLabel: _label(widget.awayTeam, 'AWAY'),
          selected: _selected,
          onSelected: (side) => setState(() => _selected = side),
        ),
        if (!_hasContent(_selectedLineup))
          Padding(
            padding: const EdgeInsets.only(top: MatchDetailsStyle.spaceMd),
            child: SectionEmptyState(
              icon: Icons.sports_soccer_rounded,
              title:
                  '${_label(_selectedModel, _side.name.toUpperCase())} lineup unavailable',
              message:
                  'This team is not included in the available lineup data.',
            ),
          )
        else ...[
          const SizedBox(height: MatchDetailsStyle.spaceMd),
          _LineupPanel(
            side: _side,
            lineup: _selectedLineup!,
            team: _selectedModel,
          ),
        ],
      ],
    );
  }
}

class _SidePicker extends StatelessWidget {
  const _SidePicker({
    required this.homeLabel,
    required this.awayLabel,
    required this.selected,
    required this.onSelected,
  });

  final String homeLabel;
  final String awayLabel;
  final _Side selected;
  final ValueChanged<_Side> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget option(_Side side, String label, String marker) {
      final isSelected = selected == side;
      return Expanded(
        child: Semantics(
          button: true,
          selected: isSelected,
          label: '$label ($marker) lineups',
          child: Material(
            color:
                isSelected
                    ? context.appColors.lineupLavender
                    : context.appColors.lineupPanel,
            borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
            child: InkWell(
              onTap: () => onSelected(side),
              borderRadius: BorderRadius.circular(
                MatchDetailsStyle.panelRadius,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Center(
                  child: Text(
                    '$label · $marker',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          isSelected
                              ? context.appColors.marketSelectedText
                              : context.appColors.lineupTextSecondary,
                      fontSize: MatchDetailsStyle.labelSize + .5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(_Side.home, homeLabel, 'H'),
        const SizedBox(width: MatchDetailsStyle.spaceSm),
        option(_Side.away, awayLabel, 'A'),
      ],
    );
  }
}

class _LineupPanel extends StatelessWidget {
  const _LineupPanel({
    required this.side,
    required this.lineup,
    required this.team,
  });

  final _Side side;
  final MatchLineup lineup;
  final TeamModel? team;

  @override
  Widget build(BuildContext context) {
    // Resolve players strictly through IDs from this team only; players from
    // the other side can never appear on the wrong half.
    MatchPlayer? playerById(int? id) {
      if (id == null) return null;
      for (final player in lineup.players) {
        if (player.id == id) return player;
      }
      return null;
    }

    final rows = <List<MatchPlayer>>[
      for (final row in lineup.formationRows)
        [
          for (final id in row)
            if (playerById(id) is MatchPlayer) playerById(id)!,
        ],
    ];
    final hasFormationRows = rows.any((row) => row.isNotEmpty);
    if (!hasFormationRows) {
      rows
        ..clear()
        ..addAll(_positionRows(lineup.starters));
    }

    final substitutes = <MatchPlayer>[
      for (final id in lineup.substituteIds)
        if (playerById(id) is MatchPlayer) playerById(id)!,
    ];
    if (substitutes.isEmpty) substitutes.addAll(lineup.substitutes);

    final managerNames = [
      for (final manager in lineup.managers)
        if ((manager.name ?? '').trim().isNotEmpty) manager.name!.trim(),
    ];

    final formationLineup = hasFormationRows ? lineup.formation : null;
    final headline = hasFormationRows ? formationLineup ?? '' : 'Positions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_teamLabel(context)}${headline.isEmpty ? '' : ' · $headline'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.lineupLavender,
                  fontSize: MatchDetailsStyle.microSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
            ),
            if (!hasFormationRows)
              Text(
                'formation unavailable',
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: MatchDetailsStyle.spaceSm),
        FormationPitch(rows: rows),
        const SizedBox(height: MatchDetailsStyle.spaceMd),
        _SubstitutesList(substitutes: substitutes),
        if (managerNames.isNotEmpty) ...[
          const SizedBox(height: MatchDetailsStyle.spaceMd),
          Row(
            children: [
              Icon(
                Icons.sports_rounded,
                size: 12,
                color: context.appColors.lineupLavender,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  managerNames.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.appColors.lineupTextSecondary,
                    fontSize: MatchDetailsStyle.labelSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _teamLabel(BuildContext context) {
    final short = team?.shortName.trim() ?? '';
    final sideMarker = side == _Side.home ? 'H' : 'A';
    return short.isEmpty ? sideMarker : '$short · $sideMarker';
  }

  static List<List<MatchPlayer>> _positionRows(List<MatchPlayer> starters) {
    final goalkeepers = <MatchPlayer>[];
    final defenders = <MatchPlayer>[];
    final midfielders = <MatchPlayer>[];
    final forwards = <MatchPlayer>[];
    for (final player in starters) {
      switch ((player.position ?? '').toLowerCase()) {
        case 'goalkeeper':
          goalkeepers.add(player);
        case 'defender':
          defenders.add(player);
        case 'midfielder':
          midfielders.add(player);
        case 'forward':
          forwards.add(player);
        default:
          forwards.add(player);
      }
    }
    return [
      goalkeepers,
      defenders,
      midfielders,
      forwards,
    ].where((row) => row.isNotEmpty).toList();
  }
}

/// Renders the parsed formation rows on a pitch. Row 1 is always the
/// goalkeeper, matching the API's ordering.
class FormationPitch extends StatelessWidget {
  const FormationPitch({super.key, required this.rows});

  final List<List<MatchPlayer>> rows;

  @override
  Widget build(BuildContext context) {
    final nonEmpty = rows.where((row) => row.isNotEmpty).toList();
    final rowHeight = 70.0;
    final height = nonEmpty.length * rowHeight + 16;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.appColors.lineupPitchTop,
            context.appColors.lineupPitchMiddle,
            context.appColors.lineupPitchBottom,
          ],
        ),
        borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
        border: Border.all(color: context.appColors.matchPitchLine),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.appColors.matchPitchLine.withValues(
                      alpha: .55,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 1,
                width: double.infinity,
                child: ColoredBox(
                  color: context.appColors.matchPitchLine.withValues(
                    alpha: .35,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 8),
                for (final row in nonEmpty)
                  SizedBox(
                    height: rowHeight,
                    child: Row(
                      children: [
                        for (final player in row)
                          Expanded(child: _PlayerChip(player: player)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.player});

  final MatchPlayer player;

  String get _shortName {
    final name = player.name ?? '';
    if (name.isEmpty) return '?';
    final words = name.split(RegExp(r'\s+'));
    return words.length <= 1 ? name : words.last;
  }

  @override
  Widget build(BuildContext context) {
    final number = player.number;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .22),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                if (player.captain)
                  Positioned(
                    right: -2,
                    top: -3,
                    child: Container(
                      width: 11,
                      height: 11,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.appColors.matchLive,
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _shortName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          Semantics(
            label:
                '${number == null ? 'Unknown number' : 'number $number'}, '
                '${player.name ?? "player unavailable"}${player.captain ? ", captain" : ""}',
            child: const SizedBox(width: 1, height: 1),
          ),
        ],
      ),
    );
  }
}

class _SubstitutesList extends StatelessWidget {
  const _SubstitutesList({required this.substitutes});

  final List<MatchPlayer> substitutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.lineupPanel,
        borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUBSTITUTES${substitutes.isEmpty ? '' : ' · ${substitutes.length}'}',
            style: TextStyle(
              color: context.appColors.lineupTextSecondary,
              fontSize: MatchDetailsStyle.microSize,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 8),
          if (substitutes.isEmpty)
            Text(
              'Substitutes unavailable',
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.bodySize,
              ),
            )
          else
            for (final player in substitutes) _SubstituteRow(player: player),
        ],
      ),
    );
  }
}

class _SubstituteRow extends StatelessWidget {
  const _SubstituteRow({required this.player});

  final MatchPlayer player;

  @override
  Widget build(BuildContext context) {
    final role =
        player.position == 'Substitute'
            ? player.subPosition ?? ''
            : player.position ?? '';
    return Semantics(
      label:
          '${player.number == null ? '' : 'number ${player.number}, '}'
          '${player.name ?? "player unavailable"}${role.isEmpty ? "" : ", $role"}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '${player.number ?? ''}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: MatchDetailsStyle.microSize,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                player.name == null || player.name!.isEmpty
                    ? 'Player unavailable'
                    : player.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.lineupText,
                  fontSize: MatchDetailsStyle.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (role.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                role,
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: MatchDetailsStyle.microSize,
                ),
              ),
            ],
            if (player.captain) ...[
              const SizedBox(width: 6),
              Text(
                'C',
                style: TextStyle(
                  color: context.appColors.matchLive,
                  fontSize: MatchDetailsStyle.microSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
