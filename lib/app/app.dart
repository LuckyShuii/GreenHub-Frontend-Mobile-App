import 'package:flutter/material.dart';

import '../shared/theme/app_theme.dart';
import '../shared/widgets/app_notification_host_widget.dart';
import 'router.dart';

class GreenHubApp extends StatelessWidget {
  const GreenHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GreenHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (BuildContext context, Widget? child) {
        return AppNotificationHost(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
