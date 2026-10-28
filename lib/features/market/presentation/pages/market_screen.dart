import 'package:fantasy/features/market/presentation/widgets/market_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BootstrapCubit>()..loadBootstrap(),
      child: const MarketViewBody(),
    );
  }
}
