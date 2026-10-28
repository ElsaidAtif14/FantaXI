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
      child: const _HistoryLoader(),
    );
  }
}

class _HistoryLoader extends StatefulWidget {
  const _HistoryLoader();

  @override
  State<_HistoryLoader> createState() => _HistoryLoaderState();
}

class _HistoryLoaderState extends State<_HistoryLoader> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    final entryId = preferences.getInt(AppConstants.entryIdKey) ?? 0;
    if (entryId > 0) {
      context.read<HistoryCubit>().loadHistory(entryId);
    }
  }

  @override
  Widget build(BuildContext context) => const HistoryViewBody();
}
