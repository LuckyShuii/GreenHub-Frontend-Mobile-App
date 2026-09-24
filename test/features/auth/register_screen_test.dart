import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/models/register_request.dart';
import 'package:flutter_frontend/features/auth/data/models/user_response.dart';
import 'package:flutter_frontend/features/auth/screens/register_screen.dart';
import 'package:flutter_frontend/shared/services/app_notification_service.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_frontend/shared/widgets/app_notification_host_widget.dart';
import 'package:flutter_frontend/shared/widgets/auth_text_field_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpRegisterScreen(
    WidgetTester tester, {
    AuthApiService? authApiService,
    AppNotificationService? notificationService,
  }) async {
    tester.view.physicalSize = const Size(393, 1292);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppNotificationService controller =
        notificationService ?? AppNotificationService();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppNotificationHost(
          controller: controller,
          child: RegisterScreen(authApiService: authApiService),
        ),
      ),
    );
  }

  Finder registrationButton() =>
      find.widgetWithText(FilledButton, 'Inscription');

  Finder confirmationField() => find.descendant(
    of: find.byKey(const Key('register-password-confirmation')),
    matching: find.byType(TextFormField),
  );

  Future<void> submitValidRegistration(WidgetTester tester) async {
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Antoine');
    await tester.enterText(fields.at(1), 'Ribeyre');
    await tester.enterText(fields.at(2), 'antoine@example.com');
    await tester.enterText(fields.at(3), 'ant_oine');
    await tester.enterText(fields.at(5), 'Abcdefghij1!');
    await tester.enterText(fields.at(6), 'Abcdefghij1!');
    await tester.pump();
    await tester.tap(registrationButton());
    await tester.pump();
  }

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

  for (final String message in <String>[
    'Cette adresse e-mail est déjà utilisée.',
    'Ce pseudonyme est déjà utilisé.',
  ]) {
    testWidgets(
      'shows the account conflict in the error notification: $message',
      (WidgetTester tester) async {
        await pumpRegisterScreen(
          tester,
          authApiService: _FailingAuthApiService(message),
        );

        await submitValidRegistration(tester);

        final Finder notification = find.byKey(
          const Key('app-notification-error'),
        );
        final BoxDecoration decoration =
            tester.widget<Container>(notification).decoration! as BoxDecoration;
        expect(find.text(message), findsOneWidget);
        expect(tester.getSize(notification).height, 60);
        expect(decoration.color, AppColors.erreur);
        expect(
          tester.widget<Text>(find.text(message)).style?.color,
          Colors.white,
        );
        expect(find.byType(SnackBar), findsNothing);

        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(message), findsNothing);
      },
    );
  }

  for (final ({String message, String fieldKey, String otherFieldKey}) conflict
      in <({String message, String fieldKey, String otherFieldKey})>[
        (
          message: 'Cette adresse e-mail est déjà utilisée.',
          fieldKey: 'register-email-field',
          otherFieldKey: 'register-username-field',
        ),
        (
          message: 'Ce pseudonyme est déjà utilisé.',
          fieldKey: 'register-username-field',
          otherFieldKey: 'register-email-field',
        ),
      ]) {
    testWidgets(
      'focuses, scrolls to and marks the ${conflict.fieldKey} field',
      (WidgetTester tester) async {
        await pumpRegisterScreen(
          tester,
          authApiService: _FailingAuthApiService(conflict.message),
        );

        await submitValidRegistration(tester);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        final Finder field = find.byKey(Key(conflict.fieldKey));
        final Finder fieldInput = find.descendant(
          of: field,
          matching: find.byType(TextFormField),
        );
        final Finder editableField = find.descendant(
          of: fieldInput,
          matching: find.byType(EditableText),
        );
        final Finder otherField = find.byKey(Key(conflict.otherFieldKey));
        final Finder stack = find.byKey(const Key('app-notification-stack'));

        expect(tester.widget<AuthTextFieldWidget>(field).hasError, isTrue);
        expect(
          tester.widget<AuthTextFieldWidget>(otherField).hasError,
          isFalse,
        );
        expect(
          tester.widget<EditableText>(editableField).focusNode.hasFocus,
          isTrue,
        );
        expect(
          tester.getTopLeft(field).dy,
          greaterThanOrEqualTo(tester.getBottomRight(stack).dy),
        );

        await tester.enterText(fieldInput, 'nouvelle-valeur');
        await tester.pump();
        expect(tester.widget<AuthTextFieldWidget>(field).hasError, isFalse);

        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
      },
    );
  }

  testWidgets('does not focus or mark a field for an unknown API error', (
    WidgetTester tester,
  ) async {
    await pumpRegisterScreen(
      tester,
      authApiService: _FailingAuthApiService(
        'Une erreur temporaire est survenue.',
      ),
    );

    await submitValidRegistration(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester
          .widget<AuthTextFieldWidget>(
            find.byKey(const Key('register-email-field')),
          )
          .hasError,
      isFalse,
    );
    expect(
      tester
          .widget<AuthTextFieldWidget>(
            find.byKey(const Key('register-username-field')),
          )
          .hasError,
      isFalse,
    );
    expect(find.text('Une erreur temporaire est survenue.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('keeps the success notification visible after navigation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 1292);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppNotificationService controller = AppNotificationService();
    final GoRouter router = GoRouter(
      initialLocation: '/register',
      routes: <RouteBase>[
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) {
            return RegisterScreen(authApiService: _SuccessfulAuthApiService());
          },
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(body: Text('Destination connexion'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (BuildContext context, Widget? child) {
          return AppNotificationHost(
            controller: controller,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );

    await submitValidRegistration(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Destination connexion'), findsOneWidget);
    expect(
      find.text(
        'Votre compte a été créé. Vous pouvez maintenant vous connecter.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('app-notification-success')), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    controller.reset();
    await tester.pump();
    controller.dispose();
  });
}

class _FailingAuthApiService extends AuthApiService {
  _FailingAuthApiService(this.message);

  final String message;

  @override
  Future<UserResponse> register(RegisterRequest request) async {
    throw AuthApiException(message, statusCode: 409);
  }
}

class _SuccessfulAuthApiService extends AuthApiService {
  @override
  Future<UserResponse> register(RegisterRequest request) async {
    return UserResponse(
      id: '00000000-0000-0000-0000-000000000001',
      firstName: request.firstName,
      lastName: request.lastName,
      email: request.email,
      username: request.username,
      location: request.location,
      createdAt: DateTime(2026, 9, 15),
    );
  }
}
