import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_frontend/app/app.dart';
import 'package:flutter_frontend/features/auth/data/auth_session.dart';

import 'support/fake_auth.dart';

void main() {
  testWidgets('Landing screen displays figma copy text', (
    WidgetTester tester,
  ) async {
    final AuthSession session = AuthSession(
      authApiService: FakeAuthApiService(),
      tokenStorage: InMemoryTokenStorage(),
    );
    await session.restore();

    await tester.pumpWidget(GreenHubApp(authSession: session));

    expect(find.text('Green\'Hub'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
  });

  testWidgets('opens the home screen directly when a session is stored', (
    WidgetTester tester,
  ) async {
    final FakeAuthApiService api = FakeAuthApiService();
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: InMemoryTokenStorage('refresh-1'),
    );
    await session.restore();

    await tester.pumpWidget(GreenHubApp(authSession: session));
    await tester.pumpAndSettle();

    expect(find.text('Connecté en tant que ada@example.com'), findsOneWidget);
    expect(api.refreshedTokens, <String>['refresh-1']);
  });
}
