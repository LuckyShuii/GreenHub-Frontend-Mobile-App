import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/app/router.dart';
import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/auth_session.dart';
import 'package:flutter_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:flutter_frontend/shared/services/app_notification_service.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_frontend/shared/widgets/app_notification_host_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_auth.dart';

void main() {
  const String credentialsError = 'Email ou mot de passe est incorrect';
  const AuthApiException rejectedCredentials = AuthApiException(
    'Email ou mot de passe incorrect.',
    statusCode: 401,
  );

  Future<AppNotificationService> pumpLogin(
    WidgetTester tester,
    FakeAuthApiService api,
  ) async {
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: InMemoryTokenStorage(),
    );
    final GoRouter router = createAppRouter(
      session,
      initialLocation: AppRoutes.login,
    );
    addTearDown(router.dispose);
    final AppNotificationService notifications = AppNotificationService();

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (BuildContext context, Widget? child) {
          return AppNotificationHost(
            controller: notifications,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
    return notifications;
  }

  Finder loginButton() => find.byType(FilledButton);

  Future<void> submitCredentials(WidgetTester tester) async {
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'antoine@example.com');
    await tester.enterText(fields.at(1), 'mot-de-passe');
    await tester.tap(find.widgetWithText(FilledButton, 'Connexion'));
    await tester.pump();
  }

  testWidgets('shows the credentials error when the API rejects them', (
    WidgetTester tester,
  ) async {
    final FakeAuthApiService api = FakeAuthApiService(
      onLogin: (_) async => throw rejectedCredentials,
    );
    await pumpLogin(tester, api);

    await submitCredentials(tester);
    await tester.pumpAndSettle();

    expect(find.text(credentialsError), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Connexion'), findsOneWidget);
    expect(api.loginRequests.single.email, 'antoine@example.com');
    expect(api.loginRequests.single.password, 'mot-de-passe');
  });

  testWidgets('opens the home screen once signed in', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester, FakeAuthApiService());

    await submitCredentials(tester);
    await tester.pumpAndSettle();

    expect(find.text('Connecté en tant que ada@example.com'), findsOneWidget);
    expect(find.text(credentialsError), findsNothing);
  });

  testWidgets('reports other failures as a notification', (
    WidgetTester tester,
  ) async {
    const String networkError =
        'Impossible de contacter le serveur. Vérifiez votre connexion.';
    final AppNotificationService notifications = await pumpLogin(
      tester,
      FakeAuthApiService(
        onLogin: (_) async => throw const AuthApiException(networkError),
      ),
    );

    await submitCredentials(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(networkError), findsOneWidget);
    expect(find.text(credentialsError), findsNothing);

    notifications.reset();
    await tester.pump();
    notifications.dispose();
  });

  testWidgets('shows a loading state while signing in', (
    WidgetTester tester,
  ) async {
    final Completer<AuthTokens> pending = Completer<AuthTokens>();
    await pumpLogin(
      tester,
      FakeAuthApiService(onLogin: (_) => pending.future),
    );

    await submitCredentials(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<FilledButton>(loginButton()).onPressed, isNull);

    pending.completeError(rejectedCredentials);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<FilledButton>(loginButton()).onPressed, isNotNull);
  });

  testWidgets('does not call the API when the form is invalid', (
    WidgetTester tester,
  ) async {
    final FakeAuthApiService api = FakeAuthApiService();
    await pumpLogin(tester, api);

    await tester.tap(find.widgetWithText(FilledButton, 'Connexion'));
    await tester.pump();

    expect(api.loginRequests, isEmpty);
    expect(
      find.text('Veuillez renseigner votre adresse e-mail.'),
      findsOneWidget,
    );
  });
}
