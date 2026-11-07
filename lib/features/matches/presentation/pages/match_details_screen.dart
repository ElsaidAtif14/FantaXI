import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/core/error/failure.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/cubit/match_details_cubit.dart';
import 'package:fantasy/features/matches/presentation/cubit/match_details_state.dart';
import 'package:go_router/go_router.dart';

const _scoreboardBackground = Color(0xFF181B25);

class MatchDetailsArguments {
  const MatchDetailsArguments({required this.fixture, required this.teams});

  final FixtureModel fixture;
  final Map<int, TeamModel> teams;
}

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({
    super.key,
    required this.fixtureId,
    this.fixture,
    this.teams,
  });

  final int fixtureId;
  final FixtureModel? fixture;
  final Map<int, TeamModel>? teams;

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  late FixtureModel? _fixture =
      widget.fixture?.id == widget.fixtureId ? widget.fixture : null;
  late Map<int, TeamModel>? _teams = widget.teams;
  String? _error;
  bool _loading = false;
  int _selectedTab = 0;
  MatchDetailsCubit? _detailsCubit;
  PremierLeagueMatchDetails? _details;
  String? _detailsError;
  bool _detailsLoading = false;

  @override
  void dispose() {
    _detailsCubit?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.fixtureId <= 0) {
      _error = 'This fixture link is invalid.';
    } else if (_fixture == null || _teams == null) {
      _loadMissingData();
    } else {
      _loadDetails();
    }
  }

  Future<void> _loadMissingData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final matchesRepository = sl<MatchesRepository>();
    final bootstrapRepository = sl<BootstrapRepository>();
    Either<Failure, FixtureModel?>? fixtureResult;
    Either<Failure, BootstrapModel>? bootstrapResult;

    if (_fixture == null) {
      fixtureResult = await matchesRepository.getFixtureById(widget.fixtureId);
    }
    if (_teams == null) {
      bootstrapResult = await bootstrapRepository.getBootstrap();
    }
    if (!mounted) return;

    String? error;
    fixtureResult?.fold((failure) => error = failure.errMessage, (fixture) {
      if (fixture == null) error = 'Fixture details are unavailable.';
      _fixture = fixture;
    });
    bootstrapResult?.fold(
      (failure) => error ??= failure.errMessage,
      (bootstrap) => _teams = bootstrap.teamsMap,
    );

    setState(() {
      _loading = false;
      _error = _fixture == null ? error : null;
    });
    if (_fixture != null) _loadDetails();
  }

  Future<void> _loadDetails() async {
    final fixture = _fixture;
    if (fixture == null || !sl.isRegistered<MatchDetailsCubit>()) return;
    _detailsCubit ??= sl<MatchDetailsCubit>();
    developer.log(
      'screen load started fpl_fixture_id=${fixture.id} candidate_pl_id=${fixture.code}',
      name: 'match_details.screen',
    );
    setState(() {
      _detailsLoading = true;
      _detailsError = null;
    });
    try {
      await _detailsCubit!.load(
        fixture,
        homeTeamName: _teams?[fixture.homeTeamId]?.name,
        awayTeamName: _teams?[fixture.awayTeamId]?.name,
      );
      if (!mounted) return;
      final state = _detailsCubit!.state;
      setState(() {
        if (state is MatchDetailsLoaded) {
          _details = state.details;
          if (state.details.failedSections.isNotEmpty) {
            _detailsError = 'Some match detail sections could not be loaded.';
          }
        }
        if (state is MatchDetailsError) _detailsError = state.message;
      });
      developer.log(
        'screen received ${state.runtimeType}',
        name: 'match_details.screen',
      );
    } catch (error, stackTrace) {
      developer.log(
        'screen load threw: $error',
        name: 'match_details.screen',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(
          () =>
              _detailsError =
                  'Match details failed to load. FPL fixture data is still shown.',
        );
      }
    } finally {
      if (mounted) setState(() => _detailsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.lineupSurface,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.appColors.lineupSurface.withValues(alpha: .96),
        leadingWidth: 44,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/matches');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
        ),
        titleSpacing: 0,
        title: const Text('Match\nDetail', style: TextStyle(height: 1.1)),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: context.appColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              if (widget.fixtureId > 0) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loadMissingData,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final fixture = _fixture;
    if (fixture == null) {
      return const Center(child: Text('Fixture details are unavailable.'));
    }
    final teams = _teams ?? const <int, TeamModel>{};
    final homeTeam =
        fixture.homeTeamId == null ? null : teams[fixture.homeTeamId];
    final awayTeam =
        fixture.awayTeamId == null ? null : teams[fixture.awayTeamId];
    final kickoff = (fixture.kickoffTime ?? _details?.kickoff)?.toLocal();
    final isLive =
        fixture.started == true &&
        fixture.finished != true &&
        fixture.finishedProvisional != true;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
      children: [
        _MatchHeader(
          fixture: fixture,
          isLive: isLive,
          matchweek: _details?.matchweek,
        ),
        _ScoreboardHero(
          fixture: fixture,
          details: _details,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          kickoff: kickoff,
          isLive: isLive,
        ),
        _MatchReportCard(stadium: _details?.stadium),
        _MatchDynamicsSection(details: _details, loading: _detailsLoading),
        if (_detailsError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _detailsError ??
                        'Some Premier League details are unavailable. FPL match information is still shown.',
                    style: TextStyle(
                      color: context.appColors.lineupTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton(onPressed: _loadDetails, child: const Text('Retry')),
              ],
            ),
          ),
        _MatchTabs(
          selectedIndex: _selectedTab,
          onSelected: (index) => setState(() => _selectedTab = index),
        ),
        _MatchTimelineSection(
          selectedTab: _selectedTab,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          details: _details,
          loading: _detailsLoading,
        ),
        _ManagerQuotesSection(homeTeam: homeTeam, awayTeam: awayTeam),
      ],
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({
    required this.fixture,
    required this.isLive,
    this.matchweek,
  });

  final FixtureModel fixture;
  final bool isLive;
  final int? matchweek;

  @override
  Widget build(BuildContext context) {
    final week = matchweek ?? fixture.gameweek;
    final finished =
        fixture.finished == true || fixture.finishedProvisional == true;
    final minutes = fixture.minutes;
    final status =
        finished
            ? 'FULL TIME'
            : isLive
            ? minutes != null && minutes > 0
                ? "LIVE · $minutes'"
                : 'LIVE'
            : 'UPCOMING';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.appColors.lineupMint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'PREMIER LEAGUE${week == null ? '' : '  ·  Matchweek $week'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appColors.lineupText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: .3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: context.appColors.lineupControl,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  finished ? Icons.sports_soccer_rounded : Icons.circle,
                  size: finished ? 10 : 7,
                  color:
                      isLive || finished
                          ? context.appColors.lineupMint
                          : context.appColors.lineupTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color:
                        isLive || finished
                            ? context.appColors.lineupMint
                            : context.appColors.lineupTextSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreboardHero extends StatelessWidget {
  const _ScoreboardHero({
    required this.fixture,
    required this.details,
    required this.homeTeam,
    required this.awayTeam,
    required this.kickoff,
    required this.isLive,
  });

  final FixtureModel fixture;
  final PremierLeagueMatchDetails? details;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final DateTime? kickoff;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final homeScore = details?.homeTeam?.score ?? fixture.homeScore;
    final awayScore = details?.awayTeam?.score ?? fixture.awayScore;
    final halfTimeHome = details?.homeTeam?.halfTimeScore;
    final halfTimeAway = details?.awayTeam?.halfTimeScore;
    final hasScore = homeScore != null && awayScore != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              left: -50,
              top: -65,
              child: _AmbientGlow(
                color: context.appColors.lineupPurple.withValues(alpha: .13),
              ),
            ),
            Positioned(
              right: -65,
              bottom: -70,
              child: _AmbientGlow(
                color: const Color(0xFFFF5451).withValues(alpha: .11),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: _scoreboardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 25,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 108,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ScoreboardTeam(team: homeTeam, label: 'HOME'),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  hasScore ? '$homeScore - $awayScore' : 'vs',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: context.appColors.lineupText,
                                    fontSize: hasScore ? 26 : 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (fixture.finished == true ||
                                  fixture.finishedProvisional == true)
                                _SmallPill(label: 'FULL TIME')
                              else if (isLive)
                                _SmallPill(
                                  label:
                                      fixture.minutes != null &&
                                              fixture.minutes! > 0
                                          ? "${fixture.minutes}'"
                                          : 'LIVE',
                                  color: context.appColors.lineupMint,
                                )
                              else
                                _SmallPill(label: 'KICK OFF'),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _ScoreboardTeam(team: awayTeam, label: 'AWAY'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (halfTimeHome != null && halfTimeAway != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Half-time  $halfTimeHome - $halfTimeAway',
                        style: TextStyle(
                          color: context.appColors.lineupTextSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  _MatchMetadataStrip(
                    kickoff: kickoff,
                    stadium: details?.stadium,
                    attendance: details?.attendance,
                    referee: details?.referee,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    height: 160,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color, blurRadius: 48, spreadRadius: 22)],
    ),
  );
}

class _ScoreboardTeam extends StatelessWidget {
  const _ScoreboardTeam({required this.team, required this.label});

  final TeamModel? team;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0x9932343F),
            shape: BoxShape.circle,
          ),
          child: _ClubBadge(team: team, size: 48),
        ),
        const SizedBox(height: 7),
        Text(
          team?.name ?? 'Team unavailable',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.appColors.lineupText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
      ],
    );
  }
}

class _ClubBadge extends StatelessWidget {
  const _ClubBadge({required this.team, required this.size});

  final TeamModel? team;
  final double size;

  @override
  Widget build(BuildContext context) {
    final teamCode = int.tryParse(team?.code ?? '');
    final fallback = SizedBox(
      width: size,
      height: size,
      child: Icon(
        Icons.shield_rounded,
        color: context.appColors.lineupLavender,
        size: size * .62,
      ),
    );
    if (teamCode == null || teamCode <= 0) return fallback;
    return CachedNetworkImage(
      imageUrl: '${AppConstants.teamBadgeBase}$teamCode.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class _MatchMetadataStrip extends StatelessWidget {
  const _MatchMetadataStrip({
    required this.kickoff,
    this.stadium,
    this.attendance,
    this.referee,
  });

  final DateTime? kickoff;
  final String? stadium;
  final int? attendance;
  final String? referee;

  @override
  Widget build(BuildContext context) {
    final dateText =
        kickoff == null
            ? 'Date unavailable'
            : '${MaterialLocalizations.of(context).formatShortDate(kickoff!)} · ${TimeOfDay.fromDateTime(kickoff!).format(context)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: context.appColors.lineupControl.withValues(alpha: .52),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 7,
        children: [
          _MetadataItem(icon: Icons.calendar_today_rounded, label: dateText),
          _MetadataItem(
            icon: Icons.stadium_rounded,
            label: stadium ?? 'Venue unavailable',
          ),
          _MetadataItem(
            icon: Icons.groups_rounded,
            label:
                attendance == null
                    ? 'Attendance unavailable'
                    : 'Attendance ${attendance!}',
          ),
          _MetadataItem(
            icon: Icons.sports_rounded,
            label: referee ?? 'Referee unavailable',
          ),
        ],
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: context.appColors.lineupTextSecondary, size: 11),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          color: context.appColors.lineupTextSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: .15,
        ),
      ),
    ],
  );
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: context.appColors.lineupBackground.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      maxLines: 1,
      style: TextStyle(
        color: color ?? context.appColors.lineupTextSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: .3,
      ),
    ),
  );
}

class _MatchReportCard extends StatelessWidget {
  const _MatchReportCard({this.stadium});
  final String? stadium;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.lineupPanel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                color: context.appColors.lineupLavender,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'MATCH REPORT',
                style: TextStyle(
                  color: context.appColors.lineupLavender,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                ),
              ),
              Spacer(),
              Text(
                stadium ?? 'Venue unavailable',
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Match report unavailable',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: context.appColors.lineupText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'An editorial recap is not provided by the available match data.',
            style: TextStyle(
              color: context.appColors.lineupTextSecondary,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MatchDynamicsSection extends StatelessWidget {
  const _MatchDynamicsSection({this.details, this.loading = false});
  final PremierLeagueMatchDetails? details;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    const labels = ['Possession', 'Total Shots', 'On Target'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Match Dynamics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.appColors.lineupText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                loading
                    ? 'Loading stats…'
                    : (details?.statistics.isNotEmpty == true
                        ? 'Match stats'
                        : 'No verified stats'),
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _DynamicsTile(
                    label: labels[i],
                    value: _dynamicValue(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String? _dynamicValue(int index) {
    final home = details?.statistics['home'];
    final away = details?.statistics['away'];
    if (home == null || away == null) return null;
    final keys = switch (index) {
      0 => const ['possessionPercentage', 'possession'],
      1 => const ['totalScoringAtt', 'totalShots'],
      _ => const ['ontargetScoringAtt', 'shotsOnTarget'],
    };
    num? value(Map<String, num> stats) {
      for (final key in keys) {
        if (stats[key] != null) return stats[key];
      }
      return null;
    }

    final h = value(home), a = value(away);
    if (h == null || a == null) return null;
    if (index == 0) {
      return '${h.toStringAsFixed(0)}% - ${a.toStringAsFixed(0)}%';
    }
    return '${h.toStringAsFixed(0)} - ${a.toStringAsFixed(0)}';
  }
}

class _DynamicsTile extends StatelessWidget {
  const _DynamicsTile({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Container(
    height: 118,
    padding: const EdgeInsets.fromLTRB(7, 8, 7, 9),
    decoration: BoxDecoration(
      color: context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value ?? '— - —',
            style: TextStyle(
              color: context.appColors.lineupText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value == null ? 'Unavailable' : 'Home - Away',
          style: TextStyle(color: context.appColors.textMuted, fontSize: 8),
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 5,
            child: ColoredBox(color: context.appColors.lineupControl),
          ),
        ),
      ],
    ),
  );
}

class _MatchTabs extends StatelessWidget {
  const _MatchTabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const tabs = [
    'Timeline',
    'Lineups',
    'Stats',
    'Commentary',
    'Table Impact',
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _TabPill(
              label: tabs[i],
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    ),
  );
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color:
        selected
            ? context.appColors.lineupLavender
            : context.appColors.lineupPanel,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected
                    ? context.appColors.marketSelectedText
                    : context.appColors.lineupTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .15,
          ),
        ),
      ),
    ),
  );
}

class _MatchTimelineSection extends StatelessWidget {
  const _MatchTimelineSection({
    required this.selectedTab,
    required this.homeTeam,
    required this.awayTeam,
    required this.details,
    required this.loading,
  });

  final int selectedTab;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final PremierLeagueMatchDetails? details;
  final bool loading;

  static const tabContent = [
    (
      'Match timeline unavailable',
      'Verified event data is not available for this fixture.',
    ),
    (
      'Lineups unavailable',
      'Confirmed lineups are not included in the available match data.',
    ),
    (
      'Stats unavailable',
      'Verified match statistics are not available for this fixture.',
    ),
    (
      'Table impact unavailable',
      'Match table-impact data is not available here.',
    ),
    ('Commentary unavailable', 'Commentary is not available for this fixture.'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = tabContent[selectedTab.clamp(0, tabContent.length - 1)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _TimelineTeamName(team: homeTeam, isHome: true)),
              Text(
                selectedTab == 0 ? 'Match Log' : _MatchTabs.tabs[selectedTab],
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .35,
                ),
              ),
              Expanded(child: _TimelineTeamName(team: awayTeam, isHome: false)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.appColors.lineupPanel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _content(context, selected),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, (String, String) selected) {
    if (loading && details == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    switch (selectedTab) {
      case 0:
        final events = details?.events ?? const <MatchEvent>[];
        if (events.isEmpty) return _empty(context, selected);
        return Column(
          children: events.map((event) => _eventRow(context, event)).toList(),
        );
      case 1:
        final home = details?.homeLineup;
        final away = details?.awayLineup;
        if (home?.players.isEmpty != false && away?.players.isEmpty != false) {
          return _empty(context, selected);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lineupGroup(context, 'HOME · ${homeTeam?.shortName ?? ''}', home),
            const SizedBox(height: 12),
            _lineupGroup(context, 'AWAY · ${awayTeam?.shortName ?? ''}', away),
          ],
        );
      case 2:
        final home = details?.statistics['home'];
        final away = details?.statistics['away'];
        if (home == null && away == null) return _empty(context, selected);
        final keys = {...?home?.keys, ...?away?.keys}.toList()..sort();
        return Column(
          children:
              keys
                  .take(40)
                  .map(
                    (key) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              home?[key]?.toString() ?? '—',
                              style: TextStyle(
                                color: context.appColors.lineupText,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _statLabel(key),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.appColors.lineupTextSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              away?[key]?.toString() ?? '—',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: context.appColors.lineupText,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        );
      case 3:
        final lines = details?.commentary ?? const <MatchCommentary>[];
        if (lines.isEmpty) return _empty(context, selected);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              lines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text(
                              line.time?.trim().isNotEmpty == true
                                  ? line.time!
                                  : 'FT',
                              style: TextStyle(
                                color: context.appColors.lineupLavender,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line.text ?? 'Commentary unavailable',
                              style: TextStyle(
                                color: context.appColors.lineupText,
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        );
      default:
        return _empty(context, selected);
    }
  }

  Widget _empty(BuildContext context, (String, String) selected) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: context.appColors.lineupTextSecondary,
          ),
          const SizedBox(height: 7),
          Text(
            selected.$1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColors.lineupText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selected.$2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColors.lineupTextSecondary,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _eventRow(BuildContext context, MatchEvent event) {
    final player = _playerName(event.playerId);
    final desc = switch (event.kind) {
      'goal' =>
        '${event.goalType == 'Own' ? 'Own goal · ' : ''}$player${event.assistPlayerId == null ? '' : ' (assist: ${_playerName(event.assistPlayerId)})'}',
      'card' => '${event.cardType ?? 'Card'} · $player',
      'substitution' =>
        'Substitution · ${_playerName(event.playerOnId)} for ${_playerName(event.playerOffId)}',
      _ => 'Match event',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              event.minute == null ? '—' : "${event.minute}'",
              style: TextStyle(
                color: context.appColors.lineupLavender,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          Icon(
            event.kind == 'goal'
                ? Icons.sports_soccer_rounded
                : event.kind == 'card'
                ? Icons.rectangle_rounded
                : Icons.swap_horiz_rounded,
            size: 15,
            color: context.appColors.lineupLavender,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                color: context.appColors.lineupText,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _playerName(int? id) {
    if (id == null) return 'Player unavailable';
    for (final player in [
      ...?details?.homeLineup?.players,
      ...?details?.awayLineup?.players,
    ]) {
      if (player.id == id && player.name?.isNotEmpty == true) {
        return player.name!;
      }
    }
    return 'Player unavailable';
  }

  Widget _lineupGroup(
    BuildContext context,
    String title,
    MatchLineup? lineup,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$title${lineup?.formation == null ? '' : ' · ${lineup!.formation}'}',
        style: TextStyle(
          color: context.appColors.lineupLavender,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 5),
      if (lineup == null)
        Text(
          'Lineup unavailable',
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 10,
          ),
        )
      else ...[
        _playerList(context, 'Starting XI', lineup.starters),
        const SizedBox(height: 5),
        _playerList(context, 'Substitutes', lineup.substitutes),
      ],
    ],
  );

  Widget _playerList(
    BuildContext context,
    String label,
    List<MatchPlayer> players,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: context.appColors.lineupTextSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (players.isEmpty)
        Text(
          'Unavailable',
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 10,
          ),
        )
      else
        for (final p in players)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              '${p.number == null ? '' : '${p.number}  '}${p.name?.isNotEmpty == true ? p.name : 'Player unavailable'}${p.captain ? ' · C' : ''}  ${p.position == 'Substitute' ? p.subPosition ?? '' : p.position ?? ''}',
              style: TextStyle(
                color: context.appColors.lineupText,
                fontSize: 10,
              ),
            ),
          ),
    ],
  );

  String _statLabel(String key) =>
      key
          .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
          .replaceAll('_', ' ')
          .trim();
}

class _TimelineTeamName extends StatelessWidget {
  const _TimelineTeamName({required this.team, required this.isHome});

  final TeamModel? team;
  final bool isHome;

  String get name => team?.shortName ?? (isHome ? 'HOME' : 'AWAY');

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
    children: [
      if (!isHome) ...[
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  isHome
                      ? context.appColors.lineupLavender
                      : const Color(0xFFFFB3AD),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
        ),
        const SizedBox(width: 5),
        _ClubBadge(team: team, size: 13),
      ] else ...[
        _ClubBadge(team: team, size: 13),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.appColors.lineupLavender,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
        ),
      ],
    ],
  );
}

class _ManagerQuotesSection extends StatelessWidget {
  const _ManagerQuotesSection({required this.homeTeam, required this.awayTeam});

  final TeamModel? homeTeam;
  final TeamModel? awayTeam;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.lineupPanel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manager Quotes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.appColors.lineupText,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _UnavailableQuoteCard(
            side: 'HOME',
            team: homeTeam,
            accent: context.appColors.lineupLavender,
          ),
          const SizedBox(height: 8),
          _UnavailableQuoteCard(
            side: 'AWAY',
            team: awayTeam,
            accent: Color(0xFFFFB3AD),
          ),
        ],
      ),
    ),
  );
}

class _UnavailableQuoteCard extends StatelessWidget {
  const _UnavailableQuoteCard({
    required this.side,
    required this.team,
    required this.accent,
  });

  final String side;
  final TeamModel? team;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: context.appColors.lineupSurface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$side MANAGER',
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                team?.shortName ?? 'Team unavailable',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'No verified manager quote is available for this team.',
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 11,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}
