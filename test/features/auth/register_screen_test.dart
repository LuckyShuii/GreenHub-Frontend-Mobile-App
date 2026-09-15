import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/auth/screens/register_screen.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpRegisterScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 1292);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RegisterScreen()),
    );
  }

  Finder registrationButton() =>
      find.widgetWithText(FilledButton, 'Inscription');

  Finder confirmationField() => find.descendant(
    of: find.byKey(const Key('register-password-confirmation')),
    matching: find.byType(TextFormField),
  );

  testWidgets('shows password requirements after the user starts typing', (
    WidgetTester tester,
  ) async {
    await pumpRegisterScreen(tester);

    expect(find.text('• Min. 12 caractères'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('password-composition-panel'))),
      const Size(365, 50),
    );

    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      'A',
    );
    await tester.pump();

    expect(find.text('• Min. 12 caractères'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('password-composition-panel'))),
      const Size(365, 170),
    );

    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      '',
    );
    await tester.pump();

    expect(find.text('• Min. 12 caractères'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('password-composition-panel'))),
      const Size(365, 50),
    );
  });

  testWidgets(
    'keeps registration disabled until password and confirmation match',
    (WidgetTester tester) async {
      await pumpRegisterScreen(tester);

      expect(
        tester.widget<FilledButton>(registrationButton()).onPressed,
        isNull,
      );

      await tester.enterText(
        find.byKey(const Key('register-password-field')),
        'Abcdefghij1!',
      );
      await tester.pump();

      expect(
        tester.widget<FilledButton>(registrationButton()).onPressed,
        isNull,
      );

      await tester.enterText(confirmationField(), 'Abcdefghij1!');
      await tester.pump();

      expect(
        tester.widget<FilledButton>(registrationButton()).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('shows the mismatch message for a different confirmation', (
    WidgetTester tester,
  ) async {
    await pumpRegisterScreen(tester);

    await tester.enterText(
      find.byKey(const Key('register-password-field')),
      'Abcdefghij1!',
    );
    await tester.enterText(confirmationField(), 'Abcdefghij2!');
    await tester.pump();

    expect(
      find.text('Les mots de passes ne correspondent pas'),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(registrationButton()).onPressed, isNull);
  });
}
