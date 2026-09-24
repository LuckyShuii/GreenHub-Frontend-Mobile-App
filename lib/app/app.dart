import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_session.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/app_notification_host_widget.dart';
import 'router.dart';

class GreenHubApp extends StatefulWidget {
  const GreenHubApp({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<GreenHubApp> createState() => _GreenHubAppState();
}

class _GreenHubAppState extends State<GreenHubApp> {
  late final GoRouter _router = createAppRouter(widget.authSession);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GreenHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      builder: (BuildContext context, Widget? child) {
        return AppNotificationHost(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
