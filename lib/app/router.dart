import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_session.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/widgets/home_bottom_navigation_widget.dart';
import '../features/home/widgets/home_navigation_shell_widget.dart';
import '../shared/screens/page_under_construction_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String home = '/home';
  static const String seasonalVegetables = '/seasonal-vegetables';
  static const String sortingGuide = '/sorting-guide';
  static const String community = '/community';
  static const String map = '/map';
  static const String wasteScan = '/waste-scan';
  static const String settings = '/settings';
}

const Set<String> _publicRoutes = <String>{
  AppRoutes.landing,
  AppRoutes.login,
  AppRoutes.forgotPassword,
  AppRoutes.register,
};

GoRouter createAppRouter(
  AuthSession authSession, {
  String initialLocation = AppRoutes.landing,
}) {
  final GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>();
  late final GoRouter router;
  router = GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authSession,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      if (authSession.isAuthenticated && isPublicRoute) {
        return AppRoutes.home;
      }
      if (!authSession.isAuthenticated && !isPublicRoute) {
        return AppRoutes.landing;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(authSession: authSession),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: homeNavigatorKey,
        builder: (context, state, child) => ListenableBuilder(
          listenable: router.routerDelegate,
          builder: (context, _) {
            final String location =
                router.routerDelegate.currentConfiguration.last.matchedLocation;
            final HomeNavigationDestination destination = switch (location) {
              AppRoutes.map => HomeNavigationDestination.map,
              AppRoutes.wasteScan => HomeNavigationDestination.scan,
              _ => HomeNavigationDestination.home,
            };
            return HomeNavigationShellWidget(
              destination: destination,
              isActive:
                  location == AppRoutes.home ||
                  location == AppRoutes.map ||
                  location == AppRoutes.wasteScan,
              onMap: () => context.push<void>(AppRoutes.map),
              onScan: () => context.push<void>(AppRoutes.wasteScan),
              child: child,
            );
          },
        ),
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => HomeScreen(authSession: authSession),
          ),
          for (final String path in <String>[
            AppRoutes.map,
            AppRoutes.wasteScan,
          ])
            _constructionRoute(path),
        ],
      ),
      for (final String path in <String>[
        AppRoutes.seasonalVegetables,
        AppRoutes.sortingGuide,
        AppRoutes.community,
        AppRoutes.settings,
      ])
        _constructionRoute(path),
    ],
  );
  return router;
}

GoRoute _constructionRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) => PageUnderConstructionScreen(
    onBack: () {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    },
  ),
);
