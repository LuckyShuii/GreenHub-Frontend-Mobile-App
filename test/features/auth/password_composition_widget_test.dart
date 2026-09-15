import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/auth/widgets/password_composition_widget.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('matches the Figma panel size and requirement styles', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 365,
              child: PasswordCompositionWidget(
                controller: controller,
                password: 'ABCDEFGHIJ1!',
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('password-composition-panel'))),
      const Size(365, 170),
    );
    expect(find.text('• Min. 12 caractères'), findsOneWidget);
    expect(find.text('• Min. 1 majuscule'), findsOneWidget);
    expect(find.text('• Min. 1 minuscule'), findsOneWidget);
    expect(find.text('• Min. 1 chiffre'), findsOneWidget);
    expect(find.text('• Min. 1 caractère spécial'), findsOneWidget);

    final Text uppercaseRequirement = tester.widget<Text>(
      find.byKey(const Key('password-requirement-Min. 1 majuscule')),
    );
    final Text lowercaseRequirement = tester.widget<Text>(
      find.byKey(const Key('password-requirement-Min. 1 minuscule')),
    );

    expect(uppercaseRequirement.style?.color, AppColors.v650);
    expect(lowercaseRequirement.style?.color, AppColors.o300);
  });

  testWidgets('does not overflow when text is enlarged', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: PasswordCompositionWidget(
                  controller: controller,
                  password: 'A',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
