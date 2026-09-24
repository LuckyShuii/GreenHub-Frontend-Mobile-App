import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_session.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String home = '/home';
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
  return GoRouter(
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomeScreen(authSession: authSession),
      ),
    ],
  );
}
