import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/auth/screens/login_screen.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the simulated login error after valid submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    );

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'antoine@example.com');
    await tester.enterText(fields.at(1), 'mot-de-passe');
    await tester.tap(find.widgetWithText(FilledButton, 'Connexion'));
    await tester.pump();

    expect(find.text('Email ou mot de passe est incorrect'), findsOneWidget);
  });
}
