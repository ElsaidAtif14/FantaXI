import 'package:get_it/get_it.dart';
import 'package:fantasy/core/network/dio_client.dart';
import 'package:fantasy/features/manager/data/repositories/manager_repository_impl.dart';
import 'package:fantasy/features/manager/domain/repositories/manager_repository.dart';
import 'package:fantasy/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:fantasy/features/league/data/repositories/league_repository_impl.dart';
import 'package:fantasy/features/league/domain/repositories/league_repository.dart';
import 'package:fantasy/features/league/presentation/cubit/league_cubit.dart';
import 'package:fantasy/features/history/data/repositories/history_repository_impl.dart';
import 'package:fantasy/features/history/domain/repositories/history_repository.dart';
import 'package:fantasy/features/history/presentation/cubit/history_cubit.dart';
import 'package:fantasy/features/picks/data/repositories/picks_repository_impl.dart';
import 'package:fantasy/features/picks/domain/repositories/picks_repository.dart';
import 'package:fantasy/features/picks/presentation/cubit/picks_cubit.dart';
import 'package:fantasy/features/bootstrap/data/repositories/bootstrap_repository_impl.dart';
import 'package:fantasy/features/bootstrap/domain/repositories/bootstrap_repository.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/live/data/repositories/live_repository_impl.dart';
import 'package:fantasy/features/live/domain/repositories/live_repository.dart';
import 'package:fantasy/features/live/presentation/cubit/live_cubit.dart';
import 'package:fantasy/features/matches/data/repositories/matches_repository_impl.dart';
import 'package:fantasy/features/matches/domain/repositories/matches_repository.dart';
import 'package:fantasy/features/matches/presentation/cubit/matches_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Repositories
  sl.registerLazySingleton<ManagerRepository>(
    () => ManagerRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LeagueRepository>(() => LeagueRepositoryImpl(sl()));
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PicksRepository>(() => PicksRepositoryImpl(sl()));
  sl.registerLazySingleton<BootstrapRepository>(
    () => BootstrapRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LiveRepository>(() => LiveRepositoryImpl(sl()));
  sl.registerLazySingleton<MatchesRepository>(
    () => MatchesRepositoryImpl(sl()),
  );

  // Cubits (factory — new instance per page)
  sl.registerFactory<ManagerCubit>(() => ManagerCubit(sl()));
  sl.registerFactory<LeagueCubit>(() => LeagueCubit(sl()));
  sl.registerFactory<HistoryCubit>(() => HistoryCubit(sl()));
  sl.registerFactory<PicksCubit>(() => PicksCubit(sl()));
  sl.registerFactory<BootstrapCubit>(() => BootstrapCubit(sl()));
  sl.registerFactory<LiveCubit>(() => LiveCubit(sl()));
  sl.registerFactory<MatchesCubit>(() => MatchesCubit(sl(), sl()));
}
