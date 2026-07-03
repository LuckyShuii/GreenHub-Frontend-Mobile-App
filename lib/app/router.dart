import 'package:go_router/go_router.dart';

import '../features/auth/screens/landing_page.dart';
import '../features/auth/screens/login_page.dart';
import '../features/auth/screens/register_page.dart';

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
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);
