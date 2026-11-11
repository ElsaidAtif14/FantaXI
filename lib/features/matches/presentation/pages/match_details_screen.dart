import 'dart:developer' as developer;

import 'package:dartz/dartz.dart' show Either;
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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fantasy/features/matches/presentation/widgets/commentary_view.dart';
import 'package:fantasy/features/matches/presentation/widgets/lineups_view.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_dynamics_section.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_facts_section.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_header_strip.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_status_pill.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_empty_state.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_tabs.dart';
import 'package:fantasy/features/matches/presentation/widgets/scoreboard_hero.dart';
import 'package:fantasy/features/matches/presentation/widgets/statistics_view.dart';
import 'package:fantasy/features/matches/presentation/widgets/timeline_view.dart';
import 'package:go_router/go_router.dart';

/// Formats a live match minute for display. Stoppage time is capped at 90 by
/// FPL, so a live fixture sitting on 90 is shown as `90+'`.
String _liveMinuteLabel(int? minutes) {
  if (minutes == null || minutes <= 0) return '';
  return minutes >= 90 ? "90+'" : "$minutes'";
}

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
        title: const Text('Match Details', style: TextStyle(height: 1.1)),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      // Unified skeleton loading (same pattern as the matches list screen).
      final dummyFixture = FixtureModel.dummy(
        gameweek: null,
        id: widget.fixtureId,
      );
      return Skeletonizer(
        enabled: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
          children: [
            const MatchHeaderStrip(
              competition: 'Premier League',
              matchweek: null,
            ),
            ScoreboardHero(
              fixture: dummyFixture,
              details: null,
              homeTeam: null,
              awayTeam: null,
              kickoff: null,
              status: MatchStatusKind.upcoming,
              liveMinute: null,
            ),
            MatchFactsSection(
              fixture: dummyFixture,
              details: null,
              kickoff: null,
            ),
            MatchDynamicsSection(
              details: null,
              homeTeam: null,
              awayTeam: null,
              loading: true,
            ),
            MatchTabs(selectedIndex: 0, onSelected: (_) {}),
            _MatchTimelineSection(
              selectedTab: 0,
              homeTeam: null,
              awayTeam: null,
              details: null,
              finished: false,
            ),
          ],
        ),
      );
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
    final isLive = fixture.isLive;
    final status =
        fixture.isFinished
            ? MatchStatusKind.fullTime
            : isLive
            ? MatchStatusKind.live
            : MatchStatusKind.upcoming;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
      children: [
        MatchHeaderStrip(
          competition: _details?.competition ?? 'Premier League',
          matchweek: _details?.matchweek ?? fixture.gameweek,
        ),
        ScoreboardHero(
          fixture: fixture,
          details: _details,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          kickoff: kickoff,
          status: status,
          liveMinute: _liveMinuteLabel(fixture.minutes),
        ),
        MatchFactsSection(
          fixture: fixture,
          details: _details,
          kickoff: kickoff,
        ),
        MatchDynamicsSection(
          details: _details,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          loading: _detailsLoading,
        ),
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
        MatchTabs(
          selectedIndex: _selectedTab,
          onSelected: (index) => setState(() => _selectedTab = index),
        ),
        _MatchTimelineSection(
          selectedTab: _selectedTab,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          details: _details,
          finished: fixture.isFinished,
        ),
      ],
    );
  }
}

class _MatchTimelineSection extends StatelessWidget {
  const _MatchTimelineSection({
    required this.selectedTab,
    required this.homeTeam,
    required this.awayTeam,
    required this.details,
    required this.finished,
  });

  final int selectedTab;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final PremierLeagueMatchDetails? details;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: switch (selectedTab) {
        0 => TimelineView(
          details: details,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          finished: finished,
        ),
        1 => LineupsView(
          details: details,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        ),
        2 => StatisticsView(
          details: details,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        ),
        3 => CommentaryView(details: details),
        // The Table Impact tab stays with an honest empty state: the API does
        // not provide table-impact data on this screen.
        _ => const SectionEmptyState(
          icon: Icons.table_chart_rounded,
          title: 'Table impact unavailable',
          message: 'Match table-impact data is not available here.',
        ),
      },
    );
  }
}
