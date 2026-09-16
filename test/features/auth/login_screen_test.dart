import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/auth/screens/login_screen.dart';
import 'package:flutter_frontend/shared/services/app_notification_service.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_frontend/shared/widgets/app_notification_host_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a shared success notification after valid submission', (
    WidgetTester tester,
  ) async {
    final AppNotificationService controller = AppNotificationService();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppNotificationHost(
          controller: controller,
          child: const LoginScreen(),
        ),
      ),
    );

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'antoine@example.com');
    await tester.enterText(fields.at(1), 'mot-de-passe');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final Finder notification = find.byKey(
      const Key('app-notification-success'),
    );
    final BoxDecoration decoration =
        tester.widget<Container>(notification).decoration! as BoxDecoration;
    expect(find.text('Connexion simulée avec succès.'), findsOneWidget);
    expect(decoration.color, AppColors.succes);
    expect(find.byType(SnackBar), findsNothing);

    controller.reset();
    await tester.pump();
    controller.dispose();
  });
}
