import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:fantasy/features/matches/presentation/pages/match_details_screen.dart';
import 'package:fantasy/features/matches/presentation/widgets/fixture_day_section.dart';
import 'package:fantasy/features/matches/presentation/widgets/matchweek_navigation.dart';
import 'package:fantasy/features/picks/presentation/widgets/error_message_view.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';
import 'package:fantasy/shared/widgets/custom_app_bar.dart';
import 'package:fantasy/shared/cubit/dock_cubit.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MatchesCubit>()..loadInitial(),
      child: const _MatchesView(),
    );
  }
}

class _MatchesView extends StatefulWidget {
  const _MatchesView();

  @override
  State<_MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<_MatchesView>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  bool _isCurrentRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isCurrentRoute) {
      context.read<MatchesCubit>().refresh();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (_isCurrentRoute) context.read<DockCubit>().show();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || !_isCurrentRoute) return;
    context.read<DockCubit>().handleScroll(
      _scrollController.position.userScrollDirection,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          backgroundColor: context.appColors.lineupBackground,
          appBar: CustomAppBar(
            title: 'Matches',
            icons: Icons.refresh_rounded,
            showActions: true,
            onSettingsTap: () {
              context.read<MatchesCubit>().retry(); // تم تصحيحها هنا بإضافة ()
            },
          ),
          bottomNavigationBar: const AppNavigationDock(currentIndex: 3),
          body: Column(
            children: [
              MatchweekNavigation(
                gameweek: state.gameweek,
                maxGameweek: state.maxGameweek,
                enabled: state.gameweek != null,
                loading: state is MatchesLoading,
                subtitle:
                    state is MatchesLoaded
                        ? _dateRange(context, state.fixtures)
                        : 'Premier League',
                onPrevious:
                    () => context.read<MatchesCubit>().selectGameweek(
                      state.gameweek! - 1,
                    ),
                onNext:
                    () => context.read<MatchesCubit>().selectGameweek(
                      state.gameweek! + 1,
                    ),
              ),
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, MatchesState state) {
    if (state is MatchesLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          children: [
            FixtureDaySection(
              dateLabel: 'Saturday, 1 January',
              fixtures: List.generate(
                5,
                (index) =>
                    FixtureModel.dummy(id: index, gameweek: state.gameweek),
              ),
              teams: const {},
            ),
          ],
        ),
      );
    }
    if (state is MatchesError) {
      return Center(
        child: ErrorMessageView(
          icon: Icons.cloud_off_outlined,
          message: state.message,
          actionLabel: 'Try again',
          onAction: () => context.read<MatchesCubit>().retry(),
        ),
      );
    }
    if (state is MatchesLoaded) {
      if (state.fixtures.isEmpty) {
        return Center(
          child: Text(
            'No fixtures are scheduled for this matchweek.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appColors.textSecondary),
          ),
        );
      }

      final sections = _groupFixtures(context, state.fixtures);
      return RefreshIndicator(
        onRefresh: () => context.read<MatchesCubit>().refresh(),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return FixtureDaySection(
              dateLabel: section.label,
              fixtures: section.fixtures,
              teams: state.teams,
              onFixtureTap:
                  (fixture) => context.push(
                    '/matches/${fixture.id}',
                    extra: MatchDetailsArguments(
                      fixture: fixture,
                      teams: state.teams,
                    ),
                  ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _dateRange(BuildContext context, List<FixtureModel> fixtures) {
    final dates =
        fixtures
            .map((fixture) => fixture.kickoffTime?.toLocal())
            .whereType<DateTime>()
            .toList()
          ..sort();
    if (dates.isEmpty) return 'Premier League';
    final localizations = MaterialLocalizations.of(context);
    final first = localizations.formatShortDate(dates.first);
    final last = localizations.formatShortDate(dates.last);
    return first == last ? first : '$first – $last';
  }

  List<_FixtureSection> _groupFixtures(
    BuildContext context,
    List<FixtureModel> fixtures,
  ) {
    final dated = <DateTime, List<FixtureModel>>{};
    final undated = <FixtureModel>[];
    for (final fixture in fixtures) {
      final date = fixture.kickoffTime?.toLocal();
      if (date == null) {
        undated.add(fixture);
        continue;
      }
      final day = DateTime(date.year, date.month, date.day);
      dated.putIfAbsent(day, () => []).add(fixture);
    }

    final days = dated.keys.toList()..sort();
    final localizations = MaterialLocalizations.of(context);
    final sections =
        days
            .map(
              (day) => _FixtureSection(
                localizations.formatFullDate(day),
                dated[day]!..sort(_compareKickoff),
              ),
            )
            .toList();
    if (undated.isNotEmpty) {
      sections.add(_FixtureSection('Date unavailable', undated));
    }
    return sections;
  }

  int _compareKickoff(FixtureModel a, FixtureModel b) {
    return (a.kickoffTime ?? DateTime(9999)).compareTo(
      b.kickoffTime ?? DateTime(9999),
    );
  }
}

class _FixtureSection {
  const _FixtureSection(this.label, this.fixtures);

  final String label;
  final List<FixtureModel> fixtures;
}
