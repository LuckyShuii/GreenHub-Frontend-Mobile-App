import 'package:go_router/go_router.dart';

import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.landing,
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
