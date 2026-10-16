import 'package:go_router/go_router.dart';
import 'package:fantasy/features/splash/presentation/pages/splash_screen.dart';
import 'package:fantasy/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:fantasy/features/home/presentation/pages/home_screen.dart';
import 'package:fantasy/features/league/presentation/pages/league_screen.dart';
import 'package:fantasy/features/history/presentation/pages/history_screen.dart';
import 'package:fantasy/features/picks/presentation/pages/picks_screen.dart';
import 'package:fantasy/features/live/presentation/pages/live_screen.dart';
import 'package:fantasy/features/market/presentation/pages/market_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String league = '/league/:id';
  static const String history = '/history';
  static const String picks = '/picks';
  static const String live = '/live';
  static const String market = '/market';

  static GoRouter get router => GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/league/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LeagueScreen(leagueId: id);
        },
      ),
      GoRoute(
        path: history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: picks,
        builder: (context, state) {
          final entryId = int.tryParse(
            state.uri.queryParameters['entryId'] ?? '',
          );
          final gw = int.tryParse(state.uri.queryParameters['gw'] ?? '');
          return PicksScreen(entryId: entryId, initialGw: gw);
        },
      ),
      GoRoute(path: live, builder: (context, state) => const LiveScreen()),
      GoRoute(path: market, builder: (context, state) => const MarketScreen()),
    ],
  );
}
