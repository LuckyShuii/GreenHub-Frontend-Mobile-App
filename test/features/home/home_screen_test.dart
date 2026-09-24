import 'package:flutter/material.dart';
import 'package:flutter_frontend/app/router.dart';
import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/auth_session.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_auth.dart';

void main() {
  late FakeAuthApiService api;
  late InMemoryTokenStorage storage;

  setUp(() {
    api = FakeAuthApiService();
    storage = InMemoryTokenStorage();
  });

  Future<AuthSession> signedInSession() async {
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: storage,
    );
    await session.login(email: 'ada@example.com', password: 'MotDePasse1!');
    return session;
  }

  Future<void> pumpHome(WidgetTester tester, AuthSession session) async {
    final GoRouter router = createAppRouter(
      session,
      initialLocation: AppRoutes.home,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the email of the signed-in user', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, await signedInSession());

    expect(find.text('Connecté en tant que ada@example.com'), findsOneWidget);
    expect(api.accessTokensUsed, <String>['access-1']);
  });

  testWidgets('signs out and returns to the landing screen', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, await signedInSession());

    await tester.tap(find.widgetWithText(FilledButton, 'Déconnexion'));
    await tester.pumpAndSettle();

    expect(find.text('Green\'Hub'), findsOneWidget);
    expect(api.loggedOutTokens, <String>['refresh-1']);
    expect(storage.refreshToken, isNull);
  });

  testWidgets('explains when the profile cannot be loaded', (
    WidgetTester tester,
  ) async {
    api.onFetchCurrentUser = (_) async =>
        throw const AuthApiException('Erreur', statusCode: 500);

    await pumpHome(tester, await signedInSession());

    expect(find.text('Impossible de charger votre profil.'), findsOneWidget);
  });

  testWidgets('sends visitors without a session back to the landing screen', (
    WidgetTester tester,
  ) async {
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: storage,
    );
    await session.restore();

    await pumpHome(tester, session);

    expect(find.text('Green\'Hub'), findsOneWidget);
    expect(api.accessTokensUsed, isEmpty);
  });
}
