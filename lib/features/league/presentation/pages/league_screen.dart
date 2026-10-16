import 'package:fantasy/features/league/presentation/cubit/league_cubit.dart';
import 'package:fantasy/features/league/presentation/widgets/league_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/core/di/injection.dart';
class LeagueScreen extends StatelessWidget {
  final int leagueId;
  const LeagueScreen({super.key, required this.leagueId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LeagueCubit>()..loadLeague(leagueId),
      child: const LeagueViewBody(),
    );
  }
}
