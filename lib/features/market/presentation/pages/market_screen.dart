import 'package:fantasy/features/market/presentation/widgets/market_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BootstrapCubit>()..loadBootstrap(),
      child: BlocProvider(
        create: (_) => sl<ManagerCubit>(),
        child: const _MarketManagerLoader(),
      ),
    );
  }
}

class _MarketManagerLoader extends StatefulWidget {
  const _MarketManagerLoader();

  @override
  State<_MarketManagerLoader> createState() => _MarketManagerLoaderState();
}

class _MarketManagerLoaderState extends State<_MarketManagerLoader> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((preferences) {
      final entryId = preferences.getInt(AppConstants.entryIdKey);
      if (mounted && entryId != null && entryId > 0) {
        context.read<ManagerCubit>().loadManager(entryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const MarketViewBody();
}
