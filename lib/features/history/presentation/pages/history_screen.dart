import 'package:fantasy/features/history/presentation/widgets/history_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/history/presentation/cubit/history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryCubit>(),
      child: FutureBuilder<int>(
        future: SharedPreferences.getInstance().then(
          (p) => p.getInt(AppConstants.entryIdKey) ?? 0,
        ),
        builder: (context, snap) {
          if (snap.hasData && snap.data! > 0) {
            context.read<HistoryCubit>().loadHistory(snap.data!);
          }
          return const HistoryViewBody();
        },
      ),
    );
  }
}
