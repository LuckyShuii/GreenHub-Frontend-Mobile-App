import 'dart:convert';

import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:flutter_frontend/features/auth/data/models/login_request.dart';
import 'package:flutter_frontend/features/auth/data/models/register_request.dart';
import 'package:flutter_frontend/features/auth/data/models/user_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const RegisterRequest request = RegisterRequest(
    firstName: 'Antoine',
    lastName: 'Ribeyre',
    email: 'antoine@example.com',
    username: 'ant_oine',
    location: 'Paris, France',
    password: 'Abcdefghij1!',
  );
  const LoginRequest credentials = LoginRequest(
    email: 'ada@example.com',
    password: 'MotDePasse1!',
  );
  const Map<String, dynamic> tokensBody = <String, dynamic>{
    'access_token': 'access',
    'refresh_token': 'refresh',
    'token_type': 'bearer',
    'expires_in': 900,
  };

  AuthApiService serviceWith(MockClientHandler handler) {
    return AuthApiService(
      baseUrl: 'http://localhost:8000',
      client: MockClient(handler),
    );
  }

  http.Response jsonResponse(Object body, int statusCode) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }

  Matcher apiError({Object? statusCode, Object? message}) {
    Matcher matcher = isA<AuthApiException>().having(
      (AuthApiException error) => error.statusCode,
      'statusCode',
      statusCode,
    );
    if (message != null) {
      matcher = allOf(
        matcher,
        isA<AuthApiException>().having(
          (AuthApiException error) => error.message,
          'message',
          message,
        ),
      );
    }
    return throwsA(matcher);
  }

  for (final String message in <String>[
    'Cette adresse e-mail est déjà utilisée.',
    'Ce pseudonyme est déjà utilisé.',
  ]) {
    test('propagates the API conflict detail: $message', () async {
      final AuthApiService service = AuthApiService(
        baseUrl: 'http://localhost:8000',
        client: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, String>{'detail': message}),
            409,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      await expectLater(
        service.register(request),
        throwsA(
          isA<AuthApiException>()
              .having(
                (AuthApiException error) => error.statusCode,
                'statusCode',
                409,
              )
              .having(
                (AuthApiException error) => error.message,
                'message',
                message,
              ),
        ),
      );
    });
  }

  test('parses the registered user with its UUID identifier', () async {
    final AuthApiService service = serviceWith((http.Request sent) async {
      return jsonResponse(<String, dynamic>{
        'id': '00000000-0000-0000-0000-000000000001',
        'prenom': 'Antoine',
        'nom': 'Ribeyre',
        'email': 'antoine@example.com',
        'pseudonyme': 'ant_oine',
        'date_naissance': null,
        'code_postal': null,
        'date_creation': '2026-09-23T10:00:00Z',
      }, 201);
    });

    final UserResponse user = await service.register(request);

    expect(user.id, '00000000-0000-0000-0000-000000000001');
    expect(user.username, 'ant_oine');
  });

  group('login', () {
    test('posts the normalized credentials and returns the tokens', () async {
      late http.Request sent;
      final AuthApiService service = serviceWith((http.Request request) async {
        sent = request;
        return jsonResponse(tokensBody, 200);
      });

      final AuthTokens tokens = await service.login(
        const LoginRequest(
          email: '  ADA@Example.COM ',
          password: 'MotDePasse1!',
          deviceInfo: 'android',
        ),
      );

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/auth/login');
      expect(jsonDecode(sent.body), <String, dynamic>{
        'email': 'ada@example.com',
        'mot_de_passe': 'MotDePasse1!',
        'device_info': 'android',
      });
      expect(tokens.accessToken, 'access');
      expect(tokens.refreshToken, 'refresh');
      expect(tokens.expiresIn, const Duration(minutes: 15));
    });

    test('flags rejected credentials with a 401 status', () async {
      final AuthApiService service = serviceWith(
        (_) async => jsonResponse(<String, String>{
          'detail': 'Email ou mot de passe incorrect.',
        }, 401),
      );

      await expectLater(service.login(credentials), apiError(statusCode: 401));
    });

    test('reports network failures without a status code', () async {
      final AuthApiService service = serviceWith(
        (_) async => throw http.ClientException('offline'),
      );

      await expectLater(
        service.login(credentials),
        apiError(
          statusCode: isNull,
          message:
              'Impossible de contacter le serveur. Vérifiez votre connexion.',
        ),
      );
    });

    test('reports unexpected server errors with their status', () async {
      final AuthApiService service = serviceWith(
        (_) async => http.Response('', 500),
      );

      await expectLater(
        service.login(credentials),
        apiError(
          statusCode: 500,
          message: 'Le serveur a retourné une erreur inattendue.',
        ),
      );
    });
  });

  group('refresh', () {
    test('sends the refresh token and returns the rotated pair', () async {
      late http.Request sent;
      final AuthApiService service = serviceWith((http.Request request) async {
        sent = request;
        return jsonResponse(tokensBody, 200);
      });

      final AuthTokens tokens = await service.refresh('refresh-1');

      expect(sent.url.path, '/api/auth/refresh');
      expect(jsonDecode(sent.body), <String, dynamic>{
        'refresh_token': 'refresh-1',
      });
      expect(tokens.refreshToken, 'refresh');
    });

    test('flags an expired session with a 401 status', () async {
      final AuthApiService service = serviceWith(
        (_) async => jsonResponse(<String, String>{
          'detail': 'Session expirée. Veuillez vous reconnecter.',
        }, 401),
      );

      await expectLater(
        service.refresh('refresh-1'),
        apiError(
          statusCode: 401,
          message: 'Session expirée. Veuillez vous reconnecter.',
        ),
      );
    });
  });

  test('logout sends the refresh token and accepts an empty 204', () async {
    late http.Request sent;
    final AuthApiService service = serviceWith((http.Request request) async {
      sent = request;
      return http.Response('', 204);
    });

    await service.logout('refresh-1');

    expect(sent.url.path, '/api/auth/logout');
    expect(jsonDecode(sent.body), <String, dynamic>{
      'refresh_token': 'refresh-1',
    });
  });

  group('fetchCurrentUser', () {
    test('authenticates with the bearer token and parses the user', () async {
      late http.Request sent;
      final AuthApiService service = serviceWith((http.Request request) async {
        sent = request;
        return jsonResponse(<String, dynamic>{
          'id': '00000000-0000-0000-0000-000000000001',
          'prenom': 'Ada',
          'nom': 'Lovelace',
          'email': 'ada@example.com',
          'pseudonyme': 'ada',
          'date_naissance': null,
          'code_postal': null,
          'date_creation': '2026-01-01T00:00:00Z',
        }, 200);
      });

      final UserResponse user = await service.fetchCurrentUser('access');

      expect(sent.method, 'GET');
      expect(sent.url.path, '/api/auth/me');
      expect(sent.headers['Authorization'], 'Bearer access');
      expect(user.email, 'ada@example.com');
    });

    test('flags an invalid access token with a 401 status', () async {
      final AuthApiService service = serviceWith(
        (_) async => jsonResponse(<String, String>{
          'detail': 'Session expirée ou invalide.',
        }, 401),
      );

      await expectLater(
        service.fetchCurrentUser('expired'),
        apiError(statusCode: 401),
      );
    });
  });
}
