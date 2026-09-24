import 'dart:async';

import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/auth_session.dart';
import 'package:flutter_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:flutter_frontend/features/auth/data/models/user_response.dart';
import 'package:flutter_frontend/features/auth/data/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth.dart';

class _UnreadableTokenStorage extends InMemoryTokenStorage {
  @override
  Future<String?> readRefreshToken() async => throw Exception('keystore');
}

class _ReadOnlyTokenStorage extends InMemoryTokenStorage {
  _ReadOnlyTokenStorage(super.refreshToken);

  @override
  Future<void> writeRefreshToken(String refreshToken) async {
    throw Exception('keystore');
  }
}

void main() {
  const AuthApiException rejected = AuthApiException(
    'Session expirée. Veuillez vous reconnecter.',
    statusCode: 401,
  );
  const AuthApiException offline = AuthApiException(
    'Impossible de contacter le serveur. Vérifiez votre connexion.',
  );

  late DateTime now;
  late FakeAuthApiService api;
  late InMemoryTokenStorage storage;

  AuthSession createSession({TokenStorage? tokenStorage}) {
    return AuthSession(
      authApiService: api,
      tokenStorage: tokenStorage ?? storage,
      clock: () => now,
    );
  }

  Future<AuthSession> signedInSession() async {
    final AuthSession session = createSession();
    await session.login(email: 'ada@example.com', password: 'MotDePasse1!');
    return session;
  }

  Future<AuthSession> restoredSession() async {
    storage.refreshToken = 'refresh-1';
    final AuthSession session = createSession();
    await session.restore();
    return session;
  }

  setUp(() {
    now = DateTime(2026, 9, 23, 10);
    api = FakeAuthApiService();
    storage = InMemoryTokenStorage();
  });

  group('restore', () {
    test('stays signed out without a stored refresh token', () async {
      final AuthSession session = createSession();

      await session.restore();

      expect(session.status, AuthStatus.unauthenticated);
    });

    test('signs in from the stored refresh token without any request', () async {
      final AuthSession session = await restoredSession();

      expect(session.status, AuthStatus.authenticated);
      expect(api.refreshedTokens, isEmpty);
    });

    test('stays signed out when the secure storage is unreadable', () async {
      final AuthSession session = createSession(
        tokenStorage: _UnreadableTokenStorage(),
      );

      await session.restore();

      expect(session.status, AuthStatus.unauthenticated);
    });
  });

  group('login', () {
    test('persists only the refresh token and notifies once', () async {
      final AuthSession session = createSession();
      int notifications = 0;
      session.addListener(() => notifications++);

      await session.login(email: 'ada@example.com', password: 'MotDePasse1!');

      expect(session.status, AuthStatus.authenticated);
      expect(storage.refreshToken, 'refresh-1');
      expect(notifications, 1);
      expect(api.loginRequests.single.deviceInfo, isNotEmpty);
      expect(await session.getValidAccessToken(), 'access-1');
      expect(api.refreshedTokens, isEmpty);
    });

    test('propagates rejected credentials and stays signed out', () async {
      api.onLogin = (_) async => throw const AuthApiException(
        'Email ou mot de passe incorrect.',
        statusCode: 401,
      );
      final AuthSession session = createSession();

      await expectLater(
        session.login(email: 'ada@example.com', password: 'faux'),
        throwsA(isA<AuthApiException>()),
      );

      expect(session.status, AuthStatus.unauthenticated);
      expect(storage.refreshToken, isNull);
    });
  });

  group('getValidAccessToken', () {
    test('reuses the access token until shortly before expiry', () async {
      final AuthSession session = await signedInSession();
      now = now.add(const Duration(minutes: 14));

      expect(await session.getValidAccessToken(), 'access-1');
      expect(api.refreshedTokens, isEmpty);
    });

    test('silently renews the access token after 15 minutes', () async {
      final AuthSession session = await signedInSession();
      now = now.add(const Duration(minutes: 15));

      expect(await session.getValidAccessToken(), 'access-2');
      expect(api.refreshedTokens, <String>['refresh-1']);
      expect(storage.refreshToken, 'refresh-2');
      expect(session.status, AuthStatus.authenticated);
    });

    test('renews from the stored refresh token after a restart', () async {
      final AuthSession session = await restoredSession();

      expect(await session.getValidAccessToken(), 'access-2');
      expect(api.refreshedTokens, <String>['refresh-1']);
    });

    test('shares a single refresh between concurrent callers', () async {
      final Completer<AuthTokens> pending = Completer<AuthTokens>();
      api.onRefresh = (_) => pending.future;
      final AuthSession session = await restoredSession();

      final Future<String?> first = session.getValidAccessToken();
      final Future<String?> second = session.getValidAccessToken();
      pending.complete(tokensGeneration(2));

      expect(await first, 'access-2');
      expect(await second, 'access-2');
      expect(api.refreshedTokens, <String>['refresh-1']);
    });

    test('signs out when the server rejects the refresh token', () async {
      api.onRefresh = (_) async => throw rejected;
      final AuthSession session = await restoredSession();
      int notifications = 0;
      session.addListener(() => notifications++);

      expect(await session.getValidAccessToken(), isNull);
      expect(session.status, AuthStatus.unauthenticated);
      expect(storage.refreshToken, isNull);
      expect(notifications, 1);
    });

    test('keeps the session when the network is unavailable', () async {
      api.onRefresh = (_) async => throw offline;
      final AuthSession session = await restoredSession();

      await expectLater(
        session.getValidAccessToken(),
        throwsA(isA<AuthApiException>()),
      );
      expect(session.status, AuthStatus.authenticated);
      expect(storage.refreshToken, 'refresh-1');
    });

    test('forgets the rotated-out token when the new one cannot be saved', () async {
      final _ReadOnlyTokenStorage readOnly = _ReadOnlyTokenStorage('refresh-1');
      final AuthSession session = createSession(tokenStorage: readOnly);
      await session.restore();

      expect(await session.getValidAccessToken(), 'access-2');
      expect(readOnly.refreshToken, isNull);
      expect(session.status, AuthStatus.authenticated);
    });
  });

  group('authorizedCall', () {
    test('retries once with a renewed token after a 401', () async {
      final AuthSession session = await signedInSession();
      final List<String> tokensSeen = <String>[];

      final String result = await session.authorizedCall((
        String accessToken,
      ) async {
        tokensSeen.add(accessToken);
        if (accessToken == 'access-1') {
          throw rejected;
        }
        return 'ok';
      });

      expect(result, 'ok');
      expect(tokensSeen, <String>['access-1', 'access-2']);
      expect(api.refreshedTokens, <String>['refresh-1']);
    });

    test('fails with a 401 when there is no session', () async {
      final AuthSession session = createSession();
      await session.restore();

      await expectLater(
        session.authorizedCall((_) async => 'ok'),
        throwsA(
          isA<AuthApiException>().having(
            (AuthApiException error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('lets other API errors through without refreshing', () async {
      final AuthSession session = await signedInSession();

      await expectLater(
        session.authorizedCall<String>(
          (_) async => throw const AuthApiException('Erreur', statusCode: 500),
        ),
        throwsA(isA<AuthApiException>()),
      );
      expect(api.refreshedTokens, isEmpty);
    });
  });

  test('fetchCurrentUser authenticates with the current token', () async {
    final AuthSession session = await signedInSession();

    final UserResponse user = await session.fetchCurrentUser();

    expect(user.email, 'ada@example.com');
    expect(api.accessTokensUsed, <String>['access-1']);
  });

  group('logout', () {
    test('revokes the session server-side and forgets it locally', () async {
      final AuthSession session = await signedInSession();

      await session.logout();

      expect(api.loggedOutTokens, <String>['refresh-1']);
      expect(storage.refreshToken, isNull);
      expect(session.status, AuthStatus.unauthenticated);
      expect(await session.getValidAccessToken(), isNull);
    });

    test('signs out locally even when the server is unreachable', () async {
      api.onLogout = (_) async => throw offline;
      final AuthSession session = await signedInSession();

      await session.logout();

      expect(storage.refreshToken, isNull);
      expect(session.status, AuthStatus.unauthenticated);
    });
  });
}
